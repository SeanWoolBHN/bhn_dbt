SELECT
    IM.ROW_ID                                             AS ITEM_ROW_ID,
    IM.CODE                                               AS ORD_ITEM_CODE,
    IM.DESCRIPTION                                        AS ORD_ITEM_DESC,
    IM.SHORT_DESC                                         AS ORD_ITEM_SHORT_DESC,
    IC.ROW_ID                                             AS SUBCAT_ROW_ID,
    IC.CODE                                               AS ORD_SUB_CAT_CODE,
    IC.DESCRIPTION                                        AS ORD_SUB_CAT_DESC

FROM {{ ref('prep_stg_trakcare_arc_itmmast') }}           AS IM

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC
    ON CAST(IM.ITEM_CAT_DR AS NUMBER(18,0)) = CAST(IC.ROW_ID AS NUMBER(18,0))

WHERE IM.CODE IS NOT NULL
  AND IM.ROW_ID IS NOT NULL