{% snapshot HIST_TRAKCARE_OE_ORDSTATUS %}
{{
    config(
        unique_key='ST_ROWID',
        strategy='check',
        check_cols=[
            'ST_PARREF', 'ST_CHILDSUB', 'ST_DATE', 'ST_TIME',
            'ST_STATUS_DR', 'ST_USER_DR', 'ST_REASON',
            'ST_TEXTSTATUS', 'ST_ORDEXECSTATUS_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'OE_ORDSTATUS') }}
{% endsnapshot %}