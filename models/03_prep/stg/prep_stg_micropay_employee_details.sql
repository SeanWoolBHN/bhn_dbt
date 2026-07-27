SELECT
    {{ format_name('TITLE') }}                    AS TITLE,
    TRY_TO_NUMBER(TRIM(EMPCODE),18,6)             AS EMPLOYEE_CODE,
    {{ format_name('SURNAME') }}                  AS LAST_NAME,
    {{ format_name('FIRSTNAME') }}                AS FIRST_NAME,
    {{ format_date('HIREDDATE') }}                AS HIRED_DATE,
    TRY_TO_NUMBER(TRIM(IDEMPLOYEE),18,6)          AS EMPLOYEE_ID,
    {{ format_name('MIDDLENAME') }}               AS MIDDLE_NAME,
    TRY_TO_NUMBER(TRIM(NORMALHOURS),18,6)          AS NORMAL_HOURS,
    {{ format_name('PREFERREDNAME') }}            AS PREF_NAME,
    {{ format_date('TERMINATIONDATE') }}          AS TERMINATION_DATE,
    TRIM(TERMINATIONREASON)                       AS TERMINATION_REASON,
    TRIM(DEFAULTCOSTACCOUNT)                      AS DEFAULT_COST_ACCOUNT,

    _AIRBYTE_EXTRACTED_AT                          AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_MICROPAY_EMPLOYEE_DETAILS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')