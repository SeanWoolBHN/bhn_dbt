WITH hacc_exceptions AS (
    SELECT
        ORIG_DESC                                         AS PROGRAM_STREAM_DESC,
        EPISODE_DT,
        REF_REC_DT,
        DISCHARGE_DT,
        LOCATION,
        HOSPITAL,
        SERVICE,
        EPISODE_TEAM,
        CP,
        UR,
        NULL::VARCHAR                                     AS EPISODE,
        ORD_SUB_CAT,
        ORD_ITEM,
        CONTACT_DT,
        DIRECT_HOURS                                      AS TOTAL_HRS,
        'Order Item/Program Stream/Service used invalid'  AS ERROR
    FROM {{ ref('rpt_hacc_funding') }}
    WHERE PROGRAM = 'Do not use ' || ORIG_DESC
      AND CONTACT_TYPE IN ('I', 'FE')

    UNION ALL

    SELECT
        ORIG_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION, HOSPITAL,
        SERVICE, EPISODE_TEAM, CP, UR, NULL::VARCHAR,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT, DIRECT_HOURS,
        'Client does not meet HACC Age funding criteria'
    FROM {{ ref('rpt_hacc_funding') }}
    WHERE AGE_SPLIT = 'Commonwealth'
      AND CONTACT_TYPE IN ('I', 'FE')
      AND REQUEST_STATUS = 'Completed'

    UNION ALL

    SELECT
        ORIG_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION, HOSPITAL,
        SERVICE, EPISODE_TEAM, CP, UR, NULL::VARCHAR,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT, DIRECT_HOURS,
        'Contact Date prior to referral Date'
    FROM {{ ref('rpt_hacc_funding') }}
    WHERE REF_REC_DT > CONTACT_DT
      AND CONTACT_TYPE IN ('I', 'FE')
      AND REQUEST_STATUS = 'Completed'

    UNION ALL

    SELECT
        ORIG_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION, HOSPITAL,
        SERVICE, EPISODE_TEAM, CP, UR, NULL::VARCHAR,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT, DIRECT_HOURS,
        'Discharge Date prior to referral Date'
    FROM {{ ref('rpt_hacc_funding') }}
    WHERE DISCHARGE_DT < CONTACT_DT
      AND CONTACT_TYPE IN ('I', 'FE')
      AND REQUEST_STATUS = 'Completed'
),

