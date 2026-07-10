SELECT
    NGO_ROWID                                                             AS ROW_ID,
    NULLIF(TRIM(NGO_CODE), 'NULL')                                        AS CODE,
    NULLIF(TRIM(NGO_DESC), 'NULL')                                        AS DESCRIPTION,
    NULLIF(TRIM(NGO_ADDRESS), 'NULL')                                     AS ADDRESS,
    NULLIF(TRIM(NGO_CITY_DR), 'NULL')                                     AS CITY_DR,
    NULLIF(TRIM(NGO_ZIP_DR), 'NULL')                                      AS ZIP_DR,
    NULLIF(TRIM(NGO_PROVINCE_DR), 'NULL')                                 AS PROVINCE_DR,
    NULLIF(TRIM(NGO_PHONE), 'NULL')                                       AS PHONE,
    NULLIF(TRIM(NGO_FAX), 'NULL')                                         AS FAX,
    LOWER(NULLIF(TRIM(NGO_EMAIL), 'NULL'))                                AS EMAIL,
    NULLIF(TRIM(NGO_CONTACTMETHOD), 'NULL')                               AS CONTACT_METHOD,
    NGO_DATEFROM                                                          AS DATE_FROM,
    NULLIF(TRIM(NGO_DATETO), 'NULL')                                      AS DATE_TO,
    NULLIF(TRIM(NGO_SCHOOL), 'NULL')                                      AS SCHOOL,
    NULLIF(TRIM(NGO_OWNER), 'NULL')                                       AS OWNER,
    NULLIF(TRIM(NGO_CODETABLETAGS), 'NULL')                               AS CODE_TABLE_TAGS,
    NULLIF(TRIM(NGO_PATHOLOGYPROVIDER), 'NULL')                           AS PATHOLOGY_PROVIDER,
    TRY_TO_DATE(NULLIF(TRIM(NGO_CREATEDDATE), 'NULL'))                    AS CREATED_DATE,
    NULLIF(TRIM(NGO_CREATEDTIME), 'NULL')                                 AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(NGO_CREATEDUSER_DR), 'NULL'), 18, 6)        AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(NGO_UPDATEDDATE), 'NULL'))                    AS UPDATED_DATE,
    NULLIF(TRIM(NGO_UPDATEDTIME), 'NULL')                                 AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(NGO_UPDATEDUSER_DR), 'NULL'), 18, 6)        AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_PAC_NONGOVORG') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')