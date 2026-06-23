{% snapshot HIST_TRAKCARE_CT_MARITAL %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='CTMAR_ROWID',
        strategy='check',
        check_cols=[
            'CTMAR_CODE', 'CTMAR_DESC', 'CTMAR_PRS2', 'CTMAR_DATEFROM',
            'CTMAR_DATETO', 'CTMAR_OWNER', 'CTMAR_CODETABLETAGS',
            'CTMAR_CREATEDDATE', 'CTMAR_CREATEDTIME', 'CTMAR_CREATEDUSER_DR',
            'CTMAR_UPDATEDDATE', 'CTMAR_UPDATEDTIME', 'CTMAR_UPDATEDUSER_DR',
            'CTMAR_CODETRANSLATED', 'CTMAR_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'CT_MARITAL') }}

{% endsnapshot %}