WITH funding_source AS (
    -- Pre-compute FundingSource — replaces correlated subquery on NatCodesFundMapping
    -- Original SSIS: SELECT TOP 1 NFMI_Desc WHERE Arcic_code IS NOT NULL
    --                AND NTC.Dep_code = a.Program_Stream_Code
    --                AND LTRIM(RTRIM(NTC.Arcic_Desc)) = LTRIM(RTRIM(a.OrdSubCat))
    SELECT
        DEP_CODE,
        ARCIC_DESC,
        NFMI_DESC,
        ROW_NUMBER() OVER (
            PARTITION BY DEP_CODE, ARCIC_DESC
            ORDER BY ARCIC_CODE
        )                                                 AS RN
    FROM {{ ref('prep_ref_national_codes_fund_mapping') }}
    WHERE ARCIC_CODE IS NOT NULL
),

number_in_group AS (
    -- Pre-compute group contact counts — replaces correlated subquery on Contacts
    -- Original SSIS: COUNT(RowId) WHERE Ev_Number IS NOT NULL AND direct > 0
    --                GROUP BY Ev_Name, contactdatetime, Program_Stream_Desc
    SELECT
        EV_NAME,
        CONTACT_DATE_TIME,
        PROGRAM_STREAM_DESC,
        CASE
            WHEN SUM(DIRECT_MINUTES) = 0 THEN 0
            ELSE COUNT(CONTACT_ID)
        END                                               AS NO_CONTACTS
    FROM {{ ref('prep_src_contact_trakcare') }}
    WHERE EV_NUMBER IS NOT NULL
      AND DIRECT_MINUTES > 0
    GROUP BY EV_NAME, CONTACT_DATE_TIME, PROGRAM_STREAM_DESC
),