chp_exceptions AS (
    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE AS EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT,
        DIRECT_HOURS + INDIRECT_HOURS                     AS TOTAL_HRS,
        'Discharge Date prior to referral Date'           AS ERROR
    FROM {{ ref('rpt_community_health_fund_data') }}
    WHERE DISCHARGE_DT < CONTACT_DT
      AND REQUEST_STATUS = 'completed'
      AND (ORDER_STATUS IS NULL OR ORDER_STATUS != 'D/C (Discontinued)')

    UNION ALL

    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT,
        DIRECT_HOURS + INDIRECT_HOURS,
        'Contact Date prior to referral Date'
    FROM {{ ref('rpt_community_health_fund_data') }}
    WHERE REF_REC_DT > CONTACT_DT
      AND REQUEST_STATUS = 'completed'
      AND (ORDER_STATUS IS NULL OR ORDER_STATUS != 'D/C (Discontinued)')

    UNION ALL

    SELECT
        CH.PROGRAM_STREAM_DESC, CH.EPISODE_DT, CH.REF_REC_DT, CH.DISCHARGE_DT,
        CH.LOCATION, CH.HOSPITAL, CH.SERVICE, CH.EPISODE_TEAM, CH.CP, CH.UR,
        CH.EPISODE, CH.ORD_SUB_CAT, CH.ORD_ITEM, CH.CONTACT_DT,
        CH.DIRECT_HOURS + CH.INDIRECT_HOURS,
        'Incorrect Team / Program Stream'
    FROM {{ ref('rpt_community_health_fund_data') }}              AS CH
    LEFT JOIN {{ ref('prep_ref_service_location_mapping') }}      AS LM
        ON CH.LOCATION = LM.LOCATION_DESC
        AND LM.RPORTING_TYPE_DESC = 'Community Health Program Data'
    WHERE LM.LOCATION_DESC IS NULL
      AND CH.REQUEST_STATUS = 'completed'
      AND (CH.ORDER_STATUS IS NULL OR CH.ORDER_STATUS != 'D/C (Discontinued)')

    UNION ALL

    SELECT
        B.PROGRAM_STREAM_DESC, B.EPISODE_DT, B.REF_REC_DT, B.DISCHARGE_DT,
        B.LOCATION, B.HOSPITAL, B.SERVICE, B.EPISODE_TEAM, B.CP, B.UR,
        B.EPISODE, B.ORD_SUB_CAT, B.ORD_ITEM, B.CONTACT_DT,
        B.DIRECT_HOURS + B.INDIRECT_HOURS,
        'Incorrect Order Item used'
    FROM {{ ref('rpt_community_health_fund_data') }}              AS B
    LEFT JOIN {{ ref('prep_ref_order_subcategory_mapping') }}     AS C
        ON B.ORD_SUB_CAT = C.ORDER_SUBCATEGORY_DESC
        AND C.REPORTING_TYPE_DESC = 'Community Health Program Data'
    WHERE C.ORDER_SUBCATEGORY_DESC IS NULL
      AND B.CONTACT_TYPE IN ('I', 'FE')
      AND B.REQUEST_STATUS = 'completed'
      AND (B.ORDER_STATUS IS NULL OR B.ORDER_STATUS != 'D/C (Discontinued)')

    UNION ALL

    SELECT
        B.PROGRAM_STREAM_DESC, B.EPISODE_DT, B.REF_REC_DT, B.DISCHARGE_DT,
        B.LOCATION, B.HOSPITAL, B.SERVICE, B.EPISODE_TEAM, B.CP, B.UR,
        B.EPISODE, B.ORD_SUB_CAT, B.ORD_ITEM, B.CONTACT_DT,
        B.DIRECT_HOURS + B.INDIRECT_HOURS,
        'Service Activity Type is Invalid'
    FROM {{ ref('rpt_community_health_fund_data') }}              AS B
    LEFT JOIN {{ ref('prep_ref_order_subcategory_mapping') }}     AS C
        ON B.ORD_SUB_CAT = C.ORDER_SUBCATEGORY_DESC
        AND C.REPORTING_TYPE_DESC = 'Community Health Program Data'
    WHERE C.ORDER_SUBCATEGORY_DESC IS NULL
      AND B.CONTACT_TYPE IN ('A', 'C', 'P', 'PS')
      AND B.REQUEST_STATUS = 'completed'
      AND (B.ORDER_STATUS IS NULL OR B.ORDER_STATUS != 'D/C (Discontinued)')
),

