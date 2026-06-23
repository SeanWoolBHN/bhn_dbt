{% snapshot HIST_TRAKCARE_PAC_CONCESSIONCARDTYPE %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='CONCCARD_ROWID',
        strategy='check',
        check_cols=[
            'CONCCARD_CODE', 'CONCCARD_DESC', 'CONCCARD_DATEFROM',
            'CONCCARD_DATETO', 'CONCCARD_OWNER', 'CONCCARD_CODETABLETAGS',
            'CONCCARD_CREATEDDATE', 'CONCCARD_CREATEDTIME',
            'CONCCARD_CREATEDUSER_DR', 'CONCCARD_UPDATEDDATE',
            'CONCCARD_UPDATEDTIME', 'CONCCARD_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'PAC_CONCESSIONCARDTYPE') }}

{% endsnapshot %}