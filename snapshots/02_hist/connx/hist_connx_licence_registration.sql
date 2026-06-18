{% snapshot HIST_CONNX_LICENCE_REGISTRATION %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='CONNX',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'STATUS',
            '"ISSUE DATE"',
            '"EXPIRY DATE"',
            '"ISSUING BODY"',
            '"LICENSE TYPE"',
            '"EMPLOYEE NUMBER"',
            '"IDENTIFICATION NUMBER"',
            '"LICENSE CLASSIFICATION"',
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
    STATUS,
    "ISSUE DATE",
    "EXPIRY DATE",
    "ISSUING BODY",
    "LICENSE TYPE",
    "EMPLOYEE NUMBER",
    _AB_SOURCE_FILE_URL,
    "IDENTIFICATION NUMBER",
    "LICENSE CLASSIFICATION",
    _AB_SOURCE_FILE_LAST_MODIFIED,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_connx', 'LICENCE_REGISTRATION') }}

{% endsnapshot %}