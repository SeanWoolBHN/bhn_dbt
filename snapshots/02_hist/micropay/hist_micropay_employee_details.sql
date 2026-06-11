{% snapshot HIST_MICROPAY_EMPLOYEE_DETAILS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='MICROPAY',
        unique_key='IDEMPLOYEE',
        strategy='check',
        check_cols=[
            'EMPCODE',
            'SURNAME',
            'FIRSTNAME',
            'MIDDLENAME',
            'PREFERREDNAME',
            'TITLE',
            'LOCATION',
            'HIREDDATE',
            'NORMALHOURS',
            'DEFAULTCOSTACCOUNT',
            'TERMINATIONDATE',
            'TERMINATIONREASON'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    IDEMPLOYEE,
    EMPCODE,
    SURNAME,
    FIRSTNAME,
    MIDDLENAME,
    PREFERREDNAME,
    TITLE,
    LOCATION,
    HIREDDATE,
    NORMALHOURS,
    DEFAULTCOSTACCOUNT,
    TERMINATIONDATE,
    TERMINATIONREASON,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_micropay', 'EMPLOYEE_DETAILS') }}

{% endsnapshot %}