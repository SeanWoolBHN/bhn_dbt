{% snapshot HIST_TRAKCARE_PAC_INDIGSTATUS %}

{{
    config(
        unique_key='INDST_ROWID',
        strategy='check',
        check_cols=[
            'INDST_CODE', 'INDST_DESC', 'INDST_DATEFROM', 'INDST_DATETO',
            'INDST_NATIONALCODE', 'INDST_OWNER', 'INDST_CODETABLETAGS',
            'INDST_CREATEDDATE', 'INDST_CREATEDTIME', 'INDST_CREATEDUSER_DR',
            'INDST_UPDATEDDATE', 'INDST_UPDATEDTIME', 'INDST_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'PAC_INDIGSTATUS') }}

{% endsnapshot %}