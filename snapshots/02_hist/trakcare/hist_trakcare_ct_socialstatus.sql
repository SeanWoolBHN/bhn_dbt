{% snapshot HIST_TRAKCARE_CT_SOCIALSTATUS %}

{{
    config(
        unique_key='SS_ROWID',
        strategy='check',
        check_cols=[
            'SS_CODE', 'SS_DESC', 'SS_OWNER', 'SS_CODETABLETAGS',
            'SS_CREATEDDATE', 'SS_CREATEDTIME', 'SS_CREATEDUSER_DR',
            'SS_UPDATEDDATE', 'SS_UPDATEDTIME', 'SS_UPDATEDUSER_DR',
            'SS_DATEFROM', 'SS_DATETO', 'SS_SEX_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'CT_SOCIALSTATUS') }}

{% endsnapshot %}