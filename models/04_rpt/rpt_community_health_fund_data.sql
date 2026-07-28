WITH funding_source AS (
    SELECT
        DEPARTMENT_CODE,
        ORDER_SUBCATEGORY_DESC,
        FUNDING_CATEGORY_DESC,
        ROW_NUMBER() OVER (
            PARTITION BY DEPARTMENT_CODE, ORDER_SUBCATEGORY_DESC
            ORDER BY ORDER_SUBCATEGORY
        )                                                 AS RN
    FROM {{ ref('prep_ref_funding_category_national_code_mapping') }}
    WHERE ORDER_SUBCATEGORY IS NOT NULL
),

number_in_group AS (
    SELECT
        EV_NAME,
        CONTACT_DATE_TIME,
        PROGRAM_STREAM_DESC,
        CASE
            WHEN SUM(DIRECT_MINUTES) = 0 THEN 0
            ELSE COUNT(CONTACT_ID)
        END                                               AS NO_CONTACTS
    FROM {{ ref('prep_model_contact') }}
    WHERE EV_NUMBER IS NOT NULL
      AND DIRECT_MINUTES > 0
    GROUP BY EV_NAME, CONTACT_DATE_TIME, PROGRAM_STREAM_DESC
),

base AS (
    SELECT
        -- ── Client demographics ─────────────────────────────────────
        CL.AGE,

        -- ── Episode fields ──────────────────────────────────────────
        EP.REF_REC_DT,
        EP.REF_CREATE_DT,
        EP.EPISODE_DT,
        EP.INT_REF_TEAM,
        EP.REFERRAL_ORG,
        EP.REF_SOURCE,
        EP.REF_TYPE,
        EP.DATA_COLLECTION_CONSENT                        AS DAT_COLLECTION_CONSENT,
        EP.CONSENT_TO_REFERRAL,
        EP.REFERRAL_REASON,
        EP.EPISODE_TEAM,
        EP.EPISODE_CP,
        EP.SERVICE,
        EP.REFERRAL_STATUS,
        EP.REF_PRIORITY,
        EP.EPISODE_ACTIVE,
        EP.DAYS_OPEN,
        EP.EXT_REQUESTOR_NAME,
        EP.DISCHARGE_DT,
        EP.REFERRAL_DESTINATION,

        -- ── Contact identity ────────────────────────────────────────
        CO.CONTACT_ID                                     AS ROW_ID,

        -- ── Status ──────────────────────────────────────────────────
        CO.REQUEST_STATUS,
        CO.ORDER_STATUS,

        -- ── Contact fields ──────────────────────────────────────────
        CO.ANON_CLIENT_ORG,
        CO.ANON_CLIENT_TYPE,
        CO.CONTACT_SEX,
        CO.ENQ_CONTACT_NAME,
        EP.PRESENTING_ISSUE,
        CO.ACTION_DETAILS                                 AS ENQ_ACTION_DETAILS,

        -- ── CP ──────────────────────────────────────────────────────
        COALESCE(
            NULLIF(CO.CP, ''),
            NULLIF(EP.EPISODE_CP, ''),
            'Unknown'
        )                                                 AS CP,

        -- ── Location ────────────────────────────────────────────────
        CO.LOCATION,
        CO.HOSPITAL,
        CO.CONTACT_METHOD,
        CO.DELIVERY_MODE,
        CO.DATE_ENTERED,

        -- ── Hours ───────────────────────────────────────────────────
        COALESCE(CO.DIRECT_MINUTES / 60, 0.00)            AS DIRECT_HOURS,
        COALESCE(CO.INDIRECT_MINUTES / 60, 0.00)          AS INDIRECT_HOURS,
        COALESCE(CO.TRAVEL_MINUTES / 60, 0.00)            AS TRAVEL,
        COALESCE(CO.KM, 0.00)                             AS DISTANCE_TRAVELED,
        CO.INTERPRETER,

        -- ── Payor / plan ────────────────────────────────────────────
        CO.PAYOR,
        CO.PLAN,

        -- ── Program stream ──────────────────────────────────────────
        CO.PROGRAM_STREAM_CODE,
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
                        'Child Health Team', 'Child Development Service',
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
                        'Podiatry', 'Physiotherapy_DHS', 'Occupational Therapy',
                        'Dietetics', 'Diabetes Education'
                    )   THEN REPLACE(CO.ORD_SUB_CAT, '_DHS', '')
                    WHEN CO.HOSPITAL IN (
                        'Allied Health', 'Podiatry', 'Physiotherapy',
                        'Occupational Therapy', 'Dietetics', 'Coordinator'
                    ) AND CO.ORD_SUB_CAT IN (
                        'Podiatry', 'Physiotherapy_DHS', 'Occupational Therapy',
                        'Dietetics', 'Client Care Co-ordination'
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
        FS.FUNDING_CATEGORY_DESC                          AS FUNDING_SOURCE,

        -- ── Validity ────────────────────────────────────────────────
        CASE
            WHEN CO.PROGRAM_STREAM_CODE = 'CHPDCHP'
              AND CO.ORD_SUB_CAT IN (
                'Intake Worker', 'Podiatry', 'Physiotherapy_DHS',
                'Occupational Therapy', 'Nursing', 'Counselling',
                'Dietetics', 'Speech Pathology', 'Client Care Co-ordination',
                'Youth Worker', 'Primary Community Health worker'
              ) THEN 'Valid'
            WHEN CO.PROGRAM_STREAM_CODE = 'CHPDICDM'
              AND CO.ORD_SUB_CAT IN (
                'Intake Worker', 'Podiatry', 'Physiotherapy_DHS',
                'Occupational Therapy', 'Nursing', 'Counselling',
                'Dietetics', 'Speech Pathology', 'Diabetes Education',
                'Client Care Co-ordination', 'Youth Worker', 'Social Worker',
                'Primary Community Health worker'
              ) THEN 'Valid'
            WHEN TRIM(CO.PROGRAM_STREAM_CODE) = 'CHPDIHS'
              AND CO.ORD_SUB_CAT IN (
                'Intake Worker', 'Nursing', 'Counselling',
                'Client Care Co-ordination', 'Youth Worker', 'Social Worker'
              ) THEN 'Valid'
            ELSE 'Invalid'
        END                                               AS VALIDITY,

        -- ── Order reference ─────────────────────────────────────────
        CO.STO,
        CO.OEORDI_REF,
        CO.OEORDI_REF                                AS ENQ_OEORDITEM_DR,
        CO.ORD_ITEM,
        CO.ORD_SUB_CAT,
        CO.INTERVENTIONS,
        CO.CONTACT_TYPE,
        CO.CONTACT_DATE                                   AS CONTACT_DT,
        CO.CONTACT_DATE_TIME,
        CO.RB_EVENT_DR                                    AS ENQ_RBEVENT_DR,
        CO.EV_NUMBER,
        CO.EV_NAME,
        CO.EVT_DESC,
        CO.EVST_SUB_DESC                                  AS GOVERNMENT_SUBCATEGORY_DESC,
        CO.EV_VENUE,
        CO.EV_DURATION,
        CO.EV_PREPARATION_TIME,
        CO.EV_MAX_NUMBER_OF_PARTICIPANTS,
        NIG.NO_CONTACTS                                   AS NUMBER_IN_GROUP,
        CO.REPORTING_QTR,
        CO.UR,
        CO.EPISODE_ID                                     AS EPISODE

    FROM {{ ref('prep_model_contact') }}           AS CO

    LEFT JOIN {{ ref('prep_model_episode') }}      AS EP
        ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

    LEFT JOIN {{ ref('prep_model_client') }}       AS CL
        ON CO.UR = CL.UR

    LEFT JOIN funding_source                              AS FS
        ON FS.DEPARTMENT_CODE = CO.PROGRAM_STREAM_CODE
        AND TRIM(FS.ORDER_SUBCATEGORY_DESC) = TRIM(CO.ORD_SUB_CAT)
        AND FS.RN = 1

    LEFT JOIN number_in_group                             AS NIG
        ON NIG.EV_NAME = CO.EV_NAME
        AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
        AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

    WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
      AND (CO.PROGRAM_STREAM_CODE ILIKE 'CHP%' OR CO.PROGRAM_STREAM_CODE IS NULL)
      AND (
          CO.ORDER_STATUS = 'Executed'
          OR CO.REQUEST_STATUS = 'completed'
          OR (CO.ORDER_STATUS IS NULL AND CO.REQUEST_STATUS IS NULL)
      )
      AND CO.HOSPITAL NOT IN ('Carer Respite', 'Social Support Groups', 'Midwifery')
)

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