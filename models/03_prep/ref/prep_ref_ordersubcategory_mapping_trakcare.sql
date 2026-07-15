SELECT
    IC.CODE                                               AS ARCIC_CODE,
    IC.DESCRIPTION                                        AS ARCIC_DESC,
    -- Parent category — via self-join on ORD_CAT_DR
    PARENT.CODE                                           AS CATEGORY,
    -- Program stream code — via CT_NFMI_CATEGDEPART
    PROG.CODE                                             AS DEP_CODE,
    -- Location mapping fields
    LM.NATC_ACTUAL_VALUE                                  AS NATC_ACTUAL_VALUE,
    LM.NATC_MAPPED_VALUE                                  AS NATC_MAPPED_VALUE,
    LM.REPORTING_TYPE_DR                                  AS NATC_REPORTING_TYPE_DR,
    LM.REPORTING_TYPE_DESC                                AS REPTYPE_DESC

FROM {{ ref('prep_stg_trakcare_arc_itemcat') }}           AS IC
-- Parent category via self-join
LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS PARENT
    ON CAST(IC.ORD_CAT_DR AS NUMBER(18,0)) = PARENT.ROW_ID
-- Program stream code via CT_NFMI_CATEGDEPART
LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS PROG
    ON CAST(IC.ORD_CAT_DR AS NUMBER(18,0)) = CAST(PROG.CHILD_SUB AS NUMBER(18,0))
-- Location mapping — join on ARCIC_CODE = NATC_ACTUAL_VALUE
LEFT JOIN {{ ref('prep_stg_reference_data_location_mapping') }} AS LM
    ON IC.CODE = LM.NATC_ACTUAL_VALUE

WHERE IC.CODE IS NOT NULL
  AND IC.DATE_TO IS NULL