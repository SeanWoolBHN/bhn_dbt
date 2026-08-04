WITH number_in_group AS (
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

    -- ── Contact identity ────────────────────────────────────────────
    CO.CONTACT_ID                                         AS ROW_ID,

    -- ── Status ──────────────────────────────────────────────────────
    CO.REQUEST_STATUS,
    CO.ANON_CLIENT_ORG,
    CO.ANON_CLIENT_TYPE,
    CO.CONTACT_SEX,
    CO.ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE,
    CO.ACTION_DETAILS                                     AS ENQ_ACTION_DETAILS,

    -- ── CP — CO.CP is already coalesced in the contact model ────────
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

    -- ── Program stream ──────────────────────────────────────────────
    CO.PROGRAM_STREAM_CODE,
    CO.PROGRAM_STREAM_DESC,

    -- ── Funding source — hardcoded per SSIS ─────────────────────────
    'Home Care Package'                                   AS FUNDING_SOURCE,

    -- ── Validity ────────────────────────────────────────────────────
    CASE
        WHEN CO.ORD_SUB_CAT IN (
            'Podiatry', 'Physiotherapy_DHS', 'Occupational Therapy',
            'Dietetics', 'Nursing', 'Group Social Support'
        ) AND CO.ORDER_STATUS != 'D/C (Discontinued)'
            THEN 'Valid'
        ELSE 'Invalid'
    END                                                   AS VALIDITY,

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

LEFT JOIN number_in_group                                 AS NIG
    ON NIG.EV_NUMBER = CO.EV_NUMBER
    AND NIG.CONTACT_DATE_TIME = CO.CONTACT_DATE_TIME
    AND NIG.PROGRAM_STREAM_DESC = CO.PROGRAM_STREAM_DESC

WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020
  AND CO.PROGRAM_STREAM_CODE IN ('HCPI', 'HCPE')
  AND (
      CO.ORDER_STATUS = 'Executed'
      OR CO.REQUEST_STATUS = 'completed'
      OR (CO.ORDER_STATUS IS NULL AND CO.REQUEST_STATUS IS NULL)
  ). 