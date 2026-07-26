SELECT
    CONTVENUE_ROWID                                                       AS ROW_ID,
    NULLIF(TRIM(CONTVENUE_CODE), 'NULL')                                  AS CODE,
    NULLIF(TRIM(CONTVENUE_DESC), 'NULL')                                  AS DESCRIPTION,
    NULLIF(TRIM(CONTVENUE_OWNER), 'NULL')                                 AS OWNER,
    CONTVENUE_DATETO                                                      AS DATE_TO,
    CONTVENUE_DATEFROM                                                    AS DATE_FROM,
    CONTVENUE_CREATEDDATE                                                 AS CREATED_DATE,
    CONTVENUE_CREATEDTIME                                                 AS CREATED_TIME,
    CONTVENUE_UPDATEDDATE                                                 AS UPDATED_DATE,
    CONTVENUE_UPDATEDTIME                                                 AS UPDATED_TIME,
    NULLIF(TRIM(CONTVENUE_CODETABLETAGS), 'NULL')                         AS CODE_TABLE_TAGS,
    CONTVENUE_CREATEDUSER_DR                                              AS CREATED_USER_DR,
    CONTVENUE_UPDATEDUSER_DR                                              AS UPDATED_USER_DR,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_TRAKCARE_PAC_CONTVENUE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')