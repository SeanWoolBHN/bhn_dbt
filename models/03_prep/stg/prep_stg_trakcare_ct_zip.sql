SELECT
    CTZIP_ROWID                                   AS ROW_ID,
    CTZIP_CODE                                    AS CITY,
    NULLIF(TRIM(CTZIP_DESC), 'NULL')              AS POSTCODE

FROM {{ ref('HIST_TRAKCARE_CT_ZIP') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')