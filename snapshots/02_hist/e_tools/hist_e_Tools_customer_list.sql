{% snapshot HIST_E_TOOLS_CUSTOMER_LIST %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='E_TOOLS',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'AGE', '"NO."', 'TITLE', 'PROVIDER', '"SUPPLMT."',
            'BDGT_IN_$', 'LAST_NAME', 'FIRST_NAME', 'START_DATE',
            '"CARE_REC.ID"', 'CONSUMER_ID', 'CONTINGENCY', 'CARE_MANAGER',
            '"CONS._CONTR."', 'DATE_OF_BIRTH', 'IS_VULNERABLE',
            'PACKAGE_LEVEL', 'PKG_MGMT_COST', 'RE_ASSMT_DATE',
            'CARE_MGMT_COST', '"PKG_MGMT_PERC%"', '"CARE_MGMT_PERC%"',
            'CONSUMER_STATUS', 'DISCHARGE_REASON', 'INCOME_TESTED_FEE',
            'PACKAGE_DISCHARGE_DATE', 'ACTIVE_PACKAGE_START_DATE',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_e_tools', 'CUSTOMER_LIST') }}

{% endsnapshot %}