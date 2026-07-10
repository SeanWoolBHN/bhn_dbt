SELECT
    -- ── Surrogate keys (placeholders) ──────────────────────────────
    'ADS_DRUG_KEY'                                        AS ADS_DRUG_KEY,
    'ADS_OUTCOME_KEY'                                     AS ADS_OUTCOME_KEY,
    'ADS_EPISODE_KEY'                                     AS ADS_EPISODE_KEY,

    -- ── Natural keys ────────────────────────────────────────────────
    DOC.VADC_OUT_DOC_KEY                                  AS VADC_OUT_DOC_KEY,
    DOC.VADC_OUT_ID                                       AS ADS_OUTCOME_ID_RAW,
    DOC.QUES_PAR_REF_DR                                   AS PARENT_OUTCOME_DR_RAW,
    DOC.CHILD_SUB                                         AS CHILD_SUB,

    -- ── Drug of concern fields ──────────────────────────────────────
    DOC.VADC_OUT_DOC_Q1                                   AS DRUG_TYPE_CODE,
    DOC.VADC_OUT_DOC_Q2                                   AS USE_FREQUENCY,
    DOC.VADC_OUT_DOC_Q3                                   AS METHOD_OF_USE,
    DOC.VADC_OUT_DOC_Q4                                   AS IS_PRINCIPAL_DRUG,
    DOC.VADC_OUT_DOC_Q5                                   AS AGE_OF_FIRST_USE,
    DOC.VADC_OUT_DOC_Q6                                   AS INJECTION_FLAG,
    DOC.VADC_OUT_DOC_Q7                                   AS ADDITIONAL_FLAGS,

    -- ── Source system ───────────────────────────────────────────────
    'TRAKCARE'                                            AS SOURCE_SYSTEM

FROM {{ ref('prep_stg_trakcare_qauxxadoutqqvadcoutdoc') }} AS DOC

WHERE DOC.VADC_OUT_ID IS NOT NULL