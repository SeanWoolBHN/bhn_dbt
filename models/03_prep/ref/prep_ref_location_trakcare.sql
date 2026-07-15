SELECT
    LOC.CODE                                              AS LOCATION_CODE,
    LOC.DESCRIPTION                                       AS LOCATION_DESC,

    -- From PAC_NationalCodes — not yet in Snowflake
    NULL::VARCHAR                                         AS MAPPED_VALUE,
    NULL::NUMBER                                          AS NATC_REPORTING_TYPE_DR,

    -- From PAC_ReportingType — not yet in Snowflake
    NULL::VARCHAR                                         AS REPTYPE_DESC,

FROM {{ ref('prep_stg_trakcare_ct_loc') }}                AS LOC

-- PAC_NationalCodes join — pending
-- INNER JOIN PAC_NationalCodes AS NAT
--     ON NAT.NATC_ACTUAL_VALUE = LOC.CODE
--     AND NAT.NATC_TABLE_NAME = 'CT_LOC'
--     AND NAT.NATC_DATE_TO IS NULL

-- PAC_ReportingType join — pending
-- INNER JOIN PAC_ReportingType AS RT
--     ON RT.REPTYPE_ROWID = NAT.NATC_REPORTING_TYPE_DR
--     AND RT.REPTYPE_DATE_TO IS NULL

WHERE LOC.CODE IS NOT NULL