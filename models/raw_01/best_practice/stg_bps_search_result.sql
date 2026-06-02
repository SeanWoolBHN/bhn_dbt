-- models/staging/stg_bps_search_result.sql

WITH source AS (
    SELECT * FROM {{ source('raw_best_practise', 'BPS_SEARCH_RESULT') }}
),

cleaned AS (
    SELECT
        -- Primary Key
        INTERNALID                                              AS internal_id,

        -- Name Fields
        TRIM(NULLIF(SURNAME, ''))                              AS surname,
        TRIM(NULLIF(FIRSTNAME, ''))                            AS first_name,
        TRIM(NULLIF(MIDDLENAME, ''))                           AS middle_name,
        TRIM(NULLIF(PREFERREDNAME, ''))                        AS preferred_name,
        TRIM(NULLIF(TITLE, ''))                                AS title,

        -- Address Fields
        TRIM(NULLIF(ADDRESS1, ''))                             AS address_line_1,
        TRIM(NULLIF(ADDRESS2, ''))                             AS address_line_2,
        TRIM(NULLIF(CITY, ''))                                 AS city,
        LPAD(CAST(POSTCODE AS VARCHAR), 4, '0')                AS postcode,
        TRIM(NULLIF(FULLADDRESS, ''))                          AS full_address,

        -- Demographics
        TRY_TO_DATE(DOB, 'DD/MM/YY')                        AS date_of_birth,
        TRY_CAST(AGE AS NUMBER)                                AS age,
        TRIM(NULLIF(SEX, ''))                                  AS sex,

        -- Medicare
        CAST(MEDICARENO AS VARCHAR)                            AS medicare_number,
        CAST(MEDICARELINENO AS VARCHAR)                        AS medicare_line_number,
        TRY_TO_DATE(MEDICAREEXPIRY, 'MM/YYYY')                 AS medicare_expiry_date,

        -- Reference Numbers
        TRIM(NULLIF(RECORDNO, ''))                             AS record_number,
        TRIM(NULLIF(PENSIONNO, ''))                            AS pension_number,
        TRIM(NULLIF(DVANO, ''))                                AS dva_number,

        -- Contact
        REGEXP_REPLACE(HOMEPHONE, '[^0-9]', '')                AS home_phone,
        REGEXP_REPLACE(WORKPHONE, '[^0-9]', '')                AS work_phone,
        REGEXP_REPLACE(MOBILEPHONE, '[^0-9]', '')              AS mobile_phone,
        TRIM(LOWER(NULLIF(EMAIL, '')))                         AS email,

        -- Metadata
        CURRENT_TIMESTAMP()                                    AS _stg_loaded_at

    FROM source
)

SELECT * FROM cleaned