WITH ordsubcat_lookup AS (
    SELECT DISTINCT
        MAP.DEPARTMENT_CODE,
        MAP.ITEM_CATEGORY_DESC,
        SUBCAT.ARCIM_CODE                                 AS ARCIM_CODE,
        SUBCAT.ARCIM_DESC                                 AS ARCIM_DESC
    FROM {{ ref('prep_ref_funding_category_national_code_mapping') }} AS MAP
    INNER JOIN {{ ref('prep_ref_order_item_subcategory_mapping') }} AS SUBCAT
        ON SUBCAT.ARCIC_CODE = MAP.ITEM_CATEGORY_CODE
        AND SUBCAT.ARCIC_CODE IS NOT NULL
    WHERE MAP.FUNDING_CATEGORY_CODE = 'IFAMVIO'
),

contacts_with_ordsubcat AS (
    SELECT
        CO.*,
        COALESCE(
            CO.ORD_SUB_CAT,
            OL.ITEM_CATEGORY_DESC
        )                                                 AS ORD_SUB_CAT_RESOLVED
    FROM {{ ref('prep_src_contact_trakcare') }}           AS CO
    LEFT JOIN ordsubcat_lookup                            AS OL
        ON OL.ARCIM_DESC = CO.ORD_ITEM
        AND OL.DEPARTMENT_CODE = CO.PROGRAM_STREAM_CODE
),

