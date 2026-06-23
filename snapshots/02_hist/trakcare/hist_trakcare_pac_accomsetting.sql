{% snapshot HIST_TRAKCARE_PAC_ACCOMSETTING %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='ACCOMS_ROWID',
        strategy='check',
        check_cols=[
            'ACCOMS_CODE', 'ACCOMS_DESC', 'ACCOMS_DATEFROM', 'ACCOMS_DATETO',
            'ACCOMS_OWNER', 'ACCOMS_CODETABLETAGS', 'ACCOMS_CREATEDDATE',
            'ACCOMS_CREATEDTIME', 'ACCOMS_CREATEDUSER_DR', 'ACCOMS_UPDATEDDATE',
            'ACCOMS_UPDATEDTIME', 'ACCOMS_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'PAC_ACCOMSETTING') }}

{% endsnapshot %}