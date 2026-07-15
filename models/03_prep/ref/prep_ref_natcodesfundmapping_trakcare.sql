SELECT DISTINCT
    DEP.CODE                                              AS DEP_CODE, --DEP_CODE
    CAT.CODE                                              AS NFMI_CODE,

    -- NFMI_Desc — with CHSP override from original SSIS logic
    CASE
        WHEN DEP.CODE = 'CHSP'
            THEN 'Commonwealth Home Support Program'
        ELSE CAT.DESCRIPTION
    END                                                   AS NFMI_DESC,--NRMI_DESC

    CAT.OWNER                                             AS NFMI_OWNER,

    -- ALT_SUBCODE — requires PAC_ReportingType, not yet in Snowflake
    NULL::VARCHAR                                         AS ALT_SUBCODE,

    -- SUB_DESC — requires CT_GovernSubcat via CAT.GOV_SUB_CATEG_DR, not yet in Snowflake
    NULL::VARCHAR                                         AS SUB_DESC,

    -- NATC columns — requires PAC_NationalCodes, not yet in Snowflake
    NULL::VARCHAR                                         AS NATC_TABLE_NAME,
    NULL::VARCHAR                                         AS NATC_FIELD_NAME,
    NULL::VARCHAR                                         AS NATC_ACTUAL_VALUE,
    NULL::VARCHAR                                         AS NATC_MAPPED_VALUE,

    -- ARCIC_DESC — requires PAC_NationalCodes join to ARC_ITEMCAT, not yet in Snowflake
    -- FVCC and IFAMVIO overrides also pending
    NULL::VARCHAR                                         AS ARCIC_DESC,
    NULL::VARCHAR                                         AS ARCIC_CODE

FROM {{ ref('prep_stg_trakcare_ct_nfmi_category') }}      AS CAT

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS DEP
    ON CAST(DEP.PAR_REF AS NUMBER(18,0)) = CAST(CAT.ROW_ID AS NUMBER(18,0))

WHERE CAT.DATE_TO IS NULL
  AND DEP.CODE IS NOT NULL