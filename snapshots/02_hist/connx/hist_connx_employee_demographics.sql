{% snapshot HIST_CONNX_EMPLOYEE_DEMOGRAPHICS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='CONNX',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'DOB', 'GENDER', 'POSTCODE', 'DEPARTMENT', 'NATIONALITY',
            'LANGUAGES_SPOKEN', '"ETHNICITY_(AU/NZ)"',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_connx', 'EMPLOYEE_DEMOGRAPHICS') }}

{% endsnapshot %}