first_contact_fvcc AS (
    -- First contact date for FVCC / Family Violence Corrections stream
    -- Replaces correlated subquery: SELECT TOP 1 contactdt WHERE Ordsubcat = 'Family Violence Corrections'
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
    -- First contact date for IFV / other FV streams
    -- Replaces correlated subquery for IFVWCP/FVDHS170/FVDHSPC182 etc.
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
    -- ── First contact date — CASE on program stream ─────────────────
    CASE
        WHEN B.PROGRAM_STREAM_CODE = 'FVCC'
            THEN FC_FVCC.FIRST_CONTACT_DT
        WHEN B.PROGRAM_STREAM_CODE IN (
            'IFVWCP', 'FVDHS170', 'FVDHSPC182', 'FVDHSPC183',
            'IFVMHCP183', 'FVMCMH', 'IFVMHCP', 'IFVPROV'
        )   THEN FC_IFV.FIRST_CONTACT_DT
    END                                                   AS FIRST_CONTACT_DT,


    -- ── Client demographics ─────────────────────────────────────────
    CL.AGE                                                AS AGE,
    CL.GENDER                                             AS GENDER,
    CL.PREF_LANG                                          AS PREF_LANG,
    CL.ATSI                                               AS ATSI,
    CL.HOMELESS                                           AS HOMELESS,

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
    B.CONTACT_ID                                          AS CONTACT_ID,
    B.REPORTING_QTR                                       AS REPORTING_QTR,
    B.CONTACT_DATE                                        AS CONTACT_DT,
    B.UR                                                  AS UR,
    B.EPISODE_ID                                          AS EPISODE_ID,

    -- ── Status — pending OE_OrdStatus / PAC_RequestStatus ───────────
    NULL::VARCHAR                                         AS REQUEST_STATUS,
    --B.ANON_CLIENT_ORG                                     AS ANON_CLIENT_ORG,
    NULL::VARCHAR                                         AS ANON_CLIENT_TYPE,
    NULL::VARCHAR                                         AS CONTACT_SEX,
    B.ENQ_CONTACT_NAME                                    AS ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE                                   AS PRESENTING_ISSUE,

    -- ── CP coalesce ─────────────────────────────────────────────────
    COALESCE(
        NULLIF(B.CARE_PROVIDER, ''),
        NULLIF(EP.EPISODE_CP, ''),
        'Unknown'
    )                                                     AS CARE_PROVIDER,

    -- ── Location / hospital ─────────────────────────────────────────
    B.LOCATION                                            AS LOCATION,
    B.HOSPITAL                                            AS HOSPITAL,

    -- ── Contact method — pending PAC_ContMethod ─────────────────────
    NULL::VARCHAR                                         AS CONTACT_METHOD,
    NULL::VARCHAR                                         AS DELIVERY_MODE,

    -- ── Dates ───────────────────────────────────────────────────────
    B.DATE_ENTERED                                        AS DATE_ENTERED,

    -- ── Hours ───────────────────────────────────────────────────────
    COALESCE(B.DIRECT_MINUTES / 60, 0.00)                 AS DIRECT_HOURS,
    COALESCE(B.INDIRECT_MINUTES / 60, 0.00)               AS INDIRECT_HOURS,
    COALESCE(B.TRAVEL_MINUTES / 60, 0.00)                 AS TRAVEL,

    -- ── Payor / plan ────────────────────────────────────────────────
    NULL::VARCHAR                                         AS PAYOR,
    NULL::VARCHAR                                         AS PLAN,

    -- ── Contact type ────────────────────────────────────────────────
    B.CONTACT_TYPE                                        AS CONTACT_TYPE,
    CASE
        WHEN B.CONTACT_TYPE != 'I'
            THEN 'Non Registered / Org client'
        ELSE 'client'
    END                                                   AS CONTACT_TYPE_DESC,

    -- ── Status ──────────────────────────────────────────────────────
    NULL::VARCHAR                                         AS ORDER_STATUS,

    -- ── Order / item reference ──────────────────────────────────────
    B.ORD_ITEM                                            AS ORD_ITEM,
    B.OEORDI_REF                                          AS OEORDI_REF,
    B.INTERVENTIONS                                       AS INTERVENTIONS,

    -- ── OrdSubCat — resolved via NatCodesFundMapping if NULL ─────────
    B.ORD_SUB_CAT_RESOLVED                                AS ORD_SUB_CAT,

    -- ── Program stream ──────────────────────────────────────────────
    B.PROGRAM_STREAM_CODE                                 AS PROGRAM_STREAM_CODE,
    B.PROGRAM_STREAM_DESC                                 AS PROGRAM_STREAM_DESC,

    -- ── Program derivation ──────────────────────────────────────────
    CASE
        WHEN B.PROGRAM_STREAM_CODE IN ('FVDHSPC183', 'IFVMHCP183')
            THEN 'FVC Family Violence Corrections'
        WHEN B.PROGRAM_STREAM_CODE IN (
            'IFVMHCP', 'IFVWCP', 'FVDHS170', 'FVDHSPC182', 'IFVPROV'
        ) AND B.ORD_SUB_CAT_RESOLVED = 'IRIS Activity Type'
            THEN B.PROGRAM_STREAM_DESC
        WHEN B.PROGRAM_STREAM_CODE = 'FVCC'
          AND B.ORD_SUB_CAT_RESOLVED = 'Family Violence Corrections'
            THEN B.PROGRAM_STREAM_DESC
        WHEN B.PROGRAM_STREAM_CODE = 'FVMCMH'
            THEN B.PROGRAM_STREAM_DESC
        ELSE 'Not supported'
    END                                                   AS PROGRAM,

    -- ── Cost / unit price — ARC_ItemPriceItaly not yet in Snowflake ─
    NULL::FLOAT                                           AS COST,
    NULL::FLOAT                                           AS UNIT_PRICE,

    -- ── Group event fields ──────────────────────────────────────────
    B.EV_NUMBER                                           AS EV_NUMBER,
    B.EV_NAME                                             AS EV_NAME,
    B.EVT_DESC                                            AS EVT_DESC,
    B.EVST_SUB_DESC                                       AS GOVERNMENT_SUBCATEGORY_DESC,
    B.EV_VENUE                                            AS EV_VENUE,
    B.EV_DURATION                                         AS EV_DURATION,
    B.EV_PREPARATION_TIME                                 AS EV_PREPARATION_TIME,
    B.EV_MAX_NUMBER_OF_PARTICIPANTS                       AS EVENT_MAX_NUMBER_OF_PARTICIPANTS 

FROM contacts_with_ordsubcat                              AS B

LEFT JOIN {{ ref('prep_src_episode_trakcare') }}          AS EP
    ON B.EPISODE_ID = EP.EPISODE_ID::VARCHAR

LEFT JOIN {{ ref('prep_src_client_trakcare_sean') }}           AS CL
    ON B.UR = CL.UR

LEFT JOIN first_contact_fvcc                              AS FC_FVCC
    ON B.EPISODE_ID = FC_FVCC.EPISODE_ID
    AND B.PROGRAM_STREAM_CODE = FC_FVCC.PROGRAM_STREAM_CODE
    AND FC_FVCC.RN = 1

LEFT JOIN first_contact_ifv                               AS FC_IFV
    ON B.EPISODE_ID = FC_IFV.EPISODE_ID
    AND B.PROGRAM_STREAM_CODE = FC_IFV.PROGRAM_STREAM_CODE
    AND FC_IFV.RN = 1

WHERE B.ORD_SUB_CAT_RESOLVED IN (
    'IRIS Activity Type',
    'Family Violence Corrections'
)
AND B.PROGRAM_STREAM_CODE IN (
    'IFVMHCP', 'IFVWCP', 'FVDHS170', 'FVDHSPC182', 'FVDHSPC183',
    'IFVMHCP183', 'FVCC', 'FVMCMH', 'IFVPROV'
)
AND LEFT(B.REPORTING_QTR, 4)::NUMBER >= 2020