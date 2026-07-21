SELECT
    LOC.CODE                                              AS LOCATION_CODE,
    LOC.DESCRIPTION                                       AS LOCATION_DESC,
    NAT.MAPPED_VALUE                                      AS MAPPED_VALUE,
    NAT.REPORTING_TYPE_DR                                 AS NATC_REPORTING_TYPE_DR,
    RT.DESCRIPTION                                        AS REPTYPE_DESC

FROM {{ ref('prep_stg_trakcare_ct_loc') }}                AS LOC

INNER JOIN {{ ref('prep_stg_trakcare_pac_nationalcodes') }} AS NAT
    ON NAT.ACTUAL_VALUE = LOC.CODE
    AND NAT.TABLE_NAME = 'CT_Loc'
    AND NAT.DATE_TO IS NULL

INNER JOIN {{ ref('prep_stg_trakcare_pac_reportingtype') }} AS RT
    ON CAST(RT.ROW_ID AS VARCHAR) = CAST(NAT.REPORTING_TYPE_DR AS VARCHAR)
    AND RT.DATE_TO IS NULL

WHERE LOC.CODE IS NOT NULL