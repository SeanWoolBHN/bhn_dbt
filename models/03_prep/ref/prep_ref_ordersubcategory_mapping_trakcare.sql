SELECT
    IC.CODE                                               AS ARCIC_CODE,
    IC.DESCRIPTION                                        AS ARCIC_DESC,

    -- Parent category via self-join
    PARENT.CODE                                           AS CATEGORY,

    -- Program stream code via CT_NFMI_CATEGDEPART
    PROG.CODE                                             AS DEP_CODE,

    -- National codes fields
    NAT.ACTUAL_VALUE                                      AS NATC_ACTUAL_VALUE,
    NAT.MAPPED_VALUE                                      AS NATC_MAPPED_VALUE,
    NAT.REPORTING_TYPE_DR                                 AS NATC_REPORTING_TYPE_DR,

    -- Reporting type description
    RT.DESCRIPTION                                        AS REPTYPE_DESC,

    -- Date to from national codes
    NAT.DATE_TO                                           AS NATC_DATE_TO

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