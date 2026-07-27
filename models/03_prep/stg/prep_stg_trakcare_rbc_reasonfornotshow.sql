SELECT
    RNS_ROWID                                                             AS ROW_ID,
    NULLIF(TRIM(RNS_CODE), 'NULL')                                        AS CODE,
    NULLIF(TRIM(RNS_DESC), 'NULL')                                        AS DESCRIPTION,
    RNS_DATEFROM                                                          AS DATE_FROM,
    NULLIF(TRIM(RNS_DATETO), 'NULL')                                      AS DATE_TO,
    NULLIF(TRIM(RNS_DEFAULTDNAREASON), 'NULL')                            AS DEFAULT_DNA_REASON,
    NULLIF(TRIM(RNS_REASONTOCHANGEOPWLTOREMOVED_DR), 'NULL')              AS REASON_TO_CHANGE_OP_WL_TO_REMOVED_DR,
    NULLIF(TRIM(RNS_OPWLSTATUSTOREINSTATE_DR), 'NULL')                    AS OP_WL_STATUS_TO_REINSTATE_DR,
    NULLIF(TRIM(RNS_INCLINNUMDNA), 'NULL')                                AS INCL_IN_NUM_DNA,
    NULLIF(TRIM(RNS_RESETTTGCLOCK), 'NULL')                               AS RESET_TTG_CLOCK,
    NULLIF(TRIM(RNS_NATIONALCODE), 'NULL')                                AS NATIONAL_CODE,
    NULLIF(TRIM(RNS_OWNER), 'NULL')                                       AS OWNER,
    NULLIF(TRIM(RNS_CODETABLETAGS), 'NULL')                               AS CODE_TABLE_TAGS,
    NULLIF(TRIM(RNS_REMOVECONTACTREMINDERDATES), 'NULL')                  AS REMOVE_CONTACT_REMINDER_DATES,
    TRY_TO_DATE(NULLIF(TRIM(RNS_CREATEDDATE), 'NULL'))                    AS CREATED_DATE,
    NULLIF(TRIM(RNS_CREATEDTIME), 'NULL')                                 AS CREATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(RNS_CREATEDUSER_DR), 'NULL'), 18, 6)        AS CREATED_USER_DR,
    TRY_TO_DATE(NULLIF(TRIM(RNS_UPDATEDDATE), 'NULL'))                    AS UPDATED_DATE,
    NULLIF(TRIM(RNS_UPDATEDTIME), 'NULL')                                 AS UPDATED_TIME,
    TRY_TO_NUMBER(NULLIF(TRIM(RNS_UPDATEDUSER_DR), 'NULL'), 18, 6)        AS UPDATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_RBC_REASONFORNOTSHOW') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')