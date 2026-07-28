SELECT
    VADC_PROG_REF_KEY,
    NULLIF(TRIM(ID), 'NULL')                                              AS VADC_ID,
    CHILDSUB                                                              AS CHILD_SUB,
    QUESPARREFDR                                                          AS QUES_PAR_REF_DR,
    QVADCPROGREFQ1                                                        AS VADC_PROG_REF_Q1,
    NULLIF(TRIM(QVADCPROGREFQ2), 'NULL')                                  AS VADC_PROG_REF_Q2,
    QVADCPROGREFQ3                                                        AS VADC_PROG_REF_Q3,
    NULLIF(TRIM(QVADCPROGREFQ4), 'NULL')                                  AS VADC_PROG_REF_Q4,
    NULLIF(TRIM(QVADCPROGREFQ5), 'NULL')                                  AS VADC_PROG_REF_Q5,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_QAUXXADVADCQQVADCPROGREF') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')