{% snapshot HIST_TRAKCARE_PAC_REFERREDDEPARTURE %}
{{
    config(
        unique_key='REFDEP_ROWID',
        strategy='check',
        check_cols=[
            'REFDEP_CODE', 'REFDEP_DESC', 'REFDEP_DATEFROM', 'REFDEP_DATETO',
            'REFDEP_NATIONALCODE', 'REFDEP_OWNER', 'REFDEP_CODETABLETAGS',
            'REFDEP_CREATEDDATE', 'REFDEP_CREATEDTIME', 'REFDEP_CREATEDUSER_DR',
            'REFDEP_UPDATEDDATE', 'REFDEP_UPDATEDTIME', 'REFDEP_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'PAC_REFERREDDEPARTURE') }}
{% endsnapshot %}