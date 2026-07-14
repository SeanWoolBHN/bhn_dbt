SELECT
    DEP.CODE                                              AS DEP_CODE,
    LTRIM(DEP.DESCRIPTION)                                AS DEP_DESC,
    CAT.CODE                                              AS NFMI_CODE,
    CAT.DESCRIPTION                                       AS NFMI_DESC,
    DEP.PAR_REF                                           AS PAR_REF,
    DEP.CHILD_SUB                                         AS CHILD_SUB

FROM {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }}   AS DEP

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_category') }} AS CAT
    ON CAST(DEP.PAR_REF AS NUMBER(18,0)) = CAST(CAT.ROW_ID AS NUMBER(18,0))

WHERE DEP.CODE IS NOT NULL
  AND DEP.DATE_TO IS NULL