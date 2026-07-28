WITH ordsubcat_lookup AS (
    SELECT DISTINCT
        DEPARTMENT_CODE,
        ORDER_SUBCATEGORY_DESC,
        ORDER_ITEM_DESC                                   AS ARCIM_DESC,
        1                                                 AS LEGACY_ORGANISATION_ID
    FROM {{ ref('prep_ref_order_item_subcategory_mapping') }}
    WHERE ORDER_SUBCATEGORY IS NOT NULL
),

contacts_with_ordsubcat AS (
    SELECT
        CO.*,
        COALESCE(CO.ORD_SUB_CAT, OL.ORDER_SUBCATEGORY_DESC) AS ORD_SUB_CAT_RESOLVED
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
    'SH' || CO.CONTACT_ID::VARCHAR                        AS IROW_ID,
    'SH' || CO.UR::VARCHAR                                AS IUR,
    'SH' || CO.EPISODE_ID::VARCHAR                        AS IEPISODE,
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
    CO.PROGRAM_STREAM_CODE,
    CO.PROGRAM_STREAM_DESC,
    CASE
        WHEN CO.PROGRAM_STREAM_CODE IN ('CBC', 'NR')
          AND CO.PAYOR = 'MECWA Care Packages'
            THEN CO.PAYOR
        WHEN CO.PROGRAM_STREAM_CODE = 'MECWA'
            THEN CO.PROGRAM_STREAM_DESC
    END                                                   AS FUNDING_SOURCE,
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
    NIG.NO_CONTACTS                                       AS NUMBER_IN_GROUP

FROM contacts_with_ordsubcat                              AS CO

LEFT JOIN {{ ref('prep_model_episode') }}                 AS EP
    ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

LEFT JOIN {{ ref('prep_model_client') }}           AS CL
    ON CO.UR = CL.UR

LEFT JOIN number_in_group                                 AS NIG
    ON NIG.EV_NUMBER = CO.EV_NUMBER
    AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
    AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
  AND (
      (CO.PROGRAM_STREAM_CODE IN ('CBC', 'NR') AND CO.PAYOR = 'MECWA Care Packages')
      OR CO.PROGRAM_STREAM_CODE = 'MECWA'
  )
  AND (
      CO.ORDER_STATUS = 'Executed'
      OR CO.REQUEST_STATUS = 'completed'
      OR (CO.ORDER_STATUS IS NULL AND CO.REQUEST_STATUS IS NULL)
  )