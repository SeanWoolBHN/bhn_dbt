SELECT
    REFPRI_ROWID                                          AS ROW_ID,
    NULLIF(TRIM(REFPRI_CODE), 'NULL')                     AS CODE,
    NULLIF(TRIM(REFPRI_DESC), 'NULL')                     AS DESCRIPTION,
    NULLIF(TRIM(REFPRI_OWNER), 'NULL')                    AS OWNER,
    NULLIF(TRIM(REFPRI_CANCER), 'NULL')                   AS CANCER,
    REFPRI_DATETO                                         AS DATE_TO,
    REFPRI_DATEFROM                                       AS DATE_FROM,
    NULLIF(TRIM(REFPRI_ICONNAME), 'NULL')                 AS ICON_NAME,
    REFPRI_CREATEDDATE                                    AS CREATED_DATE,
    REFPRI_CREATEDTIME                                    AS CREATED_TIME,
    REFPRI_UPDATEDDATE                                    AS UPDATED_DATE,
    REFPRI_UPDATEDTIME                                    AS UPDATED_TIME,
    REFPRI_ICONPRIORITY                                   AS ICON_PRIORITY,
    NULLIF(TRIM(REFPRI_NATIONALCODE), 'NULL')             AS NATIONAL_CODE,
    NULLIF(TRIM(REFPRI_ADMISSIONTYPE), 'NULL')            AS ADMISSION_TYPE,
    NULLIF(TRIM(REFPRI_CODETABLETAGS), 'NULL')            AS CODE_TABLE_TAGS,
    REFPRI_CREATEDUSER_DR                                 AS CREATED_USER_DR,
    REFPRI_UPDATEDUSER_DR                                 AS UPDATED_USER_DR,
    REFPRI_MAXDAYSWAITAPPT                                AS MAX_DAYS_WAIT_APPT,
    _AIRBYTE_EXTRACTED_AT                                 AS AIRBYTE_EXTRACTED_TS
FROM {{ ref('HIST_TRAKCARE_PAC_REFERRALPRIORITY') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')