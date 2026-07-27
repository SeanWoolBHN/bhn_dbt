SELECT
    RFC_ROWID                                                             AS ROW_ID,
    NULLIF(TRIM(RFC_CODE), 'NULL')                                        AS CODE,
    NULLIF(TRIM(RFC_DESC), 'NULL')                                        AS DESCRIPTION,
    NULLIF(TRIM(RFC_INITIATOR), 'NULL')                                   AS INITIATOR,
    RFC_DATEFROM                                                          AS DATE_FROM,
    NULLIF(TRIM(RFC_DATETO), 'NULL')                                      AS DATE_TO,
    NULLIF(TRIM(RFC_DEFAULT), 'NULL')                                     AS DEFAULT,
    NULLIF(TRIM(RFC_ADMCANCELREASON_DR), 'NULL')                          AS ADM_CANCEL_REASON_DR,
    NULLIF(TRIM(RFC_REASONTOCHANGEOPWLTOREMOVED_DR), 'NULL')              AS REASON_TO_CHANGE_OP_WL_TO_REMOVED_DR,
    NULLIF(TRIM(RFC_OPWLSTATUSTOREINSTATE_DR), 'NULL')                    AS OP_WL_STATUS_TO_REINSTATE_DR,
    NULLIF(TRIM(RFC_RESETTTGCLOCK), 'NULL')                               AS RESET_TTG_CLOCK,
    NULLIF(TRIM(RFC_NATIONALCODE), 'NULL')                                AS NATIONAL_CODE,
    NULLIF(TRIM(RFC_OWNER), 'NULL')                                       AS OWNER,
    NULLIF(TRIM(RFC_CODETABLETAGS), 'NULL')                               AS CODE_TABLE_TAGS,
    NULLIF(TRIM(RFC_REMOVECONTACTREMINDERDATES), 'NULL')                  AS REMOVE_CONTACT_REMINDER_DATES,
    TRY_TO_DATE(NULLIF(TRIM(RFC_CREATEDDATE), 'NULL'))                    AS CREATED_DATE,
    NULLIF(TRIM(RFC_CREATEDTIME), 'NULL')                                 AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(RFC_CREATEDUSER_DR), 'NULL'), 18, 6)        AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(RFC_UPDATEDDATE), 'NULL'))                    AS UPDATED_DATE,
    NULLIF(TRIM(RFC_UPDATEDTIME), 'NULL')                                 AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(RFC_UPDATEDUSER_DR), 'NULL'), 18, 6)        AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_RBC_REASONFORCANCEL') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')