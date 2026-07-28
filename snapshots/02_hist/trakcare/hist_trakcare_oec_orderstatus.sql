{% snapshot HIST_TRAKCARE_OEC_ORDERSTATUS %}
{{
    config(
        schema='TRAKCARE',
        unique_key='OSTAT_ROWID',
        strategy='check',
        check_cols=[
            'OSTAT_CODE', 'OSTAT_DESC', 'OSTAT_COLOR', 'OSTAT_ACTIVATE',
            'OSTAT_CREATEDDATE', 'OSTAT_CREATEDTIME', 'OSTAT_UPDATEDDATE',
            'OSTAT_UPDATEDTIME', 'OSTAT_CREATEDUSER_DR', 'OSTAT_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'OEC_ORDERSTATUS') }}
{% endsnapshot %}