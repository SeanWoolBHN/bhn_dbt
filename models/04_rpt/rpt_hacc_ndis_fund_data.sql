SELECT
    CL.AGE,
    -- AgeSplit derivation using age at contact date
    CASE
        WHEN CL.ATSI = 'ATSI'
          AND FLOOR(DATEDIFF('day', CL.DOB, CO.CONTACT_DATE) / 365.25) > 50
            THEN 'Commonwealth'
        WHEN CL.ATSI = 'Non-ATSI'
          AND FLOOR(DATEDIFF('day', CL.DOB, CO.CONTACT_DATE) / 365.25) > 65
            THEN 'Commonwealth'
        ELSE 'State'
    END                                                   AS AGE_SPLIT,
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
    CO.CONTACT_DATE                                       AS CONTACT_DT,
    CO.UR,
    CO.EPISODE_ID                                         AS EPISODE,
    CO.CONTACT_ID                                         AS ROW_ID,
    CO.REQUEST_STATUS,
    CO.ANON_CLIENT_ORG,
    CO.ANON_CLIENT_TYPE,
    CO.CONTACT_SEX,
    CO.ENQ_CONTACT_NAME,
    EP.PRESENTING_ISSUE,
    COALESCE(NULLIF(CO.CP, ''), NULLIF(EP.EPISODE_CP, ''), 'Unknown') AS CP,
    CO.LOCATION,
    CO.HOSPITAL,
    CO.CONTACT_METHOD,
    CO.DELIVERY_MODE,
    CO.DATE_ENTERED,
    -- Raw minutes per SSIS
    CO.DIRECT_MINUTES                                     AS DIRECT,
    CO.INDIRECT_MINUTES                                   AS INDIRECT,
    CO.TRAVEL_MINUTES                                     AS TRAVEL,
    -- Hours
    CO.DIRECT_MINUTES / 60                                AS DIRECT_HRS,
    CO.INDIRECT_MINUTES / 60                              AS INDIRECT_HRS,
    CO.TRAVEL_MINUTES / 60                                AS TRAVEL_HRS,
    CO.INTERPRETER,
    -- Payor hardcoded per SSIS
    'HACC NDIS Assessments'                               AS PAYOR,
    CO.STO,
    CO.PLAN,
    CO.ORD_ITEM,
    CO.OEORDI_REF,
    CO.OEORDI_REF                                         AS ENQ_OEORDITEM_DR,
    CO.CONTACT_TYPE,
    CO.ORDER_STATUS,
    CO.INTERVENTIONS,
    CO.ORD_SUB_CAT,
    CO.PROGRAM_STREAM_CODE,
    CO.PROGRAM_STREAM_DESC,
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

FROM {{ ref('prep_model_contact') }}                      AS CO

LEFT JOIN {{ ref('prep_model_episode') }}                 AS EP
    ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

LEFT JOIN {{ ref('prep_model_client') }}           AS CL
    ON CO.UR = CL.UR

WHERE (
    CO.PAYOR IN ('HACC NDIS Assess', 'HACC - NDIS Funding')
    OR CO.PROGRAM_STREAM_DESC IN ('HACC NDIS Funding', 'HACC NDIS Assessment')
)
AND TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= 2020