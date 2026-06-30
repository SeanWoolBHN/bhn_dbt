{% snapshot HIST_MICROPAY_EMPLOYEE_DETAILS %}

{{
    config(
        schema = 'MICROPAY',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'TITLE',
            'EMPCODE',
            'SURNAME',
            'FIRSTNAME',
            'HIREDDATE',
            'IDEMPLOYEE',
            'MIDDLENAME',
            'NORMALHOURS',
            'PREFERREDNAME',
            'TERMINATIONDATE',
            'TERMINATIONREASON',
            'DEFAULTCOSTACCOUNT',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
*
FROM {{ source('raw_micropay', 'EMPLOYEE_DETAILS') }}

{% endsnapshot %}