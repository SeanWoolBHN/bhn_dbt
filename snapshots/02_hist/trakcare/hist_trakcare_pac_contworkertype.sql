{% snapshot HIST_TRAKCARE_PAC_CONTWORKERTYPE %}
{{ config(unique_key='WORKT_ROWID', strategy='check',
    check_cols=['WORKT_CODE','WORKT_DESC','WORKT_OWNER','WORKT_DATETO',
        'WORKT_DATEFROM','WORKT_CREATEDDATE','WORKT_CREATEDTIME',
        'WORKT_UPDATEDDATE','WORKT_UPDATEDTIME','WORKT_CODETABLETAGS',
        'WORKT_CREATEDUSER_DR','WORKT_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_CONTWORKERTYPE') }}
{% endsnapshot %}