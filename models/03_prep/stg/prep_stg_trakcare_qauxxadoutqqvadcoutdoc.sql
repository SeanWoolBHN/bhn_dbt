SELECT
    VADC_OUT_DOC_KEY,
    NULLIF(TRIM(ID), 'NULL')                                              AS VADC_OUT_ID,
    CHILDSUB                                                              AS CHILD_SUB,
    QUESPARREFDR                                                          AS QUES_PAR_REF_DR,
    NULLIF(TRIM(QVADCOUTDOCQ1), 'NULL')                                   AS VADC_OUT_DOC_Q1,
    QVADCOUTDOCQ2                                                         AS VADC_OUT_DOC_Q2,
    NULLIF(TRIM(QVADCOUTDOCQ3), 'NULL')                                   AS VADC_OUT_DOC_Q3,
    NULLIF(TRIM(QVADCOUTDOCQ4), 'NULL')                                   AS VADC_OUT_DOC_Q4,
    NULLIF(TRIM(QVADCOUTDOCQ5), 'NULL')                                   AS VADC_OUT_DOC_Q5,
    QVADCOUTDOCQ6                                                         AS VADC_OUT_DOC_Q6,
    NULLIF(TRIM(QVADCOUTDOCQ7), 'NULL')                                   AS VADC_OUT_DOC_Q7,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_QAUXXADOUTQQVADCOUTDOC') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')