SELECT
    CO.CONTACT_DATE                                       AS CONTACT_DT,
    CL.NDIS_NUMBER                                        AS NDIS_NUMBER,
    CL.DOB,
    CL.AGE,
    CO.UR,
    CO.EPISODE_ID                                         AS EPISODE,
    CO.REQUEST_STATUS,
    -- Triple CP coalesce per SSIS: isnull(isnull(isnull(c.[CP],EpisodeCP),a.CP),'Unknown')
    COALESCE(
        NULLIF(CO.CP, ''),
        NULLIF(EP.EPISODE_CP, ''),
        NULLIF(AP.CARE_PROVIDER, ''),
        'Unknown'
    )                                                     AS CP,
    CO.LOCATION,
    CO.HOSPITAL,
    -- Raw minutes per SSIS (Direct, Indirect, Travel are minutes not hours)
    CO.DIRECT_MINUTES                                     AS DIRECT,
    CO.INDIRECT_MINUTES                                   AS INDIRECT,
    CO.TRAVEL_MINUTES                                     AS TRAVEL,
    -- TotalHrs = (Direct + Indirect) / 60 per SSIS Part 1
    (CO.DIRECT_MINUTES + CO.INDIRECT_MINUTES) / 60        AS TOTAL_HRS,
    CO.PAYOR,
    CO.PLAN,
    CO.ORD_ITEM,
    CO.OEORDI_REF,
    CO.INTERVENTIONS,
    CO.ORD_SUB_CAT,
    CO.PROGRAM_STREAM_CODE,
    CO.PROGRAM_STREAM_DESC,
    CO.COST,
    CO.UNIT_PRICE,
    -- ClaimType per SSIS
    CASE
        WHEN COALESCE(AP.APPOINTMENT_STATUS_REF, 'N') = 'N'
            THEN 'CANC'
        WHEN CO.ORD_ITEM ILIKE 'NDIS Requested Report%'
            THEN 'REPW'
        ELSE ''
    END                                                   AS CLAIM_TYPE

FROM {{ ref('prep_model_contact') }}                      AS CO

INNER JOIN {{ ref('prep_model_client') }}          AS CL
    ON CO.UR = CL.UR

INNER JOIN {{ ref('prep_model_episode') }}                AS EP
    ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

LEFT JOIN {{ ref('prep_model_appointment') }}             AS AP
    ON AP.OEORDI_REF = CO.OEORDI_REF

WHERE CO.AUXIT_CODE ILIKE '%NDI%'
  AND CO.AUXIT_CODE != 'NDISNON'
  AND CO.PLAN NOT IN ('NDIS Non Billable')
  AND CO.REQUEST_STATUS = 'Completed'
  AND COALESCE(AP.APPOINTMENT_STATUS_REF, 'N') != 'T'
  AND CL.NDIS_NUMBER IS NOT NULL

UNION ALL

-- Part 2: Travel contacts — TotalHrs = (Indirect + Travel) / 60 per SSIS
SELECT
    CO.CONTACT_DATE                                       AS CONTACT_DT,
    CL.NDIS_NUMBER                                        AS NDIS_NUMBER,
    CL.DOB,
    CL.AGE,
    CO.UR,
    CO.EPISODE_ID                                         AS EPISODE,
    CO.REQUEST_STATUS,
    -- Double CP coalesce per SSIS Part 2: isnull(isnull(c.[CP],EpisodeCP),'Unknown')
    COALESCE(
        NULLIF(CO.CP, ''),
        NULLIF(EP.EPISODE_CP, ''),
        'Unknown'
    )                                                     AS CP,
    CO.LOCATION,
    CO.HOSPITAL,
    CO.DIRECT_MINUTES                                     AS DIRECT,
    CO.INDIRECT_MINUTES                                   AS INDIRECT,
    CO.TRAVEL_MINUTES                                     AS TRAVEL,
    -- TotalHrs = (Indirect + Travel) / 60 per SSIS Part 2
    (CO.INDIRECT_MINUTES + CO.TRAVEL_MINUTES) / 60        AS TOTAL_HRS,
    CO.PAYOR,
    CO.PLAN,
    CO.ORD_ITEM,
    CO.OEORDI_REF,
    CO.INTERVENTIONS,
    CO.ORD_SUB_CAT,
    CO.PROGRAM_STREAM_CODE,
    CO.PROGRAM_STREAM_DESC,
    CO.COST,
    CO.UNIT_PRICE,
    'TRAN'                                                AS CLAIM_TYPE

FROM {{ ref('prep_model_contact') }}                      AS CO

INNER JOIN {{ ref('prep_model_client') }}          AS CL
    ON CO.UR = CL.UR

INNER JOIN {{ ref('prep_model_episode') }}                AS EP
    ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

WHERE CO.AUXIT_CODE ILIKE '%NDI%'
  AND CO.AUXIT_CODE != 'NDISNON'
  AND CO.PLAN NOT IN ('NDIS Non Billable')
  AND CO.REQUEST_STATUS = 'Completed'
  AND CO.TRAVEL_MINUTES > 0
  AND CL.NDIS_NUMBER IS NOT NULL