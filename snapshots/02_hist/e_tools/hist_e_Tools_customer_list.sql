{% snapshot HIST_E_TOOLS_CUSTOMER_LIST %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='E_TOOLS',
        unique_key='ROW_KEY',
        strategy='check',
        check_cols=[
            'CONSUMER_ID',
            'TITLE',
            'FIRST_NAME',
            'LAST_NAME',
            'CARE_MANAGER',
            'DATE_OF_BIRTH',
            'AGE',
            'PROVIDER',
            'START_DATE',
            'PACKAGE_LEVEL',
            'INCOME_TESTED_FEE',
            'PKG_MGMT_COST',
            'CARE_MGMT_COST',
            'BDGT_IN_$',
            'CONTINGENCY',
            'ACTIVE_PACKAGE_START_DATE',
            'PACKAGE_DISCHARGE_DATE',
            'DISCHARGE_REASON',
            'CONSUMER_STATUS',
            'IS_VULNERABLE'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    MD5(
        COALESCE(CONSUMER_ID, 'unknown')                || '-' ||
        COALESCE(FIRST_NAME, 'unknown')                 || '-' ||
        COALESCE(LAST_NAME, 'unknown')                  || '-' ||
        COALESCE(DATE_OF_BIRTH, 'unknown')              || '-' ||
        COALESCE(CAST(AGE AS VARCHAR), 'unknown')       || '-' ||
        COALESCE(PROVIDER, 'unknown')                   || '-' ||
        COALESCE(START_DATE, 'unknown')                 || '-' ||
        COALESCE(PACKAGE_LEVEL, 'unknown')              || '-' ||
        COALESCE(CONSUMER_STATUS, 'unknown')            || '-' ||
        COALESCE(CAST(IS_VULNERABLE AS VARCHAR), 'unknown')
    )                                                   AS ROW_KEY,
    *,
    CURRENT_TIMESTAMP()                                 AS _stg_loaded_at

FROM {{ source('raw_e_tools', 'CUSTOMER_LIST') }}

{% endsnapshot %}