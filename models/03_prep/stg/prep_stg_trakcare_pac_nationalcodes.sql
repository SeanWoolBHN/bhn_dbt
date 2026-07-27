SELECT
    NATC_ROWID                                                            AS ROW_ID,
    NATC_DATEFROM                                                         AS DATE_FROM,
    NATC_DATETO                                                           AS DATE_TO,
    NULLIF(TRIM(NATC_TABLE_DR), 'NULL')                                   AS TABLE_DR,
    NULLIF(TRIM(NATC_TABLENAME), 'NULL')                                  AS TABLE_NAME,
    NULLIF(TRIM(NATC_TABLEFIELD_DR), 'NULL')                              AS TABLE_FIELD_DR,
    NULLIF(TRIM(NATC_FIELDNAME), 'NULL')                                  AS FIELD_NAME,
    NULLIF(TRIM(NATC_ACTUALVALUE), 'NULL')                                AS ACTUAL_VALUE,
    NULLIF(TRIM(NATC_MAPPEDVALUE), 'NULL')                                AS MAPPED_VALUE,
    NULLIF(TRIM(NATC_REPORTINGTYPE_DR), 'NULL')                           AS REPORTING_TYPE_DR,
    NULLIF(TRIM(NATC_NODISPLAYONWEB), 'NULL')                             AS NO_DISPLAY_ON_WEB,
    NULLIF(TRIM(NATC_OWNER), 'NULL')                                      AS OWNER,
    NULLIF(TRIM(NATC_CODETABLETAGS), 'NULL')                              AS CODE_TABLE_TAGS,
    TRY_TO_DATE(NULLIF(TRIM(NATC_CREATEDDATE), 'NULL'))                   AS CREATED_DATE,
    NULLIF(TRIM(NATC_CREATEDTIME), 'NULL')                                AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(NATC_CREATEDUSER_DR), 'NULL'), 18, 6)       AS CREATED_USER_DR,
    NATC_UPDATEDDATE                                                      AS UPDATED_DATE,
    NATC_UPDATEDTIME                                                      AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(NATC_UPDATEDUSER_DR), 'NULL'), 18, 6)       AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_PAC_NATIONALCODES') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')