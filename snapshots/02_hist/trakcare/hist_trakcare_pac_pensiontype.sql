{% snapshot HIST_TRAKCARE_PAC_PENSIONTYPE %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='PENSTYPE_ROWID',
        strategy='check',
        check_cols=[
            'PENSTYPE_CODE', 'PENSTYPE_DESC', 'PENSTYPE_DATEFROM',
            'PENSTYPE_DATETO', 'PENSTYPE_OWNER', 'PENSTYPE_CODETABLETAGS',
            'PENSTYPE_CREATEDDATE', 'PENSTYPE_CREATEDTIME',
            'PENSTYPE_CREATEDUSER_DR', 'PENSTYPE_UPDATEDDATE',
            'PENSTYPE_UPDATEDTIME', 'PENSTYPE_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'PAC_PENSIONTYPE') }}

{% endsnapshot %}