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
    FROM {{ ref('prep_model_contact') }}           AS CO
    LEFT JOIN ordsubcat_lookup                            AS OL
        ON OL.ARCIM_DESC = CO.ORD_ITEM
        AND OL.DEPARTMENT_CODE = CO.PROGRAM_STREAM_CODE
        AND OL.LEGACY_ORGANISATION_ID = 1
),

first_contact_fvcc AS (
    SELECT
        EPISODE_ID,
        PROGRAM_STREAM_CODE,
        MIN(CONTACT_DATE)                                 AS FIRST_CONTACT_DT,
        ROW_NUMBER() OVER (
            PARTITION BY EPISODE_ID, PROGRAM_STREAM_CODE
            ORDER BY MIN(CONTACT_DATE)
        )                                                 AS RN
    FROM contacts_with_ordsubcat
    WHERE ORD_SUB_CAT_RESOLVED = 'Family Violence Corrections'
      AND PROGRAM_STREAM_CODE = 'FVCC'
    GROUP BY EPISODE_ID, PROGRAM_STREAM_CODE
),

first_contact_ifv AS (
    SELECT
        EPISODE_ID,
        PROGRAM_STREAM_CODE,
        MIN(CONTACT_DATE)                                 AS FIRST_CONTACT_DT,
        ROW_NUMBER() OVER (
            PARTITION BY EPISODE_ID, PROGRAM_STREAM_CODE
            ORDER BY MIN(CONTACT_DATE)
        )                                                 AS RN
    FROM contacts_with_ordsubcat
    WHERE ORD_SUB_CAT_RESOLVED = 'IRIS Activity Type'
      AND PROGRAM_STREAM_CODE IN (
          'IFVWCP', 'FVDHS170', 'FVDHSPC182', 'FVDHSPC183',
          'IFVMHCP183', 'FVMCMH', 'IFVMHCP', 'IFVPROV'
      )
    GROUP BY EPISODE_ID, PROGRAM_STREAM_CODE
)

SELECT
    CASE
        WHEN CO.PROGRAM_STREAM_CODE = 'FVCC'
            THEN FC_FVCC.FIRST_CONTACT_DT
        WHEN CO.PROGRAM_STREAM_CODE IN (
            'IFVWCP', 'FVDHS170', 'FVDHSPC182', 'FVDHSPC183',
            'IFVMHCP183', 'FVMCMH', 'IFVMHCP', 'IFVPROV'
        )   THEN FC_IFV.FIRST_CONTACT_DT
    END                                                   AS FIRST_CONTACT_DT,
    CL.AGE,
    CL.GENDER,
    CL.PREF_LANG,
    CL.ATSI,
    CL.HOMELESS,
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
    CO.REPORTING_QTR,
    CO.CONTACT_DATE                                       AS CONTACT_DT,
    CO.UR,
    CO.EPISODE_ID,
    CO.REQUEST_STATUS,
    CO.ANON_CLIENT_ORG,
    CO.ANON_CLIENT_TYPE,
    CO.CONTACT_SEX,
    CO.ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE,
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
    CO.PAYOR,
    CO.PLAN,
    CO.CONTACT_TYPE,
    CASE
        WHEN CO.CONTACT_TYPE != 'I'
            THEN 'Non Registered / Org client'
        ELSE 'client'
    END                                                   AS CONTACT_TYPE_DESC,
    CO.ORDER_STATUS,
    CO.ORD_ITEM,
    CO.OEORDI_REF,
    CO.OEORDI_REF                                     AS ENQ_OEORDITEM_DR,
    CO.INTERVENTIONS,
    CO.ORD_SUB_CAT_RESOLVED                               AS ORD_SUB_CAT,
    CO.PROGRAM_STREAM_CODE,
    CO.PROGRAM_STREAM_DESC,
    CASE
        WHEN CO.PROGRAM_STREAM_CODE IN ('FVDHSPC183', 'IFVMHCP183')
            THEN 'FVC Family Violence Corrections'
        WHEN CO.PROGRAM_STREAM_CODE IN (
            'IFVMHCP', 'IFVWCP', 'FVDHS170', 'FVDHSPC182', 'IFVPROV'
        ) AND CO.ORD_SUB_CAT_RESOLVED = 'IRIS Activity Type'
            THEN CO.PROGRAM_STREAM_DESC
        WHEN CO.PROGRAM_STREAM_CODE = 'FVCC'
          AND CO.ORD_SUB_CAT_RESOLVED = 'Family Violence Corrections'
            THEN CO.PROGRAM_STREAM_DESC
        WHEN CO.PROGRAM_STREAM_CODE = 'FVMCMH'
            THEN CO.PROGRAM_STREAM_DESC
        ELSE 'Not supported'
    END                                                   AS PROGRAM,
    CO.COST,
    CO.UNIT_PRICE,
    CO.EV_NUMBER,
    CO.EV_NAME,
    CO.EVT_DESC,
    CO.EVST_SUB_DESC                                      AS GOVERNMENT_SUBCATEGORY_DESC,
    CO.EV_VENUE,
    CO.EV_DURATION,
    CO.EV_PREPARATION_TIME,
    CO.EV_MAX_NUMBER_OF_PARTICIPANTS

FROM contacts_with_ordsubcat                              AS CO

LEFT JOIN {{ ref('prep_model_episode') }}          AS EP
    ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

LEFT JOIN {{ ref('prep_model_client') }}           AS CL
    ON CO.UR = CL.UR

LEFT JOIN first_contact_fvcc                              AS FC_FVCC
    ON CO.EPISODE_ID = FC_FVCC.EPISODE_ID
    AND CO.PROGRAM_STREAM_CODE = FC_FVCC.PROGRAM_STREAM_CODE
    AND FC_FVCC.RN = 1

LEFT JOIN first_contact_ifv                               AS FC_IFV
    ON CO.EPISODE_ID = FC_IFV.EPISODE_ID
    AND CO.PROGRAM_STREAM_CODE = FC_IFV.PROGRAM_STREAM_CODE
    AND FC_IFV.RN = 1

WHERE CO.ORD_SUB_CAT_RESOLVED IN (
    'IRIS Activity Type', 'Family Violence Corrections'
)
AND CO.PROGRAM_STREAM_CODE IN (
    'IFVMHCP', 'IFVWCP', 'FVDHS170', 'FVDHSPC182', 'FVDHSPC183',
    'IFVMHCP183', 'FVCC', 'FVMCMH', 'IFVPROV'
)
AND TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
AND (
    CO.ORDER_STATUS = 'Executed'
    OR CO.REQUEST_STATUS = 'completed'
    OR (CO.ORDER_STATUS IS NULL AND CO.REQUEST_STATUS IS NULL)
)