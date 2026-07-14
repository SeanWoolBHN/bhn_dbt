{% snapshot HIST_TRAKCARE_RTC_MRECORDTYPE %}
{{
    config(
        schema='TRAKCARE',
        unique_key='TYP_ROWID',
        strategy='check',
        check_cols=[
            'TYP_SUF', 'TYP_CODE', 'TYP_DESC', 'TYP_PREF', 'TYP_OWNER',
            'TYP_DATETO', 'TYP_LENGTH', 'TYP_COUNTER', 'TYP_CTLOC_DR',
            'TYP_DATEFROM', 'TYP_MRNOPOLICY', 'TYP_VOLUMETYPE',
            'TYP_CREATEDDATE', 'TYP_CREATEDTIME', 'TYP_UPDATEDDATE',
            'TYP_UPDATEDTIME', 'TYP_CODETABLETAGS', 'TYP_CREATEDUSER_DR',
            'TYP_UPDATEDUSER_DR', 'TYP_NOTCREATEVOLUME'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'RTC_MRECORDTYPE') }}
{% endsnapshot %}