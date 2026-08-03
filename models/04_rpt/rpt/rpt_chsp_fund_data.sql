WITH ordsubcat_lookup AS (
    SELECT DISTINCT
        DEPARTMENT_CODE,
        ORDER_SUBCATEGORY_DESC,
        ORDER_ITEM_DESC                                   AS ARCIM_DESC,
        1                                                 AS LEGACY_ORGANISATION_ID
    FROM {{ ref('prep_ref_order_item_subcategory_mapping') }}
    WHERE DEPARTMENT_CODE = 'CHSP'
      AND ORDER_SUBCATEGORY IS NOT NULL
),

funding_source AS (
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

contacts_with_ordsubcat AS (
    SELECT
        CO.*,
        COALESCE(CO.ORD_SUB_CAT, OL.ORDER_SUBCATEGORY_DESC) AS ORD_SUB_CAT_RESOLVED
    FROM {{ ref('prep_model_contact') }}           AS CO
    LEFT JOIN ordsubcat_lookup                            AS OL
        ON OL.ARCIM_DESC = CO.ORD_ITEM
        AND OL.DEPARTMENT_CODE = CO.PROGRAM_STREAM_CODE
        AND OL.LEGACY_ORGANISATION_ID = 1
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
)

SELECT
    CL.AGE,
    EP.REF_REC_DT,
    EP.REF_CREATE_DT,
    EP.EPISODE_DT,
    EP.INT_REF_TEAM,
    EP.REFERRAL_ORG,
    EP.REF_SOURCE,
    EP.REF_TYPE,
    EP.DATA_COLLECTION_CONSENT                            AS DATA_COLLECTION_CONSENT,
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
    CO.CONTACT_ID                                         AS ROW_ID,
    CO.REQUEST_STATUS,
    CO.ANON_CLIENT_ORG,
    CO.ANON_CLIENT_TYPE,
    CO.CONTACT_SEX,
    CO.ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE,
    CO.ACTION_DETAILS                                     AS ENQ_ACTION_DETAILS,
    COALESCE(
        NULLIF(CO.CP, ''),
        NULLIF(EP.EPISODE_CP, ''),
        'Unknown'
    )                                                     AS CP,
    CO.LOCATION,
    CO.HOSPITAL,
    CO.CONTACT_METHOD,
    CO.DELIVERY_MODE,
    CO.DATE_ENTERED,
    COALESCE(CO.DIRECT_MINUTES / 60, 0.00)                AS DIRECT_HOURS,
    COALESCE(CO.INDIRECT_MINUTES / 60, 0.00)              AS INDIRECT_HOURS,
    COALESCE(CO.TRAVEL_MINUTES / 60, 0.00)                AS TRAVEL,
    COALESCE(CO.KM, 0.00)                                 AS DISTANCE_TRAVELED,
    CO.INTERPRETER,
    CO.PAYOR,
    CO.PLAN,
    CO.PROGRAM_STREAM_CODE,
    CASE
        WHEN CO.PROGRAM_STREAM_CODE = 'CHSP'
            THEN 'Commonwealth Home Support Program'
        ELSE CO.PROGRAM_STREAM_DESC
    END                                                   AS PROGRAM_STREAM_DESC,
    FS.FUNDING_CATEGORY_DESC                              AS FUNDING_SOURCE,
    CO.STO,
    CO.OEORDI_REF,
    CO.OEORDI_REF                                         AS ENQ_OEORDITEM_DR,
    CO.ORD_ITEM,
    CO.ORD_SUB_CAT_RESOLVED                               AS ORD_SUB_CAT,
    CO.INTERVENTIONS,
    CO.CONTACT_TYPE,
    CO.ORDER_STATUS,
    CO.CONTACT_DATE                                       AS CONTACT_DT,
    CO.CONTACT_DATE_TIME,
    CO.EV_NUMBER,
    CO.EV_NAME,
    CO.EVT_DESC,
    CO.EVST_SUB_DESC                                      AS GOVERNMENT_SUBCATEGORY_DESC,
    CO.EV_VENUE,
    CO.EV_DURATION,
    CO.EV_PREPARATION_TIME,
    CO.EV_MAX_NUMBER_OF_PARTICIPANTS,
    NIG.NO_CONTACTS                                       AS NUMBER_IN_GROUP,
    CO.REPORTING_QTR,
    CO.UR,
    CO.EPISODE_ID                                         AS EPISODE,

    -- ── Stream ──────────────────────────────────────────────────────
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
        ) AND CO.HOSPITAL IN ('Social Support Groups', 'Centre Based Respite')
            THEN 'Valid'
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

LEFT JOIN {{ ref('prep_model_episode') }}          AS EP
    ON CAST(CO.EPISODE_ID AS VARCHAR) = CAST(EP.EPISODE_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_model_client') }}           AS CL
    ON CO.UR = CL.UR

LEFT JOIN funding_source                                  AS FS
    ON FS.DEPARTMENT_CODE = CO.PROGRAM_STREAM_CODE
    AND TRIM(FS.ORDER_SUBCATEGORY_DESC) = TRIM(CO.ORD_SUB_CAT_RESOLVED)
    AND FS.RN = 1

LEFT JOIN number_in_group                                 AS NIG
    ON NIG.EV_NAME = CO.EV_NAME
    AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
    AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
  AND (CO.PROGRAM_STREAM_CODE = 'CHSP' OR CO.PROGRAM_STREAM_CODE IS NULL)
  AND (
      CO.ORDER_STATUS = 'Executed'
      OR CO.REQUEST_STATUS = 'completed'
      OR (CO.ORDER_STATUS IS NULL AND CO.REQUEST_STATUS IS NULL)
  )