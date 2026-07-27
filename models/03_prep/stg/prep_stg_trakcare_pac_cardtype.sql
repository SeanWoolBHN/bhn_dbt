SELECT
    CARD_ROWID                                                            AS ROW_ID,
    CARD_CODE                                                             AS CODE,
    NULLIF(TRIM(CARD_DESC), 'NULL')                                       AS DESCRIPTION,
    CARD_DATEFROM                                                         AS DATE_FROM,
    NULLIF(TRIM(CARD_DATETO), 'NULL')                                     AS DATE_TO,
    NULLIF(TRIM(CARD_OWNER), 'NULL')                                      AS OWNER,
    NULLIF(TRIM(CARD_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(CARD_CREATEDDATE), 'NULL'))                   AS CREATED_DATE,
    NULLIF(TRIM(CARD_CREATEDTIME), 'NULL')                                AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CARD_CREATEDUSER_DR), 'NULL'), 18, 6)       AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(CARD_UPDATEDDATE), 'NULL'))                   AS UPDATED_DATE,
    NULLIF(TRIM(CARD_UPDATEDTIME), 'NULL')                                AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CARD_UPDATEDUSER_DR), 'NULL'), 18, 6)       AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_CARDTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')