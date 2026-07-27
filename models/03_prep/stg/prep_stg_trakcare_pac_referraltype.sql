SELECT
    REFT_ROWID                                                            AS ROW_ID,
    NULLIF(TRIM(REFT_CODE), 'NULL')                                       AS CODE,
    NULLIF(TRIM(REFT_DESC), 'NULL')                                       AS DESCRIPTION,
    NULLIF(TRIM(REFT_NATIONALCODE), 'NULL')                               AS NATIONAL_CODE,
    NULLIF(TRIM(REFT_REFERRALLENGTH), 'NULL')                             AS REFERRAL_LENGTH,
    NULLIF(TRIM(REFT_REFERRALPERIOD), 'NULL')                             AS REFERRAL_PERIOD,
    NULLIF(TRIM(REFT_REFSTDATEAPPTDATE), 'NULL')                          AS REF_START_DATE_APPT_DATE,
    NULLIF(TRIM(REFT_OWNER), 'NULL')                                      AS OWNER,
    NULLIF(TRIM(REFT_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    NULLIF(TRIM(REFT_SUBREGION_DR), 'NULL')                               AS SUB_REGION_DR,
    TRY_TO_DATE(NULLIF(TRIM(REFT_DATEFROM), 'NULL'))                      AS DATE_FROM,
    TRY_TO_DATE(NULLIF(TRIM(REFT_DATETO), 'NULL'))                        AS DATE_TO,
    TRY_TO_DATE(NULLIF(TRIM(REFT_CREATEDDATE), 'NULL'))                   AS CREATED_DATE,
    NULLIF(TRIM(REFT_CREATEDTIME), 'NULL')                                AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(REFT_CREATEDUSER_DR), 'NULL'), 18, 6)       AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(REFT_UPDATEDDATE), 'NULL'))                   AS UPDATED_DATE,
    NULLIF(TRIM(REFT_UPDATEDTIME), 'NULL')                                AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(REFT_UPDATEDUSER_DR), 'NULL'), 18, 6)       AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_PAC_REFERRALTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')