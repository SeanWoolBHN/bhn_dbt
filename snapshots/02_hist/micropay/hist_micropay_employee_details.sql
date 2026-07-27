{% snapshot HIST_MICROPAY_EMPLOYEE_DETAILS %}

{{
    config(
        unique_key='IDEMPLOYEE',
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
QUALIFY ROW_NUMBER() OVER (PARTITION BY IDEMPLOYEE ORDER BY _AIRBYTE_GENERATION_ID DESC) = 1

{% endsnapshot %}