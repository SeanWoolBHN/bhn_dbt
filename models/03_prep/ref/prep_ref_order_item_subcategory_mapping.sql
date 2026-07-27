SELECT
    IC.ROW_ID                                             AS ORDER_SUBCATEGORY_ID,
    IC.CODE                                               AS ORDER_SUBCATEGORY,
    IC.DESCRIPTION                                        AS ORDER_SUBCATEGORY_DESC,
    IM.CODE                                               AS ORDER_ITEM_CODE,
    IM.DESCRIPTION                                        AS ORDER_ITEM_DESC,
    PROG.CODE                                             AS DEPARTMENT_CODE

FROM {{ ref('prep_stg_trakcare_arc_itmmast') }}           AS IM

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC
    ON CAST(IM.ITEM_CAT_DR AS NUMBER(18,0)) = IC.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS PROG
    ON CAST(IC.ORD_CAT_DR AS NUMBER(18,0)) = CAST(PROG.CHILD_SUB AS NUMBER(18,0))

WHERE IM.CODE IS NOT NULL
  AND IM.ROW_ID IS NOT NULL