{% snapshot HIST_TRAKCARE_PAC_CARDTYPE %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='CARD_ROWID',
        strategy='check',
        check_cols=[
            'CARD_CODE', 'CARD_DESC', 'CARD_DATEFROM', 'CARD_DATETO',
            'CARD_OWNER', 'CARD_CODETABLETAGS', 'CARD_CREATEDDATE',
            'CARD_CREATEDTIME', 'CARD_CREATEDUSER_DR', 'CARD_UPDATEDDATE',
            'CARD_UPDATEDTIME', 'CARD_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'PAC_CARDTYPE') }}

{% endsnapshot %}