base AS (
    SELECT
        -- ── Client demographics ─────────────────────────────────────
        CL.AGE                                            AS AGE,

        -- ── Episode fields ──────────────────────────────────────────
        EP.REF_REC_DT                                     AS REF_REC_DT,
        EP.REF_CREATE_DT                                  AS REF_CREATE_DT,
        EP.EPISODE_DT                                     AS EPISODE_DT,
        EP.INT_REF_TEAM                                   AS INT_REF_TEAM,
        EP.REFERRAL_ORG                                   AS REFERRAL_ORG,
        EP.REF_SOURCE                                     AS REF_SOURCE,
        EP.REF_TYPE                                       AS REF_TYPE,
        EP.DATA_COLLECTION_CONSENT                        AS DAT_COLLECTION_CONSENT,
        EP.CONSENT_TO_REFERRAL                            AS CONSENT_TO_REFERRAL,
        EP.REFERRAL_REASON                                AS REFERRAL_REASON,
        EP.EPISODE_TEAM                                   AS EPISODE_TEAM,
        EP.EPISODE_CP                                     AS EPISODE_CP,
        EP.SERVICE                                        AS SERVICE,
        NULL::VARCHAR                                     AS REFERRAL_STATUS,
        NULL::VARCHAR                                     AS REF_PRIORITY,
        EP.EPISODE_ACTIVE                                 AS EPISODE_ACTIVE,
        EP.DAYS_OPEN                                      AS DAYS_OPEN,
        EP.EXT_REQUESTOR_NAME                             AS EXT_REQUESTOR_NAME,
        EP.DISCHARGE_DT                                   AS DISCHARGE_DT,
        EP.REFERRAL_DESTINATION                           AS REFERRAL_DESTINATION,

        -- ── Contact identity ────────────────────────────────────────
        CO.CONTACT_ID                                     AS CONTACT_ID,

        NULL::VARCHAR                                     AS REQUEST_STATUS,
        NULL::VARCHAR                                     AS ORDER_STATUS,

        -- ── Contact fields ──────────────────────────────────────────
        'ANON_CLIENT_ORG'                                 AS ANON_CLIENT_ORG,
        NULL::VARCHAR                                     AS ANON_CLIENT_TYPE,
        NULL::VARCHAR                                     AS CONTACT_SEX,
        CO.ENQ_CONTACT_NAME                               AS ENQ_CONTACT_NAME,
        EP.PRESENTING_ISSUE                               AS PRESENTING_ISSUE,
        'ENQ_ACTION_DETAILS'                              AS ENQ_ACTION_DETAILS,

        -- ── CP coalesce — matches ISNULL(ISNULL(CP, EpisodeCP), 'Unknown')
        COALESCE(
            NULLIF(CO.CARE_PROVIDER, ''),
            NULLIF(EP.EPISODE_CP, ''),
            'Unknown'
        )                                                 AS CARE_PROVIDER,

        -- ── Location / hospital ─────────────────────────────────────
        CO.LOCATION                                       AS LOCATION,
        CO.HOSPITAL                                       AS HOSPITAL,

        -- ── Contact method — pending PAC_ContMethod ─────────────────
        NULL::VARCHAR                                     AS CONTACT_METHOD,
        NULL::VARCHAR                                     AS DELIVERY_MODE,

        -- ── Dates ───────────────────────────────────────────────────
        CO.DATE_ENTERED                                   AS DATE_ENTERED,

        -- ── Hours / distance — matches ISNULL(x/60, 0.00) ──────────
        COALESCE(CO.DIRECT_MINUTES / 60, 0.00)            AS DIRECT_HOURS,
        COALESCE(CO.INDIRECT_MINUTES / 60, 0.00)          AS INDIRECT_HOURS,
        COALESCE(CO.TRAVEL_MINUTES / 60, 0.00)            AS TRAVEL,
        COALESCE(CO.KM, 0.00)                             AS DISTANCE_TRAVELED,
        CO.INTERPRETER                                    AS INTERPRETER,

        -- ── Payor / plan — pending PA_ADMINSURANCE ──────────────────
        NULL::VARCHAR                                     AS PAYOR,
        NULL::VARCHAR                                     AS PLAN,

        -- ── Program stream ──────────────────────────────────────────
        CO.PROGRAM_STREAM_CODE                            AS PROGRAM_STREAM_CODE,
        CASE
            WHEN CO.PROGRAM_STREAM_CODE = 'CHPDCHP'
                THEN 'Community Health Program'
            WHEN CO.PROGRAM_STREAM_CODE = 'CHPDICDM'
                THEN 'Integrated Chronic Disease'
            WHEN TRIM(CO.PROGRAM_STREAM_CODE) = 'CHPDIHS'
                THEN 'Innovative Health Services for Homeless Youth'
            ELSE CO.PROGRAM_STREAM_DESC
        END                                               AS PROGRAM_STREAM_DESC,

        -- ── Allied health sub-program ────────────────────────────────
        CASE
            WHEN CO.PROGRAM_STREAM_CODE = 'CHPDCHP' THEN
                CASE
                    WHEN CO.HOSPITAL IN (
                        'Child Health Team',
                        'Child Development Service',
                        'Child and Family Services'
                    )   THEN 'Child Health'
                    WHEN (
                        CO.LOCATION ILIKE '%Paed%'
                        OR CO.LOCATION ILIKE '%CFS%'
                        OR CO.LOCATION ILIKE '%CDS%'
                    ) AND CO.ORD_SUB_CAT != 'Intake Worker'
                        THEN 'Child Health'
                    WHEN CO.ORD_SUB_CAT = 'Speech Pathology'
                        THEN 'Child Health'
                    WHEN CO.HOSPITAL = 'Case Management'
                      AND CO.ORD_SUB_CAT = 'Counselling'
                        THEN 'Case Management'
                    WHEN CO.ORD_SUB_CAT = 'Youth Worker'
                        THEN 'Casework Counselling'
                    WHEN CO.HOSPITAL IN (
                        'Casework Counselling', 'Counselling',
                        'Alcohol & Drug', 'AHA', 'Smoking Cessation'
                    ) AND CO.ORD_SUB_CAT = 'Counselling'
                        THEN 'Casework Counselling'
                    WHEN (
                        CO.LOCATION NOT ILIKE '%Paed%'
                        OR CO.LOCATION NOT ILIKE '%CFS%'
                        OR CO.LOCATION NOT ILIKE '%CDS%'
                    ) AND CO.ORD_SUB_CAT = 'Counselling'
                        THEN 'Casework Counselling'
                    WHEN CO.ORD_SUB_CAT = 'Nursing'
                        THEN CO.ORD_SUB_CAT
                    WHEN (
                        CO.LOCATION NOT ILIKE '%Paed%'
                        OR CO.LOCATION NOT ILIKE '%CFS%'
                    ) AND CO.ORD_SUB_CAT IN (
                        'Podiatry', 'Physiotherapy_DHS',
                        'Occupational Therapy', 'Dietetics',
                        'Diabetes Education'
                    )   THEN REPLACE(CO.ORD_SUB_CAT, '_DHS', '')
                    WHEN CO.HOSPITAL IN (
                        'Allied Health', 'Podiatry', 'Physiotherapy',
                        'Occupational Therapy', 'Dietetics', 'Coordinator'
                    ) AND CO.ORD_SUB_CAT IN (
                        'Podiatry', 'Physiotherapy_DHS',
                        'Occupational Therapy', 'Dietetics',
                        'Client Care Co-ordination'
                    )   THEN REPLACE(CO.ORD_SUB_CAT, '_DHS', '')
                    WHEN CO.HOSPITAL = 'AHA'
                      AND (
                        CO.ORD_SUB_CAT != 'Counselling'
                        OR CO.ORD_SUB_CAT != 'Speech Pathology'
                      ) THEN REPLACE(CO.ORD_SUB_CAT, '_DHS', '')
                    WHEN CO.HOSPITAL != 'AHA'
                      AND CO.ORD_SUB_CAT IN (
                        'Podiatry', 'Physiotherapy_DHS',
                        'Occupational Therapy', 'Dietetics'
                      ) THEN REPLACE(CO.ORD_SUB_CAT, '_DHS', '')
                    WHEN CO.ORD_SUB_CAT = 'Intake worker'
                        THEN 'Intake & Referral'
                    ELSE NULL
                END
            ELSE NULL
        END                                               AS ALLIED_HEALTH_SUB_PROGRAM,

        -- ── Funding source ──────────────────────────────────────────
        FS.NFMI_DESC                                      AS FUNDING_SOURCE,

        -- ── Validity ────────────────────────────────────────────────
        CASE
            WHEN CO.PROGRAM_STREAM_CODE = 'CHPDCHP'
              AND CO.ORD_SUB_CAT IN (
                'Intake Worker', 'Podiatry', 'Physiotherapy_DHS',
                'Occupational Therapy', 'Nursing', 'Counselling',
                'Dietetics', 'Speech Pathology',
                'Client Care Co-ordination', 'Youth Worker',
                'Primary Community Health worker'
              ) THEN 'Valid'
            WHEN CO.PROGRAM_STREAM_CODE = 'CHPDICDM'
              AND CO.ORD_SUB_CAT IN (
                'Intake Worker', 'Podiatry', 'Physiotherapy_DHS',
                'Occupational Therapy', 'Nursing', 'Counselling',
                'Dietetics', 'Speech Pathology', 'Diabetes Education',
                'Client Care Co-ordination', 'Youth Worker',
                'Social Worker', 'Primary Community Health worker'
              ) THEN 'Valid'
            WHEN TRIM(CO.PROGRAM_STREAM_CODE) = 'CHPDIHS'
              AND CO.ORD_SUB_CAT IN (
                'Intake Worker', 'Nursing', 'Counselling',
                'Client Care Co-ordination', 'Youth Worker',
                'Social Worker'
              ) THEN 'Valid'
            ELSE 'Invalid'
        END                                               AS VALIDITY,

        -- ── Order / contact reference ────────────────────────────────
        CO.STO                                            AS STO,
        CO.OEORDI_REF                                     AS OEORDI_REF,
        CO.ORD_ITEM                                       AS ORD_ITEM,
        CO.ORD_SUB_CAT                                    AS ORD_SUB_CAT,
        CO.INTERVENTIONS                                  AS INTERVENTIONS,
        CO.CONTACT_TYPE                                   AS CONTACT_TYPE,

        -- ── Contact dates ───────────────────────────────────────────
        CO.CONTACT_DATE                                   AS CONTACT_DT,
        CO.CONTACT_DATE_TIME                              AS CONTACT_DATE_TIME,

        -- ── Group event fields ──────────────────────────────────────
        CO.RB_EVENT_DR                                    AS ENQ_RBEVENT_DR,
        CO.EV_NUMBER                                      AS EV_NUMBER,
        CO.EV_NAME                                        AS EV_NAME,
        CO.EVT_DESC                                       AS EVT_DESC,
        CO.EVST_SUB_DESC                                  AS SUB_DESC,
        CO.EV_VENUE                                       AS EV_VENUE,
        CO.EV_DURATION                                    AS EV_DURATION,
        CO.EV_PREPARATION_TIME                            AS EV_PREPARATION_TIME,
        CO.EV_MAX_NUMBER_OF_PARTICIPANTS                   AS EV_MAX_NUMBER_OF_PARTICIPANTS,

        -- ── Number in group ─────────────────────────────────────────
        NIG.NO_CONTACTS                                   AS NUMBER_IN_GROUP,

        -- ── Reporting quarter / UR / episode ────────────────────────
        CO.REPORTING_QTR                                  AS REPORTING_QTR,
        CO.UR                                             AS UR,
        CO.EPISODE_ID                                     AS EPISODE

    FROM {{ ref('prep_src_contact_trakcare') }}           AS CO

    LEFT JOIN {{ ref('prep_src_episode_trakcare') }}      AS EP
        ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

    LEFT JOIN {{ ref('prep_src_client_trakcare_sean') }}       AS CL
        ON CO.UR = CL.UR

    LEFT JOIN funding_source                              AS FS
        ON FS.DEP_CODE = CO.PROGRAM_STREAM_CODE
        AND TRIM(FS.ARCIC_DESC) = TRIM(CO.ORD_SUB_CAT)
        AND FS.RN = 1

    LEFT JOIN number_in_group                             AS NIG
        ON NIG.EV_NAME = CO.EV_NAME
        AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
        AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

    WHERE LEFT(CO.REPORTING_QTR, 4)::NUMBER >= 2020
      AND (CO.PROGRAM_STREAM_CODE ILIKE 'CHP%'
           OR CO.PROGRAM_STREAM_CODE IS NULL)
      AND CO.HOSPITAL NOT IN (
          'Carer Respite', 'Social Support Groups', 'Midwifery'
      )
)

