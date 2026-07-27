{% snapshot HIST_TRAKCARE_RBC_EVENTTYPE %}
{{
    config(
        unique_key='EVT_ROWID',
        strategy='check',
        check_cols=[
            'EVT_CODE', 'EVT_DESC', 'EVT_DATEFROM', 'EVT_DATETO',
            'EVT_OWNER', 'EVT_CODETABLETAGS', 'EVT_CREATEDDATE',
            'EVT_CREATEDTIME', 'EVT_CREATEDUSER_DR', 'EVT_UPDATEDDATE',
            'EVT_UPDATEDTIME', 'EVT_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'RBC_EVENTTYPE') }}
{% endsnapshot %}