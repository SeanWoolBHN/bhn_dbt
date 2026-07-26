{% snapshot HIST_TRAKCARE_PAC_CONTOUTCOME %}
{{ config(unique_key='CONTOUTC_ROWID', strategy='check',
    check_cols=['CONTOUTC_CODE','CONTOUTC_DESC','CONTOUTC_OWNER','CONTOUTC_DATETO',
        'CONTOUTC_DATEFROM','CONTOUTC_CREATEDDATE','CONTOUTC_CREATEDTIME',
        'CONTOUTC_UPDATEDDATE','CONTOUTC_UPDATEDTIME','CONTOUTC_CODETABLETAGS',
        'CONTOUTC_CREATEDUSER_DR','CONTOUTC_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_CONTOUTCOME') }}
{% endsnapshot %}