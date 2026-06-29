SELECT
    {{ format_name('TITLE') }}                   AS TITLE,
    TRIM(EMPCODE)                                 AS EMPLOYEE_CODE,
    {{ format_name('SURNAME') }}                 AS LAST_NAME,
    {{ format_name('FIRSTNAME') }}                AS FIRST_NAME,
    {{ format_date('HIREDDATE') }}                AS HIRED_DATE,
    TRIM(IDEMPLOYEE)                              AS EMPLOYEE_ID,
    {{ format_name('MIDDLENAME') }}               AS MIDDLE_NAME,
    TRIM(NORMALHOURS)                             AS NORMAL_HOURS,
    {{ format_name('PREFERREDNAME') }}            AS PREF_NAME,
    {{ format_date('TERMINATIONDATE') }}          AS TERMINATION_DATE,
    TRIM(TERMINATIONREASON)                       AS TERMINATION_REASON,
    TRIM(DEFAULTCOSTACCOUNT)                      AS DEFAULT_COST_ACCOUNT,

    _AIRBYTE_EXTRACTED_AT                          AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_MICROPAY_EMPLOYEE_DETAILS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')