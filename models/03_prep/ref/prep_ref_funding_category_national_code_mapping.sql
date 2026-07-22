WITH reporting_type_by_codetabletag AS (
    -- Pre-compute the TOP 1 reporting type code per CODE_TABLE_TAGS
    -- replaces the correlated subquery in the original SSIS CASE logic
    SELECT
        CODE_TABLE_TAGS,
        CODE,
        ROW_NUMBER() OVER (
            PARTITION BY CODE_TABLE_TAGS
            ORDER BY ROW_ID
        ) AS RN
    FROM {{ ref('prep_stg_trakcare_pac_reportingtype') }}
    WHERE DATE_TO IS NULL
      AND CODE_TABLE_TAGS IS NOT NULL
),

rt_tag_lookup AS (
    SELECT CODE_TABLE_TAGS, CODE
    FROM reporting_type_by_codetabletag
    WHERE RN = 1
),

-- Pre-compute the resolved GOVERNMENT_SUBCATEGORY_CODE per NFMI_CATEGORY row
-- to avoid repeating the CASE in both SELECT and JOIN
nfmi_with_altsubcode AS (
    SELECT
        CAT.ROW_ID,
        CAT.CODE,
        CAT.DESCRIPTION,
        CAT.OWNER,
        CAT.CODE_TABLE_TAGS,
        CAT.GOV_SUB_CATEG_DR,
        CAT.DATE_TO,
        GOV.CODE                                          AS GOV_CODE,
        GOV.DESCRIPTION                                   AS GOV_DESC,
        CASE
            WHEN CAT.CODE = 'CHSP'
                THEN 'AUXXDEXSERVICETYPEID'
            WHEN GOV.CODE = 'QDC'
                THEN 'QDC1'
            WHEN CAT.CODE_TABLE_TAGS IS NULL
                THEN COALESCE(GOV.CODE, CAT.CODE)
            ELSE RTT.CODE
        END                                               AS GOVERNMENT_SUBCATEGORY_CODE
    FROM {{ ref('prep_stg_trakcare_ct_nfmi_category') }} AS CAT
    LEFT JOIN {{ ref('prep_stg_trakcare_ct_governsubcat') }} AS GOV
        ON CAST(GOV.ROW_ID AS VARCHAR) = CAST(CAT.GOV_SUB_CATEG_DR AS VARCHAR)
    LEFT JOIN rt_tag_lookup AS RTT
        ON RTT.CODE_TABLE_TAGS = CAT.CODE_TABLE_TAGS
    WHERE CAT.DATE_TO IS NULL
)

SELECT DISTINCT
    DEP.CODE                                              AS DEPARTMENT_CODE,
    NFA.CODE                                              AS FUNDING_CATEGORY_CODE,

    -- FUNDING_CATEGORY_DESC with CHSP override
    CASE
        WHEN DEP.CODE = 'CHSP'
            THEN 'Commonwealth Home Support Program'
        ELSE NFA.DESCRIPTION
    END                                                   AS FUNDING_CATEGORY_DESC,

    NFA.OWNER                                             AS FUNDING_CATEGORY_OWNER,
    NFA.GOVERNMENT_SUBCATEGORY_CODE                                       AS GOVERNMENT_SUBCATEGORY_CODE,
    NFA.GOV_DESC                                          AS GOVERNMENT_SUBCATEGORY_DESC,
    NAT.TABLE_NAME                                        AS NAITONAL_CODE_TABLE_NAME,
    NAT.FIELD_NAME                                        AS NATIONAL_CODE_FIELD_NAME,
    NAT.ACTUAL_VALUE                                      AS NATIONAL_CODE_ACTUAL_VALUE,
    NAT.MAPPED_VALUE                                      AS NATIONAL_CODE_MAPPED_VALUE,

    -- ITEM_CATEGORY_DESC with overrides
    CASE
        WHEN NFA.CODE = 'IFAMVIO'
            THEN 'IRIS Activity Type'
        WHEN DEP.CODE = 'FVCC'
            THEN 'Family Violence Corrections'
        ELSE OI.DESCRIPTION
    END                                                   AS ITEM_CATEGORY_DESC,

    OI.CODE                                               AS ITEM_CATEGORY_CODE

FROM nfmi_with_altsubcode                                 AS NFA

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS DEP
    ON CAST(DEP.PAR_REF AS NUMBER(18,0)) = CAST(NFA.ROW_ID AS NUMBER(18,0))

INNER JOIN {{ ref('prep_stg_trakcare_pac_reportingtype') }} AS RT
    ON RT.CODE = NFA.GOVERNMENT_SUBCATEGORY_CODE
    AND RT.DATE_TO IS NULL

LEFT JOIN {{ ref('prep_stg_trakcare_pac_nationalcodes') }} AS NAT
    ON CAST(NAT.REPORTING_TYPE_DR AS VARCHAR) = CAST(RT.ROW_ID AS VARCHAR)
    AND NAT.TABLE_NAME = 'ARC_ItemCat'
    AND NAT.DATE_TO IS NULL

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS OI
    ON OI.CODE = NAT.ACTUAL_VALUE