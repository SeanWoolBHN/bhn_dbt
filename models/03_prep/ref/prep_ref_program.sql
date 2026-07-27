SELECT
    -- Program stream code and description
    DEP.CODE                                            AS PROGRAM_STREAM_CODE,
    LTRIM(DEP.DESCRIPTION)                              AS PROGRAM_STREAM_DESC,
    -- Stream derived from program code
    CASE
        WHEN DEP.CODE LIKE 'HACC%'                      THEN 'HACC'
        WHEN DEP.CODE LIKE 'CHSP%'                      THEN 'CHSP'
        WHEN DEP.CODE IN ('AODTSCRC5', 'AD50-100')      THEN 'CRC'
        WHEN DEP.CODE IN ('AODTSNRW5', 'AD11-100', 'AD11-116') THEN 'NRW'
        WHEN DEP.CODE IN ('AD20-100', 'AODTSCOU5')      THEN 'Counselling'
        WHEN DEP.CODE IN ('AD80-100')                   THEN 'Intake - General'
        WHEN DEP.CODE LIKE 'CHPD%'                      THEN 'Community Health Program'
        WHEN DEP.CODE LIKE 'FV%'                        THEN 'Family Violence'
        WHEN DEP.CODE LIKE 'NDIS%'                      THEN 'NDIS'
        WHEN DEP.CODE LIKE 'SFC%'                       THEN 'Support for Carers'
        WHEN DEP.CODE LIKE 'CMH%'
          OR DEP.CODE LIKE 'SEMPHN%'                    THEN 'Mental Health'
        WHEN DEP.CODE LIKE 'HCP%'                       THEN 'Home Care Package'
        ELSE LTRIM(DEP.DESCRIPTION)
    END                                                 AS STREAM_NAME,

    -- Government category code
    CAT.CODE                                            AS GOVERNMENT_CATEGORY_CODE,

    -- Funding body derived from program code
    CASE
        WHEN DEP.CODE LIKE 'HACC%'                      THEN 'State + Commonwealth'
        WHEN DEP.CODE LIKE 'CHSP%'                      THEN 'Commonwealth'
        WHEN DEP.CODE LIKE 'NDIS%'                      THEN 'NDIS'
        WHEN DEP.CODE LIKE 'CHPD%'                      THEN 'State'
        WHEN DEP.CODE LIKE 'FV%'                        THEN 'State'
        WHEN DEP.CODE LIKE 'SFC%'                       THEN 'State'
        WHEN DEP.CODE LIKE 'CMH%'
          OR DEP.CODE LIKE 'SEMPHN%'                    THEN 'Commonwealth'
        WHEN DEP.CODE LIKE 'AD%'
          OR DEP.CODE LIKE 'AOD%'                       THEN 'State'
        WHEN DEP.CODE LIKE 'HCP%'                       THEN 'Commonwealth'
        WHEN DEP.CODE = 'Worksafe'                      THEN 'WorkSafe Victoria'
        ELSE 'State'
    END                                                 AS FUNDING_BODY,

    -- Funding type derived
    CASE
        WHEN DEP.CODE LIKE 'NDIS%'                      THEN 'Activity'
        WHEN DEP.CODE LIKE 'HCP%'                       THEN 'Activity'
        WHEN DEP.CODE = 'Worksafe'                      THEN 'FeeForService'
        ELSE 'Block'
    END                                                 AS FUNDING_TYPE,

    -- Reporting system derived
    CASE
        WHEN CAT.DESCRIPTION ILIKE '%alcohol%'
          OR CAT.DESCRIPTION ILIKE '%drug%'
          OR DEP.CODE LIKE 'AD%'
          OR DEP.CODE LIKE 'AOD%'                       THEN 'VADC'
        WHEN DEP.CODE LIKE 'CHSP%'                      THEN 'DEX'
        WHEN DEP.CODE LIKE 'HACC%'                      THEN 'DEX'
        WHEN DEP.CODE LIKE 'NDIS%'                      THEN 'NDIS'
        WHEN DEP.CODE LIKE 'FV%'                        THEN 'IRIS'
        WHEN DEP.CODE LIKE 'CMH%'
          OR DEP.CODE LIKE 'SEMPHN%'                    THEN 'IRIS'
        ELSE 'Internal'
    END                                                 AS REPORTING_SYSTEM,

    -- Age split applies — HACC only
    CASE
        WHEN DEP.CODE LIKE 'HACC%' THEN TRUE
        ELSE FALSE
    END                                                 AS IS_AGE_SPLIT_APPLIES

FROM {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS DEP

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_category') }} AS CAT
    ON CAST(DEP.PAR_REF AS NUMBER) = CAST(CAT.ROW_ID AS NUMBER)

WHERE DEP.CODE IS NOT NULL
  AND DEP.DATE_TO IS NULL