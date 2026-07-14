SELECT
    TRIM(AGE)                                    AS AGE,
    TRY_TO_NUMBER(TRIM(NO_),18,6)                AS NO,
    {{ format_name('TITLE') }}                   AS TITLE,
    {{ format_name('PROVIDER') }}                AS PROVIDER,
    TRIM(SUPPLMT_)                                AS SUPPLMT,
    TRIM(BDGT_IN_$)                               AS BDGT_IN,
    {{ format_name('LAST_NAME') }}                AS LAST_NAME,
    {{ format_name('FIRST_NAME') }}               AS FIRST_NAME,
    {{ format_date('START_DATE') }}               AS START_DATE,
    CAST(TRIM(CARE_REC_ID) AS TEXT)               AS CARE_RECIPIENT_ID,
    TRIM(CONSUMER_ID)                             AS CONSUMER_ID,
    TRIM(CONTINGENCY)                             AS CONTINGENCY,
    {{ format_name('CARE_MANAGER') }}             AS CARE_MANAGER,
    TRIM(CONS_CONTR_)                             AS CONS_CONTR,
    {{ format_date('DATE_OF_BIRTH') }}            AS DOB,
    IS_VULNERABLE,
    TRIM(PACKAGE_LEVEL)                           AS PKG_LEVEL,
    TRIM(PKG_MGMT_COST)                           AS PKG_MGMT_COST,
    {{ format_date('RE_ASSMT_DATE') }}            AS RE_ASSESSMENT_DATE,
    TRY_TO_NUMBER(TRIM(CARE_MGMT_COST),18,6)      AS CARE_MGMT_COST,
    TRIM(PKG_MGMT_PERC_)                          AS PKG_MGMT_PERCENT,
    TRIM(CARE_MGMT_PERC_)                         AS CARE_MGMT_PERCENT,
    TRIM(CONSUMER_STATUS)                         AS CLIENT_STATUS,
    TRIM(DISCHARGE_REASON)                        AS DISCHARGE_REASON,
    TRIM(INCOME_TESTED_FEE)                       AS INCOME_TESTED_FEE,
    {{ format_date('PACKAGE_DISCHARGE_DATE') }}   AS PKG_DISCHARGE_DATE,
    {{ format_date('ACTIVE_PACKAGE_START_DATE') }} AS ACTIVE_PKG_START_DATE,

    _AIRBYTE_EXTRACTED_AT                          AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_E_TOOLS_CUSTOMER_LIST') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31') AND UPPER(CLIENT_STATUS) IN ('ACTIVE','DISCHARGED')