SELECT
    TRY_TO_NUMBER(TRIM(EMPCODE),18,6)             AS EMPLOYEE_CODE,
    LEAVECODE                                     AS LEAVE_CODE,
    TRIM(LEAVETYPE)                               AS LEAVE_TYPE,
    TRIM(TERMINATED)                              AS IS_TERMINATED,
    {{ format_date('POSTENTDATE') }}              AS POST_ENT_DATE,
    TRIM(POSTENTDAYS)                             AS POST_ENT_DAYS,
    TRY_TO_NUMBER(TRIM(POSTENTHOURS),18,6)        AS POST_ENT_HOURS,
    TRY_TO_NUMBER(TRIM(IDEMPLOYEELEAVE),18,6)     AS EMPLOYEE_LEAVE_ID,

    _AIRBYTE_EXTRACTED_AT                          AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_MICROPAY_EMPLOYEE_LEAVE') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')