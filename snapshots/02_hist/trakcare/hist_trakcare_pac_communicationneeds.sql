{% snapshot HIST_TRAKCARE_PAC_COMMUNICATIONNEEDS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='COMMNEEDS_ROWID',
        strategy='check',
        check_cols=[
            'COMMNEEDS_CODE', 'COMMNEEDS_DESC', 'COMMNEEDS_DATEFROM',
            'COMMNEEDS_DATETO', 'COMMNEEDS_OWNER', 'COMMNEEDS_CODETABLETAGS',
            'COMMNEEDS_CREATEDDATE', 'COMMNEEDS_CREATEDTIME',
            'COMMNEEDS_CREATEDUSER_DR', 'COMMNEEDS_UPDATEDDATE',
            'COMMNEEDS_UPDATEDTIME', 'COMMNEEDS_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'PAC_COMMUNICATIONNEEDS') }}

{% endsnapshot %}