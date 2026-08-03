WITH first_contact_dt AS (
    -- First contact date per episode where OrdSubCat = 'Care Finder Activity'
    -- Replaces correlated subquery: SELECT TOP 1 Contactdt WHERE OrdSubCat = 'Care Finder Activity'
    SELECT
        EPISODE_ID,
        MIN(CONTACT_DATE)                                 AS FIRST_CONTACT_DT
    FROM {{ ref('prep_model_contact') }}
    WHERE ORD_SUB_CAT = 'Care Finder Activity'
    GROUP BY EPISODE_ID
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

    -- ── Client demographics ─────────────────────────────────────────
    CL.AGE,

    -- ── Episode fields ──────────────────────────────────────────────
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
    EP.DISCHARGE_CLASSIFICATION,

    -- ── Contact identity ────────────────────────────────────────────
    CO.CONTACT_ID                                         AS ROW_ID,

    -- ── Status ──────────────────────────────────────────────────────
    CO.REQUEST_STATUS,
    CO.ANON_CLIENT_ORG,
    CO.ANON_CLIENT_TYPE,
    CO.CONTACT_SEX,
    CO.ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE,

    -- ── CP ──────────────────────────────────────────────────────────
    COALESCE(
        NULLIF(CO.CP, ''),
        NULLIF(EP.EPISODE_CP, ''),
        'Unknown'
    )                                                     AS CP,

    -- ── Location ────────────────────────────────────────────────────
    CO.LOCATION,
    CO.HOSPITAL,
    CO.CONTACT_METHOD,
    CO.DELIVERY_MODE,
    CO.DATE_ENTERED,

    -- ── Hours ───────────────────────────────────────────────────────
    COALESCE(CO.DIRECT_MINUTES / 60, 0.00)                AS DIRECT_HOURS,
    COALESCE(CO.INDIRECT_MINUTES / 60, 0.00)              AS INDIRECT_HOURS,
    COALESCE(CO.TRAVEL_MINUTES / 60, 0.00)                AS TRAVEL,
    COALESCE(CO.KM, 0.00)                                 AS DISTANCE_TRAVELED,
    CO.INTERPRETER,

    -- ── Payor / plan ────────────────────────────────────────────────
    CO.PAYOR,
    CO.PLAN,

    -- ── Program stream — hardcoded per SSIS ─────────────────────────
    CO.PROGRAM_STREAM_CODE,
    'Care finder'                                         AS PROGRAM_STREAM_DESC,

    -- ── Order reference ─────────────────────────────────────────────
    CO.STO,
    CO.OEORDI_REF,
    CO.OEORDI_REF                                         AS ENQ_OEORDITEM_DR,
    CO.ORD_ITEM,
    CO.ORD_SUB_CAT,
    CO.INTERVENTIONS,
    CO.CONTACT_TYPE,
    CO.ORDER_STATUS,
    CO.CONTACT_DATE                                       AS CONTACT_DT,

    -- ── First contact date for this episode ─────────────────────────
    FC.FIRST_CONTACT_DT,

    -- ── Contact datetime ────────────────────────────────────────────
    CO.CONTACT_DATE_TIME,

    -- ── Group event fields ──────────────────────────────────────────
    CO.EV_NUMBER,
    CO.EV_NAME,
    CO.EVT_DESC,
    CO.EVST_SUB_DESC                                      AS GOVERNMENT_SUBCATEGORY_DESC,
    CO.EV_VENUE,
    CO.EV_DURATION,
    CO.EV_PREPARATION_TIME,
    CO.EV_MAX_NUMBER_OF_PARTICIPANTS,

    -- ── Number in group ─────────────────────────────────────────────
    NIG.NO_CONTACTS                                       AS NUMBER_IN_GROUP,

    -- ── Reporting ───────────────────────────────────────────────────
    CO.REPORTING_QTR,
    CO.UR,
    CO.EPISODE_ID                                         AS EPISODE

FROM {{ ref('prep_model_contact') }}                      AS CO

LEFT JOIN {{ ref('prep_model_episode') }}                 AS EP
    ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

LEFT JOIN {{ ref('prep_model_client') }}           AS CL
    ON CO.UR = CL.UR

LEFT JOIN first_contact_dt                                AS FC
    ON CO.EPISODE_ID = FC.EPISODE_ID

LEFT JOIN number_in_group                                 AS NIG
    ON NIG.EV_NUMBER = CO.EV_NUMBER
    AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
    AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
  AND CO.ORD_SUB_CAT = 'Care Finder Activity'
  AND (
      CO.ORDER_STATUS = 'Executed'
      OR CO.REQUEST_STATUS = 'completed'
      OR (CO.ORDER_STATUS IS NULL AND CO.REQUEST_STATUS IS NULL)
  )