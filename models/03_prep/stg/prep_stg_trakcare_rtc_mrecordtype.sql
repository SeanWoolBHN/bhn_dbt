SELECT
    TYP_ROWID                                                             AS ROW_ID,
    NULLIF(TRIM(TYP_SUF), 'NULL')                                         AS SUFFIX,
    NULLIF(TRIM(TYP_CODE), 'NULL')                                        AS CODE,
    NULLIF(TRIM(TYP_DESC), 'NULL')                                        AS DESCRIPTION,
    NULLIF(TRIM(TYP_PREF), 'NULL')                                        AS PREFIX,
    NULLIF(TRIM(TYP_OWNER), 'NULL')                                       AS OWNER,
    TYP_DATETO                                                            AS DATE_TO,
    TYP_LENGTH                                                            AS LENGTH,
    TYP_COUNTER                                                           AS COUNTER,
    TYP_CTLOC_DR                                                          AS CT_LOC_DR,
    TYP_DATEFROM                                                          AS DATE_FROM,
    NULLIF(TRIM(TYP_MRNOPOLICY), 'NULL')                                  AS MR_NO_POLICY,
    NULLIF(TRIM(TYP_VOLUMETYPE), 'NULL')                                  AS VOLUME_TYPE,
    TYP_CREATEDDATE                                                       AS CREATED_DATE,
    TYP_CREATEDTIME                                                       AS CREATED_TIME,
    TYP_UPDATEDDATE                                                       AS UPDATED_DATE,
    TYP_UPDATEDTIME                                                       AS UPDATED_TIME,
    NULLIF(TRIM(TYP_CODETABLETAGS), 'NULL')                               AS CODE_TABLE_TAGS,
    TYP_CREATEDUSER_DR                                                    AS CREATED_USER_DR,
    TYP_UPDATEDUSER_DR                                                    AS UPDATED_USER_DR,
    NULLIF(TRIM(TYP_NOTCREATEVOLUME), 'NULL')                             AS NOT_CREATE_VOLUME,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_RTC_MRECORDTYPE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')