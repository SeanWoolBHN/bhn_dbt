{% snapshot HIST_TRAKCARE_PAC_INDIGSTATUS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='INDST_ROWID',
        strategy='check',
        check_cols=[
            'INDST_CODE', 'INDST_DESC', 'INDST_DATEFROM', 'INDST_DATETO',
            'INDST_NATIONALCODE', 'INDST_OWNER', 'INDST_CODETABLETAGS',
            'INDST_CREATEDDATE', 'INDST_CREATEDTIME', 'INDST_CREATEDUSER_DR',
            'INDST_UPDATEDDATE', 'INDST_UPDATEDTIME', 'INDST_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'PAC_INDIGSTATUS') }}

{% endsnapshot %}