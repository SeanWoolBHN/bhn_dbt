SELECT
    CTZIP_ROWID                                   AS ROW_ID,
    CAST(CTZIP_CODE AS TEXT)                      AS POSTCODE,
    NULLIF(TRIM(CTZIP_DESC), 'NULL')              AS CITY

FROM {{ ref('HIST_TRAKCARE_CT_ZIP') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')