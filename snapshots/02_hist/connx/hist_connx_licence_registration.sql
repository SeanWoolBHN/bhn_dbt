{% snapshot HIST_CONNX_LICENCE_REGISTRATION %}

{{
    config(
        unique_key="IDENTIFICATION_NUMBER||'-'||ISSUING_BODY||'-'||EMPLOYEE_NUMBER||'-'||LICENSE_TYPE||'-'||ISSUE_DATE||'-'||STATUS",
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
QUALIFY ROW_NUMBER() OVER (PARTITION BY IDENTIFICATION_NUMBER, ISSUING_BODY, EMPLOYEE_NUMBER, LICENSE_TYPE, ISSUE_DATE, STATUS ORDER BY _AIRBYTE_GENERATION_ID DESC, _AIRBYTE_RAW_ID) = 1

{% endsnapshot %}