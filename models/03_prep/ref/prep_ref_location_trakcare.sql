SELECT
    -- Keys
    'LOCATION_KEY'                                      AS LOCATION_KEY,
    'LEGACY_ORG_ID'                                     AS LEGACY_ORG_ID,
    'ORGANISATION_KEY'                                  AS ORGANISATION_KEY,

    -- Location code and description
    LOC.CODE                                            AS LOCATION_CODE,
    LOC.DESCRIPTION                                     AS LOCATION_DESC,

    -- Hospital/service category
    HOSP.DESCRIPTION                                    AS HOSPITAL,

    -- Episode team
    CASE
        WHEN LOC.TYPE IN ('TEAM', 'WARD', 'UNIT')
            THEN LOC.DESCRIPTION
        ELSE NULL
    END                                                 AS EPISODE_TEAM,

    -- Site
    CASE
        WHEN LOC.TYPE IN ('CLINIC', 'SITE', 'FACILITY')
            THEN LOC.DESCRIPTION
        ELSE LOC.DESCRIPTION
    END                                                 AS SITE,

    -- Mapped value from location mapping
    LM.NATC_MAPPED_VALUE                                AS MAPPED_VALUE,
    LM.REPORTING_TYPE_DESC                              AS REPORTING_TYPE,
    LM.CAMPUS                                           AS CAMPUS,

    -- Source system
    'TRAKCARE'                                          AS SOURCE_SYSTEM

FROM {{ ref('prep_stg_trakcare_ct_loc') }}              AS LOC

LEFT JOIN {{ ref('prep_stg_trakcare_ct_hospital') }}    AS HOSP
    ON LOC.HOSPITAL_DR = HOSP.ROW_ID

LEFT JOIN {{ ref('prep_stg_reference_data_location_mapping') }} AS LM
    ON LOC.CODE = LM.NATC_ACTUAL_VALUE

WHERE LOC.CODE IS NOT NULL