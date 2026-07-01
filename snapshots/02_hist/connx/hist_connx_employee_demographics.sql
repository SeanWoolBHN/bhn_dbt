{% snapshot HIST_CONNX_EMPLOYEE_DEMOGRAPHICS %}

{{
    config(
        schema = 'CONNX',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'DOB', 'GENDER', 'POSTCODE', 'DEPARTMENT', 'NATIONALITY',
            'LANGUAGES_SPOKEN', 'ETHNICITY',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_connx', 'EMPLOYEE_DEMOGRAPHICS') }}

{% endsnapshot %}