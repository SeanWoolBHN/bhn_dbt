WITH funding_source AS (
    SELECT
        DEPARTMENT_CODE,
        FUNDING_CATEGORY_DESC                             AS SUB_DESC,
        ROW_NUMBER() OVER (
            PARTITION BY DEPARTMENT_CODE
            ORDER BY ORDER_SUBCATEGORY
        )                                                 AS RN
    FROM {{ ref('prep_ref_funding_category_national_code_mapping') }}
    WHERE ORDER_SUBCATEGORY IS NOT NULL
),

ordsubcat_lookup AS (
    SELECT DISTINCT
        ORDER_ITEM_DESC                                   AS ARCIM_DESC,
        ORDER_SUBCATEGORY_DESC,
        1                                                 AS LEGACY_ORGANISATION_ID
    FROM {{ ref('prep_ref_order_item_subcategory_mapping') }}
    WHERE ORDER_SUBCATEGORY IS NOT NULL
),

contacts_with_ordsubcat AS (
    SELECT
        CO.*,
        CASE
            WHEN CO.CONTACT_TYPE = 'FE'
                THEN COALESCE(CO.ORD_SUB_CAT, OL.ORDER_SUBCATEGORY_DESC)
            ELSE CO.ORD_SUB_CAT
        END                                               AS ORD_SUB_CAT_RESOLVED
    FROM {{ ref('prep_model_contact') }}                  AS CO
    LEFT JOIN ordsubcat_lookup                            AS OL
        ON OL.ARCIM_DESC = CO.ORD_ITEM
        AND OL.LEGACY_ORGANISATION_ID = 1
),

number_in_group AS (
    SELECT
        EV_NUMBER,
        CONTACT_DATE_TIME,
        PROGRAM_STREAM_DESC,
        CASE
            WHEN SUM(DIRECT_MINUTES) = 0 THEN 0
            ELSE COUNT(CONTACT_ID)
        END                                               AS NO_CONTACTS
    FROM {{ ref('prep_model_contact') }}
    WHERE EV_NUMBER IS NOT NULL
      AND DIRECT_MINUTES > 0
    GROUP BY EV_NUMBER, CONTACT_DATE_TIME, PROGRAM_STREAM_DESC
),

program_stream_mapped AS (
    SELECT
        CO.*,
        CASE
            WHEN CO.PROGRAM_STREAM_CODE = 'HACCCR'   THEN 'HACC'
            WHEN CO.PROGRAM_STREAM_CODE = 'HACC-CCP' THEN 'HACC'
            WHEN CO.PROGRAM_STREAM_CODE = 'HACCH'    THEN 'HACC'
            ELSE CO.PROGRAM_STREAM_CODE
        END                                               AS PROGRAM_STREAM_CODE_MAPPED,
        CASE
            WHEN CO.PROGRAM_STREAM_DESC = 'HACC Home and Community Care' THEN 'HACC'
            WHEN CO.PROGRAM_STREAM_DESC = 'HACC CCP and Insecure Housing' THEN 'HACC'
            WHEN CO.PROGRAM_STREAM_DESC = 'HACC Core'                     THEN 'HACC'
            WHEN CO.PROGRAM_STREAM_DESC = 'HACC High'                     THEN 'HACC'
            ELSE CO.PROGRAM_STREAM_DESC
        END                                               AS PROGRAM_STREAM_DESC_MAPPED
    FROM contacts_with_ordsubcat                          AS CO
)

