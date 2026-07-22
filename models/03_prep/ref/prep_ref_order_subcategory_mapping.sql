SELECT
    IC.CODE                                               AS ORDER_SUBCATEGORY,
    IC.DESCRIPTION                                        AS ORDER_SUBCATEGORY_DESC,

    -- Parent category via self-join
    PARENT.CODE                                           AS PARENT_CATEGORY_CODE,

    -- Program stream code via CT_NFMI_CATEGDEPART
    PROG.CODE                                             AS DEPARTMENT_CODE,

    -- National codes fields
    NAT.ACTUAL_VALUE                                      AS NATIONAL_CODE_ACTUAL_VALUE,
    NAT.MAPPED_VALUE                                      AS NATIONAL_CODE_MAPPED_VALUE,
    NAT.REPORTING_TYPE_DR                                 AS REPORTING_TYPE_ID,

    -- Reporting type description
    RT.DESCRIPTION                                        AS REPORTING_TYPE_DESC,

    -- Date to from national codes
    NAT.DATE_TO                                           AS NATIONAL_CODE_END_DATE

FROM {{ ref('prep_stg_trakcare_arc_itemcat') }}           AS IC

-- Parent category via self-join
LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS PARENT
    ON CAST(IC.ORD_CAT_DR AS NUMBER(18,0)) = PARENT.ROW_ID

-- Program stream via CT_NFMI_CATEGDEPART
LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS PROG
    ON CAST(IC.ORD_CAT_DR AS NUMBER(18,0)) = CAST(PROG.CHILD_SUB AS NUMBER(18,0))

-- National codes — filter to ARC_ItemCat table
INNER JOIN {{ ref('prep_stg_trakcare_pac_nationalcodes') }} AS NAT
    ON NAT.ACTUAL_VALUE = IC.CODE
    AND NAT.TABLE_NAME = 'ARC_ItemCat'
    AND NAT.DATE_TO IS NULL

-- Reporting type
INNER JOIN {{ ref('prep_stg_trakcare_pac_reportingtype') }} AS RT
    ON CAST(RT.ROW_ID AS VARCHAR) = CAST(NAT.REPORTING_TYPE_DR AS VARCHAR)
    AND RT.DATE_TO IS NULL

WHERE IC.CODE IS NOT NULL
  AND IC.DATE_TO IS NULL