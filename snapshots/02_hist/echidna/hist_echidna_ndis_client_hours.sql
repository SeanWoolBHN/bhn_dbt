{% snapshot HIST_ECHIDNA_NDIS_CLIENT_HOURS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='ECHIDNA',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            '"TO"', '"DATE"', '"FROM"', 'RATE', 'HOURS', 'VALUE',
            'HOURS2', 'REGION', 'FUNDING', 'ITEM_NO', 'NDIS_NO',
            'ACTIVITY', 'CLIENT_ID', 'CONSULTANT', 'INVOICE_NO',
            'STAFF_TYPE', 'AMOUNT_PAID', 'CLIENT_NAME', 'HOURS_SPENT',
            'CONSULTANT_ID', 'NDIS_CLAIM_NO', 'CLIENT_SURNAME',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_echidna', 'NDIS_CLIENT_HOURS') }}

{% endsnapshot %}