SELECT
    CL.AGE,
    CO.UR,
    FLOOR(DATEDIFF('day', CL.DOB, CO.CONTACT_DATE) / 365.25) AS AGE_AT_CONTACT,
    CL.ATSI,
    EP.REF_REC_DT,
    EP.REF_CREATE_DT,
    EP.EPISODE_DT,
    EP.INT_REF_TEAM,
    EP.REFERRAL_ORG,
    EP.REF_SOURCE,
    EP.REF_TYPE,
    EP.DATA_COLLECTION_CONSENT                            AS DAT_COLLECTION_CONSENT,
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
    CO.EPISODE_ID                                         AS EPISODE,
    CO.REQUEST_STATUS,
    CO.ANON_CLIENT_ORG,
    CO.ANON_CLIENT_TYPE,
    CO.CONTACT_SEX,
    CO.ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE,
    CO.ACTION_DETAILS                                     AS ENQ_ACTION_DETAILS,
    COALESCE(NULLIF(CO.CP, ''), NULLIF(EP.EPISODE_CP, ''), 'Unknown') AS CP,
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
    CO.PROGRAM_STREAM_CODE                                AS ORIG_CODE,
    CO.PROGRAM_STREAM_DESC                                AS ORIG_DESC,
    CO.PROGRAM_STREAM_CODE_MAPPED                         AS PROGRAM_STREAM_CODE,
    CO.PROGRAM_STREAM_DESC_MAPPED                         AS PROGRAM_STREAM_DESC,
    FS.SUB_DESC                                           AS FUNDING_SOURCE,

    -- Program derivation
    CASE
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED IN (
            'HACC', 'HACC Home and Community Care', 'HACC High', 'HACC Core'
        ) AND CO.ORD_SUB_CAT_RESOLVED = 'Nursing '
            THEN 'HACC Nursing'
        WHEN CO.ORD_SUB_CAT_RESOLVED ILIKE 'Planned Activity Group%'
          AND CO.PROGRAM_STREAM_DESC_MAPPED IN (
              'HACC', 'HACC Home and Community Care', 'HACC High', 'HACC Core'
          ) THEN 'HACC Social Support Group'
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED = 'HACC'
          AND CO.ORD_SUB_CAT_RESOLVED = 'Respite Care'
          AND CO.HOSPITAL = 'Carer Respite'
          AND EP.SERVICE = 'Carer Respite'
            THEN 'HACC Respite Care'
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED = 'HACC A&S and  SRS'
          AND CO.LOCATION = 'SRS Outreach'
          AND CO.HOSPITAL = 'Outreach'
          AND CO.ORD_SUB_CAT_RESOLVED IN ('Assertive Outreach', 'Client Care Co-ordination')
            THEN 'LCA SRS Outreach and Assistance Program'
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED = 'HACC Older Persons High-Rise Support'
          AND CO.LOCATION = 'SRS Outreach'
          AND CO.HOSPITAL = 'Outreach'
          AND CO.ORD_SUB_CAT_RESOLVED = 'Housing Assistance'
            THEN 'Outreach Housing Assistance'
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED ILIKE 'HACC A&S%'
          AND EP.SERVICE = 'HACC Access and Support'
          AND EP.EPISODE_TEAM = 'HACC Indigenous Access and Support'
          AND CO.LOCATION IN ('Indigenous Access', 'HACC Indigenous Access and Support')
          AND CO.HOSPITAL IN ('HACC Access and Support', 'Indigenous Access')
          AND CO.ORD_SUB_CAT_RESOLVED = 'Client Care Co-ordination'
            THEN 'LCA Housing Support for the Aged'
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED ILIKE 'HACC A&S%'
          AND CO.LOCATION = 'HACC Access and Support'
          AND CO.HOSPITAL = 'HACC Access and Support'
          AND EP.SERVICE = 'HACC Access and Support'
          AND CO.ORD_SUB_CAT_RESOLVED = 'Client Care Co-ordination'
            THEN 'HACC Access and Support'
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED ILIKE 'HACC A&S%'
          AND CO.ORD_SUB_CAT_RESOLVED ILIKE 'Assertive Outreach%'
            THEN 'HACC FSR Assertive Outreach'
        WHEN CO.PROGRAM_STREAM_DESC_MAPPED ILIKE 'HACC A&S%'
          AND CO.ORD_SUB_CAT_RESOLVED ILIKE 'Client Care Co-ord%'
            THEN 'HACC Access and Support'
        WHEN CO.ORD_SUB_CAT_RESOLVED IN (
            'Podiatry', 'Physiotherapy_DHS', 'Occupational Therapy', 'Dietetics'
        ) AND CO.PROGRAM_STREAM_DESC_MAPPED IN (
            'HACC', 'HACC Home and Community Care', 'HACC High', 'HACC Core'
        ) THEN 'HACC Allied Health'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Voluntary Social Support'
          AND CO.HOSPITAL = 'HACC PYP Volunteer'
          AND CO.PROGRAM_STREAM_DESC_MAPPED = 'HACC'
            THEN 'HACC Volunteer Coordination'
        WHEN CO.ORD_SUB_CAT_RESOLVED = 'Voluntary Social Support'
          AND CO.HOSPITAL = 'volunteer coordination'
            THEN 'HACC Volunteer Coordination'
        ELSE 'Do not use ' || CO.PROGRAM_STREAM_DESC_MAPPED
    END                                                   AS PROGRAM,

    -- Allied health sub program
    CASE
        WHEN CO.PROGRAM_STREAM_CODE_MAPPED IN ('HACC', 'HACCH', 'HACCCR')
          AND CO.ORD_SUB_CAT_RESOLVED IN (
              'Podiatry', 'Physiotherapy_DHS', 'Occupational Therapy',
              'Nursing', 'Dietetics'
          ) THEN
            CASE
                WHEN CO.LOCATION ILIKE '%Paed%' OR CO.LOCATION ILIKE '%CFS%'
                    THEN 'Child Health'
                WHEN CO.HOSPITAL = 'Child Development Service'
                    THEN 'Child Health'
                WHEN CO.ORD_SUB_CAT_RESOLVED = 'Nursing'
                    THEN CO.ORD_SUB_CAT_RESOLVED
                ELSE REPLACE(CO.ORD_SUB_CAT_RESOLVED, '_DHS', '')
            END
    END                                                   AS ALLIED_HEALTH_SUB_PROGRAM,

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

    -- AgeSplit
    CASE
        WHEN CL.ATSI = 'ATSI'
          AND FLOOR(DATEDIFF('day', CL.DOB, CO.CONTACT_DATE) / 365.25) > 50
            THEN 'Commonwealth'
        WHEN CL.ATSI = 'Non-ATSI'
          AND FLOOR(DATEDIFF('day', CL.DOB, CO.CONTACT_DATE) / 365.25) > 65
            THEN 'Commonwealth'
        ELSE 'State'
    END                                                   AS AGE_SPLIT

FROM program_stream_mapped                                AS CO

INNER JOIN {{ ref('prep_model_client') }}          AS CL
    ON CO.UR = CL.UR
    AND CL.FIRST_NAME != 'Outreach'

LEFT JOIN {{ ref('prep_model_episode') }}                 AS EP
    ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

LEFT JOIN funding_source                                  AS FS
    ON FS.DEPARTMENT_CODE = CO.PROGRAM_STREAM_CODE_MAPPED
    AND FS.RN = 1

LEFT JOIN number_in_group                                 AS NIG
    ON NIG.EV_NUMBER = CO.EV_NUMBER
    AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
    AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
  AND CO.PROGRAM_STREAM_CODE ILIKE 'HACC%'
  AND EP.SERVICE != 'Dementia Advisory Services'
  AND (
      CO.ORDER_STATUS = 'Executed'
      OR CO.REQUEST_STATUS = 'completed'
      OR (CO.ORDER_STATUS IS NULL AND CO.REQUEST_STATUS IS NULL)
  )