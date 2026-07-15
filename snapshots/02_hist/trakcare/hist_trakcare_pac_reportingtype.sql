{% snapshot HIST_TRAKCARE_PAC_REPORTINGTYPE %}
{{
    config(
        schema='TRAKCARE',
        unique_key='REPTYPE_ROWID',
        strategy='check',
        check_cols=[
            'REPTYPE_CODE', 'REPTYPE_DESC', 'REPTYPE_DATEFROM', 'REPTYPE_DATETO',
            'REPTYPE_NATIONALCODE', 'REPTYPE_NATIONCODETABLEMNGTINSTRUCTIONS',
            'REPTYPE_OWNER', 'REPTYPE_CODETABLETAGS', 'REPTYPE_CREATEDDATE',
            'REPTYPE_CREATEDTIME', 'REPTYPE_CREATEDUSER_DR', 'REPTYPE_UPDATEDDATE',
            'REPTYPE_UPDATEDTIME', 'REPTYPE_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'PAC_REPORTINGTYPE') }}
{% endsnapshot %}