{% snapshot HIST_CONNX_LICENCE_REGISTRATION %}

{{
    config(
        schema = 'CONNX',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'STATUS', 'ISSUE_DATE', 'EXPIRY_DATE', 'ISSUING_BODY',
            'LICENSE_TYPE', 'EMPLOYEE_NUMBER', 'IDENTIFICATION_NUMBER',
            'LICENSE_CLASSIFICATION',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_connx', 'LICENCE_REGISTRATION') }}

{% endsnapshot %}