WITH ordsubcat_lookup AS (
    -- Resolve OrdSubCat when NULL via NatCodesFundMapping + Orditem_OrdSubcatMapTable
    -- Filtered to CHSP program only
    SELECT DISTINCT
        MAP.DEP_CODE,
        MAP.ARCIC_DESC,
        SUBCAT.ARCIM_DESC                                 AS ARCIM_DESC
    FROM {{ ref('prep_ref_national_codes_fund_mapping') }} AS MAP
    INNER JOIN {{ ref('prep_ref_order_item_subcategory_mapping') }} AS SUBCAT
        ON SUBCAT.ARCIC_CODE = MAP.ARCIC_CODE
        AND SUBCAT.ARCIC_CODE IS NOT NULL
    WHERE MAP.DEP_CODE = 'CHSP'
      AND MAP.ARCIC_CODE IS NOT NULL
),

funding_source AS (
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

contacts_with_ordsubcat AS (
    SELECT
        CO.*,
        COALESCE(
            CO.ORD_SUB_CAT,
            OL.ARCIC_DESC
        )                                                 AS ORD_SUB_CAT_RESOLVED
    FROM {{ ref('prep_src_contact_trakcare') }}           AS CO
    LEFT JOIN ordsubcat_lookup                            AS OL
        ON OL.ARCIM_DESC = CO.ORD_ITEM
        AND OL.DEP_CODE = CO.PROGRAM_STREAM_CODE
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
    FROM {{ ref('prep_src_contact_trakcare') }}
    WHERE EV_NUMBER IS NOT NULL
    AND TRY_TO_NUMBER(DIRECT_MINUTES::VARCHAR) > 0
    GROUP BY EV_NAME, CONTACT_DATE_TIME, PROGRAM_STREAM_DESC
)

SELECT

    -- ── Client demographics ─────────────────────────────────────────
    CL.AGE                                                AS AGE,

    -- ── Episode fields ──────────────────────────────────────────────
    EP.REF_REC_DT                                         AS REF_REC_DT,
    EP.REF_CREATE_DT                                      AS REF_CREATE_DT,
    EP.EPISODE_DT                                         AS EPISODE_DT,
    EP.INT_REF_TEAM                                       AS INT_REF_TEAM,
    EP.REFERRAL_ORG                                       AS REFERRAL_ORG,
    EP.REF_SOURCE                                         AS REF_SOURCE,
    EP.REF_TYPE                                           AS REF_TYPE,
    EP.DATA_COLLECTION_CONSENT                            AS DAT_COLLECTION_CONSENT,
    EP.CONSENT_TO_REFERRAL                                AS CONSENT_TO_REFERRAL,
    EP.REFERRAL_REASON                                    AS REFERRAL_REASON,
    EP.EPISODE_TEAM                                       AS EPISODE_TEAM,
    EP.EPISODE_CP                                         AS EPISODE_CP,
    EP.SERVICE                                            AS SERVICE,
    NULL::VARCHAR                                         AS REFERRAL_STATUS,
    NULL::VARCHAR                                         AS REF_PRIORITY,
    EP.EPISODE_ACTIVE                                     AS EPISODE_ACTIVE,
    EP.DAYS_OPEN                                          AS DAYS_OPEN,
    EP.EXT_REQUESTOR_NAME                                 AS EXT_REQUESTOR_NAME,
    EP.DISCHARGE_DT                                       AS DISCHARGE_DT,
    EP.REFERRAL_DESTINATION                               AS REFERRAL_DESTINATION,

    -- ── Contact identity ────────────────────────────────────────────
    CO.CONTACT_ID                                         AS ROW_ID,

    -- ── Status placeholders ─────────────────────────────────────────
    NULL::VARCHAR                                         AS REQUEST_STATUS,
    NULL::VARCHAR                                         AS ANON_CLIENT_ORG,
    NULL::VARCHAR                                         AS ANON_CLIENT_TYPE,
    NULL::VARCHAR                                         AS CONTACT_SEX,
    CO.ENQ_CONTACT_NAME                                   AS ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE                                   AS PRESENTING_ISSUE,
    NULL::VARCHAR                                         AS ENQ_ACTION_DETAILS,

    -- ── CP ──────────────────────────────────────────────────────────
    COALESCE(
        NULLIF(CO.CARE_PROVIDER, ''),
        NULLIF(EP.EPISODE_CP, ''),
        'Unknown'
    )                                                     AS CARE_PROVIDER,

    -- ── Location / hospital ─────────────────────────────────────────
    CO.LOCATION                                           AS LOCATION,
    CO.HOSPITAL                                           AS HOSPITAL,

    -- ── Contact method ──────────────────────────────────────────────
    NULL::VARCHAR                                         AS CONTACT_METHOD,
    NULL::VARCHAR                                         AS DELIVERY_MODE,

    -- ── Dates ───────────────────────────────────────────────────────
    CO.DATE_ENTERED                                       AS DATE_ENTERED,

    -- ── Hours ───────────────────────────────────────────────────────
    COALESCE(CO.DIRECT_MINUTES / 60, 0.00)                AS DIRECT_HOURS,
    COALESCE(CO.INDIRECT_MINUTES / 60, 0.00)              AS INDIRECT_HOURS,
    COALESCE(CO.TRAVEL_MINUTES / 60, 0.00)                AS TRAVEL,
    COALESCE(CO.KM, 0.00)                                 AS DISTANCE_TRAVELED,
    CO.INTERPRETER                                        AS INTERPRETER,

    -- ── Payor / plan ────────────────────────────────────────────────
    NULL::VARCHAR                                         AS PAYOR,
    NULL::VARCHAR                                         AS PLAN,

    -- ── Program stream ──────────────────────────────────────────────
    CO.PROGRAM_STREAM_CODE                                AS PROGRAM_STREAM_CODE,
    CASE
        WHEN CO.PROGRAM_STREAM_CODE = 'CHSP'
            THEN 'Commonwealth Home Support Program'
        ELSE CO.PROGRAM_STREAM_DESC
    END                                                   AS PROGRAM_STREAM_DESC,

    -- ── Funding source ──────────────────────────────────────────────
    FS.NFMI_DESC                                          AS FUNDING_SOURCE,

    -- ── Order reference ─────────────────────────────────────────────
    CO.STO                                                AS STO,
    CO.OEORDI_REF                                         AS OEORDI_REF,
    CO.ORD_ITEM                                           AS ORD_ITEM,
    CO.ORD_SUB_CAT_RESOLVED                               AS ORD_SUB_CAT,
    CO.INTERVENTIONS                                      AS INTERVENTIONS,
    CO.CONTACT_TYPE                                       AS CONTACT_TYPE,
    NULL::VARCHAR                                         AS ORDER_STATUS,

    -- ── Contact dates ───────────────────────────────────────────────
    CO.CONTACT_DATE                                       AS CONTACT_DT,
    CO.CONTACT_DATE_TIME                                  AS CONTACT_DATE_TIME,

    -- ── Group event fields ──────────────────────────────────────────
    CO.EV_NUMBER                                          AS EV_NUMBER,
    CO.EV_NAME                                            AS EV_NAME,
    CO.EVT_DESC                                           AS EVT_DESC,
    CO.EVST_SUB_DESC                                      AS SUB_DESC,
    CO.EV_VENUE                                           AS EV_VENUE,
    CO.EV_DURATION                                        AS EV_DURATION,
    CO.EV_PREPARATION_TIME                                AS EV_PREPARATION_TIME,
    CO.EV_MAX_NUMBER_OF_PARTICIPANTS                      AS EV_MAX_NUMBER_OF_PARTICIPANTS,

    -- ── Number in group ─────────────────────────────────────────────
    NIG.NO_CONTACTS                                       AS NUMBER_IN_GROUP,

    -- ── Reporting quarter ───────────────────────────────────────────
    CO.REPORTING_QTR                                      AS REPORTING_QTR,
    CO.UR                                                 AS UR,
    CO.EPISODE_ID                                         AS EPISODE,

    -- ── Stream derivation ───────────────────────────────────────────
    CASE
        WHEN CO.ORD_SUB_CAT_RESOLVED ILIKE 'Housing%'
            THEN 'Insecure Housing'
        WHEN CO.LOCATION = 'Community Connections Program'
          AND CO.HOSPITAL = 'outreach'
          AND CO.ORD_SUB_CAT_RESOLVED = 'Client Care Co-ordination'
            THEN 'Access and Support'
        WHEN CO.LOCATION IN ('Indigenous Access')
          AND CO.ORD_SUB_CAT_RESOLVED = 'Client Care Co-ordination'
          AND CO.HOSPITAL = 'Indigenous Access'
            THEN 'Indigenous Access and Support'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Dietetics', 'Occupational Therapy', 'Physiotherapy_DHS',
            'Podiatry', 'Speech Pathology'
        )   THEN REPLACE(CO.ORD_SUB_CAT_RESOLVED, '_DHS', '')
        WHEN CO.ORD_SUB_CAT_RESOLVED ILIKE '%Group%'
            THEN 'Group Social Support'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Nursing'
            THEN CO.ORD_SUB_CAT_RESOLVED
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Centre Based Day Respite', 'Centre Based Respite'
        )   THEN 'Centre Based Respite'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Dementia Advisory Service', 'Dementia Support Services'
        )   THEN 'Dementia Support Services'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Social Support Indiv - Accompanied'
          AND CO.LOCATION ILIKE '%SSI – Accompanied CoPP%'
            THEN 'Social Support Individual - Accompanied'
        ELSE NULL
    END                                                   AS STREAM,

    -- ── Parent stream ────────────────────────────────────────────────
    CASE
        WHEN CO.ORD_SUB_CAT_RESOLVED ILIKE 'Housing%'
            THEN 'CHSP Specialised Services'
        WHEN CO.ORD_SUB_CAT_RESOLVED ILIKE '%Care Co-ord%'
            THEN 'CHSP Specialised Services'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Dietetics', 'Occupational Therapy', 'Physiotherapy_DHS',
            'Podiatry', 'Speech Pathology'
        )   THEN 'CHSP Allied Health'
        WHEN CO.ORD_SUB_CAT_RESOLVED ILIKE '%Group%'
            THEN 'CHSP Social Support Group'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Nursing'
            THEN 'CHSP Nursing'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Centre Based Day Respite', 'Centre Based Respite'
        )   THEN 'CHSP Social Support Group'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Dementia Advisory Service', 'Dementia Support Services'
        )   THEN 'CHSP Dementia Advisory Service'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Social Support Indiv - Accompanied'
          AND CO.LOCATION ILIKE '%SSI – Accompanied CoPP%'
          AND CO.HOSPITAL = 'Outreach'
            THEN 'CHSP Social Support Individual'
        ELSE 'Error Not applicable'
    END                                                   AS PARENT_STREAM,

    -- ── Validity ────────────────────────────────────────────────────
    CASE
        WHEN CO.EPISODE_ID IS NULL
            THEN 'Invalid'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Nursing', 'Dietetics', 'Group Social Support',
            'Occupational Therapy', 'Physiotherapy_DHS', 'Podiatry',
            'Planned Activity Group Core', 'Planned Activity Group High',
            'Dementia Advisory Service', 'Speech Pathology',
            'Dementia Support Services'
        )   THEN 'Valid'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Housing Assistance'
          AND EP.SERVICE = 'Case Management'
            THEN 'Valid'
        WHEN CO.LOCATION = 'Community Connections Program'
          AND CO.HOSPITAL = 'outreach'
          AND CO.ORD_SUB_CAT_RESOLVED = 'Client Care Co-ordination'
            THEN 'Valid'
        WHEN CO.LOCATION IN ('Indigenous Access')
          AND CO.ORD_SUB_CAT_RESOLVED = 'Client Care Co-ordination'
          AND EP.SERVICE = 'Indigenous Access'
          AND CO.HOSPITAL = 'Indigenous Access'
            THEN 'Valid'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Social Support Indiv - Accompanied'
            THEN 'Valid'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Centre Based Day Respite', 'Centre Based Respite'
        ) AND CO.HOSPITAL IN (
            'Social Support Groups', 'Centre Based Respite'
        )   THEN 'Valid'
        ELSE 'Invalid'
    END                                                   AS VALIDITY,

    -- ── Allied health sub-program ────────────────────────────────────
    CASE
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Dietetics', 'Occupational Therapy', 'Physiotherapy_DHS',
            'Podiatry', 'Speech Pathology'
        )   THEN REPLACE(CO.ORD_SUB_CAT_RESOLVED, '_DHS', '')
        ELSE NULL
    END                                                   AS ALLIED_HEALTH_SUB_PROGRAM

FROM contacts_with_ordsubcat                              AS CO

LEFT JOIN {{ ref('prep_src_episode_trakcare') }}          AS EP
    ON CAST(CO.EPISODE_ID AS VARCHAR) = CAST(EP.EPISODE_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_src_client_trakcare_sean') }}           AS CL
    ON CO.UR = CL.UR

LEFT JOIN funding_source                                  AS FS
    ON FS.DEP_CODE = CO.PROGRAM_STREAM_CODE
    AND TRIM(FS.ARCIC_DESC) = TRIM(CO.ORD_SUB_CAT_RESOLVED)
    AND FS.RN = 1

LEFT JOIN number_in_group                                 AS NIG
    ON NIG.EV_NAME = CO.EV_NAME
    AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
    AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
  AND (
      CO.PROGRAM_STREAM_CODE = 'CHSP'
      OR CO.PROGRAM_STREAM_CODE IS NULL
  )
