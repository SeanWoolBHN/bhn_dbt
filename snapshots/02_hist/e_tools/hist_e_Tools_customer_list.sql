{% snapshot HIST_E_TOOLS_CUSTOMER_LIST %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='E_TOOLS',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            '"NO."',
            'AGE',
            'TITLE',
            'PROVIDER',
            '"SUPPLMT."',
            '"BDGT IN $"',
            '"LAST NAME"',
            '"FIRST NAME"',
            '"START DATE"',
            '"CARE REC.ID"',
            '"CONSUMER ID"',
            'CONTINGENCY',
            '"CARE MANAGER"',
            '"CONS. CONTR."',
            '"DATE OF BIRTH"',
            '"IS VULNERABLE"',
            '"PACKAGE LEVEL"',
            '"PKG MGMT COST"',
            '"RE-ASSMT DATE"',
            '"CARE MGMT COST"',
            '"PKG MGMT PERC%"',
            '"CARE MGMT PERC%"',
            '"CONSUMER STATUS"',
            '"DISCHARGE REASON"',
            '"INCOME TESTED FEE"',
            '"PACKAGE DISCHARGE DATE"',
            '"ACTIVE PACKAGE START DATE"',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    _AIRBYTE_RAW_ID,
    _AIRBYTE_EXTRACTED_AT,
    _AIRBYTE_META,
    _AIRBYTE_GENERATION_ID,
    AGE,
    "NO.",
    TITLE,
    PROVIDER,
    "SUPPLMT.",
    "BDGT IN $",
    "LAST NAME",
    "FIRST NAME",
    "START DATE",
    "CARE REC.ID",
    "CONSUMER ID",
    CONTINGENCY,
    "CARE MANAGER",
    "CONS. CONTR.",
    "DATE OF BIRTH",
    "IS VULNERABLE",
    "PACKAGE LEVEL",
    "PKG MGMT COST",
    "RE-ASSMT DATE",
    "CARE MGMT COST",
    "PKG MGMT PERC%",
    "CARE MGMT PERC%",
    "CONSUMER STATUS",
    "DISCHARGE REASON",
    "INCOME TESTED FEE",
    _AB_SOURCE_FILE_URL,
    "PACKAGE DISCHARGE DATE",
    "ACTIVE PACKAGE START DATE",
    _AB_SOURCE_FILE_LAST_MODIFIED,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_e_tools', 'CUSTOMER_LIST') }}

{% endsnapshot %}