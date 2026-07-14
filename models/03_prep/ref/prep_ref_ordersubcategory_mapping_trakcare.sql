-- ============================================================
-- PREP_REF_ORDERSUBCATEGORY_MAPPING_TRAKCARE
-- Replaces: dbo.OrderSubcategory_Mapping SSIS table
-- Grain: one row per order subcategory
-- Source: ARC_ITEMCAT only (self-join for parent category)
-- ============================================================

SELECT
    IC.ROW_ID                                             AS SUBCAT_ROW_ID,
    IC.CODE                                               AS ORD_SUB_CAT_CODE,
    IC.DESCRIPTION                                        AS ORD_SUB_CAT_DESC,
    IC.DATE_FROM                                          AS DATE_FROM,
    IC.DATE_TO                                            AS DATE_TO,
    IC.ORD_CAT_DR                                         AS PARENT_CAT_DR,
    PARENT.CODE                                           AS PARENT_CAT_CODE,
    PARENT.DESCRIPTION                                    AS PARENT_CAT_DESC,
    IC.ORDER_TYPE                                         AS ORDER_TYPE,
    IC.BILLING_TYPE                                       AS BILLING_TYPE,
    IC.IS_TEST                                            AS IS_TEST

FROM {{ ref('prep_stg_trakcare_arc_itemcat') }}           AS IC

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS PARENT
    ON CAST(IC.ORD_CAT_DR AS NUMBER(18,0)) = CAST(PARENT.ROW_ID AS NUMBER(18,0))

WHERE IC.CODE IS NOT NULL
  AND IC.DATE_TO IS NULL