{% snapshot HIST_ECHIDNA_NDIS_CLIENT_HOURS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='ECHIDNA',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            '"TO"',
            'DATE',
            '"FROM"',
            'RATE',
            'HOURS',
            'VALUE',
            'HOURS2',
            'REGION',
            'FUNDING',
            '"ITEM NO"',
            '"NDIS NO"',
            'ACTIVITY',
            '"CLIENT ID"',
            'CONSULTANT',
            '"INVOICE NO"',
            '"STAFF TYPE"',
            '"AMOUNT PAID"',
            '"CLIENT NAME"',
            '"HOURS SPENT"',
            '"CONSULTANT ID"',
            '"NDIS CLAIM NO"',
            '"CLIENT SURNAME"',
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
    "TO",
    DATE,
    "FROM",
    RATE,
    HOURS,
    VALUE,
    HOURS2,
    REGION,
    FUNDING,
    "ITEM NO",
    "NDIS NO",
    ACTIVITY,
    "CLIENT ID",
    CONSULTANT,
    "INVOICE NO",
    "STAFF TYPE",
    "AMOUNT PAID",
    "CLIENT NAME",
    "HOURS SPENT",
    "CONSULTANT ID",
    "NDIS CLAIM NO",
    "CLIENT SURNAME",
    _AB_SOURCE_FILE_URL,
    _AB_SOURCE_FILE_LAST_MODIFIED,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_echidna', 'NDIS_CLIENT_HOURS') }}

{% endsnapshot %}