-- ── Outer STREAM derivation — matches original SSIS outer SELECT ─────
SELECT
    *,
    CASE
        WHEN ALLIED_HEALTH_SUB_PROGRAM IN (
            'Child Health', 'Casework Counselling',
            'Intake & Referral', 'Case Management', 'Nursing'
        )   THEN ALLIED_HEALTH_SUB_PROGRAM
        WHEN PROGRAM_STREAM_DESC = 'Community Health Program'
          AND EV_NUMBER IS NOT NULL
          AND CONTACT_TYPE = 'FE'
            THEN 'Allied Health Groups'
        WHEN ALLIED_HEALTH_SUB_PROGRAM IS NOT NULL
            THEN 'Allied Health'
        WHEN ALLIED_HEALTH_SUB_PROGRAM IS NULL
          AND PROGRAM_STREAM_CODE = 'CHPDCHP'
          AND ORD_SUB_CAT = 'Counselling'
            THEN 'Casework Counselling'
        WHEN ALLIED_HEALTH_SUB_PROGRAM IS NULL
          AND PROGRAM_STREAM_CODE = 'CHPDCHP'
          AND ORD_SUB_CAT != 'Counselling'
            THEN 'Allied Health'
        ELSE PROGRAM_STREAM_DESC
    END                                                   AS STREAM

FROM base