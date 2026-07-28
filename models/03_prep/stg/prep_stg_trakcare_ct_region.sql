SELECT
    CTRG_ROWID                                                            AS ROW_ID,
    NULLIF(TRIM(CTRG_CODE), 'NULL')                                       AS CODE,
    NULLIF(TRIM(CTRG_DESC), 'NULL')                                       AS DESCRIPTION,
    NULLIF(TRIM(CTRG_RCFLAG), 'NULL')                                     AS RC_FLAG,
    TRY_TO_NUMBER(NULLIF(TRIM(CTRG_COUNTRY_DR), 'NULL'), 18, 6)           AS COUNTRY_DR,
    NULLIF(TRIM(CTRG_OWNER), 'NULL')                                      AS OWNER,
    NULLIF(TRIM(CTRG_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(CTRG_CREATEDDATE), 'NULL'))                   AS CREATED_DATE,
    NULLIF(TRIM(CTRG_CREATEDTIME), 'NULL')                                AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CTRG_CREATEDUSER_DR), 'NULL'), 18, 6)       AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(CTRG_UPDATEDDATE), 'NULL'))                   AS UPDATED_DATE,
    NULLIF(TRIM(CTRG_UPDATEDTIME), 'NULL')                                AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(CTRG_UPDATEDUSER_DR), 'NULL'), 18, 6)       AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_CT_REGION') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')