{% snapshot HIST_ECHIDNA_NDIS_CLIENT_HOURS %}

{{
    config(
        unique_key="_AIRBYTE_RAW_ID",
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
WITH cte_max_gen AS (
    SELECT MAX(_AIRBYTE_GENERATION_ID) AS MAX_GEN
    FROM {{ source('raw_echidna', 'NDIS_CLIENT_HOURS') }}
)


SELECT
    *
FROM {{ source('raw_echidna', 'NDIS_CLIENT_HOURS') }} ch
INNER JOIN cte_max_gen mg
    ON mg.MAX_GEN = ch._AIRBYTE_GENERATION_ID


{% endsnapshot %}