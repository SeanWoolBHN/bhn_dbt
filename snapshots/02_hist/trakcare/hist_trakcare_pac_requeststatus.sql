{% snapshot HIST_TRAKCARE_PAC_REQUESTSTATUS %}
{{
    config(
        schema='TRAKCARE',
        unique_key='REQST_ROWID',
        strategy='check',
        check_cols=[
            'REQST_CODE', 'REQST_DESC', 'REQST_DATEFROM', 'REQST_DATETO',
            'REQST_OWNER', 'REQST_CODETABLETAGS', 'REQST_CREATEDDATE',
            'REQST_CREATEDTIME', 'REQST_CREATEDUSER_DR', 'REQST_UPDATEDDATE',
            'REQST_UPDATEDTIME', 'REQST_UPDATEDUSER_DR', 'REQST_CODETRANSLATED',
            'REQST_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'PAC_REQUESTSTATUS') }}
{% endsnapshot %}