chsp_exceptions AS (
    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT,
        DIRECT_HOURS + INDIRECT_HOURS                     AS TOTAL_HRS,
        'Contact Date prior to referral Date'             AS ERROR
    FROM {{ ref('rpt_chsp_fund_data') }}
    WHERE REF_REC_DT > CONTACT_DT
      AND CONTACT_TYPE IN ('I', 'FE')

    UNION ALL

    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT,
        DIRECT_HOURS + INDIRECT_HOURS,
        'Contact Date after Discharge Date'
    FROM {{ ref('rpt_chsp_fund_data') }}
    WHERE DISCHARGE_DT < CONTACT_DT
      AND CONTACT_TYPE IN ('I', 'FE')

    UNION ALL

    SELECT
        B.PROGRAM_STREAM_DESC, B.EPISODE_DT, B.REF_REC_DT, B.DISCHARGE_DT,
        B.LOCATION, B.HOSPITAL, B.SERVICE, B.EPISODE_TEAM, B.CP, B.UR,
        B.EPISODE, B.ORD_SUB_CAT, B.ORD_ITEM, B.CONTACT_DT,
        B.DIRECT_HOURS + B.INDIRECT_HOURS,
        'Incorrect Order Item used'
    FROM {{ ref('rpt_chsp_fund_data') }}                          AS B
    LEFT JOIN {{ ref('prep_ref_order_subcategory_mapping') }}     AS C
        ON B.ORD_SUB_CAT = C.ORDER_SUBCATEGORY_DESC
        AND C.REPORTING_TYPE_DESC = 'DEX Service Type ID'
    WHERE C.ORDER_SUBCATEGORY_DESC IS NULL
      AND B.CONTACT_TYPE IN ('I', 'FE')

    UNION ALL

    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT,
        DIRECT_HOURS + INDIRECT_HOURS,
        'Service/order subcategory/Program stream used invalid'
    FROM {{ ref('rpt_chsp_fund_data') }}
    WHERE VALIDITY = 'Invalid'
      AND CONTACT_TYPE IN ('I', 'FE')

    UNION ALL

    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT,
        DIRECT_HOURS + INDIRECT_HOURS,
        'Contact Type P, PS or A is not valid for CHSP'
    FROM {{ ref('rpt_chsp_fund_data') }}
    WHERE CONTACT_TYPE NOT IN ('I', 'FE')

    UNION ALL

    SELECT
        CH.PROGRAM_STREAM_DESC, CH.EPISODE_DT, CH.REF_REC_DT, CH.DISCHARGE_DT,
        CH.LOCATION, CH.HOSPITAL, CH.SERVICE, CH.EPISODE_TEAM, CH.CP, CH.UR,
        CH.EPISODE, CH.ORD_SUB_CAT, CH.ORD_ITEM, CH.CONTACT_DT,
        CH.DIRECT_HOURS + CH.INDIRECT_HOURS,
        'Incorrect Episode Team / Program Stream'
    FROM {{ ref('rpt_chsp_fund_data') }}                          AS CH
    LEFT JOIN {{ ref('prep_ref_service_location_mapping') }}      AS LM
        ON CH.EPISODE_TEAM = LM.LOCATION_DESC
        AND LM.RPORTING_TYPE_DESC = 'DEX Outlet Activity ID'
    WHERE LM.LOCATION_DESC IS NULL
      AND CH.CONTACT_TYPE IN ('I', 'FE')
),

hacc_ndis_exceptions AS (
    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT,
        DIRECT_HRS                                        AS TOTAL_HRS,
        'Program Stream not valid for HACC NDIS Funding'  AS ERROR
    FROM {{ ref('rpt_hacc_ndis_fund_data') }}
    WHERE PROGRAM_STREAM_DESC NOT IN ('cbc - internal', 'Non Reportable')

    UNION ALL

    SELECT
        PROGRAM_STREAM_DESC, EPISODE_DT, REF_REC_DT, DISCHARGE_DT, LOCATION,
        HOSPITAL, SERVICE, EPISODE_TEAM, CP, UR, EPISODE,
        ORD_SUB_CAT, ORD_ITEM, CONTACT_DT, DIRECT_HRS,
        'Client does not meet HACC Age funding criteria'
    FROM {{ ref('rpt_hacc_ndis_fund_data') }}
    WHERE AGE_SPLIT = 'Commonwealth'
      AND PROGRAM_STREAM_DESC IN ('cbc - internal', 'Non Reportable')
)

SELECT
    PROGRAM_STREAM_DESC,
    EPISODE_DT,
    REF_REC_DT,
    DISCHARGE_DT,
    LOCATION,
    HOSPITAL,
    SERVICE,
    EPISODE_TEAM,
    CP,
    UR,
    EPISODE,
    ORD_SUB_CAT,
    ORD_ITEM,
    CONTACT_DT,
    TOTAL_HRS,
    ERROR

FROM (
    SELECT * FROM hacc_exceptions
    UNION ALL
    SELECT * FROM chp_exceptions
    UNION ALL
    SELECT * FROM chsp_exceptions
    UNION ALL
    SELECT * FROM hacc_ndis_exceptions
) AS all_exceptions