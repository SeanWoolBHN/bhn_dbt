SELECT
    OEORD_ROWID                                           AS ROW_ID,
    OEORD_DATE                                            AS ORDER_DATE,
    OEORD_TIME                                            AS ORDER_TIME,
    OEORD_ADM_DR                                          AS ADM_DR,
    OEORD_ROWID1                                          AS ROW_ID_1,
    NULLIF(TRIM(OEORD_ARCOP_DR), 'NULL')                  AS ARCOP_DR,
    NULLIF(TRIM(OEORD_OEOTC_DR), 'NULL')                  AS OEOTC_DR,
    NULLIF(TRIM(OEORD_DOCTOR_DR), 'NULL')                 AS DOCTOR_DR,
    OEORD_SUNDRYDEBTOR_DR                                 AS SUNDRY_DEBTOR_DR,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_OE_ORDER') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')