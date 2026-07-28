{% snapshot HIST_TRAKCARE_PAC_CONTMETHOD %}
{{ config(unique_key='CONTMETH_ROWID', strategy='check',
    check_cols=['CONTMETH_CODE','CONTMETH_DESC','CONTMETH_OWNER','CONTMETH_DATETO',
        'CONTMETH_DATEFROM','CONTMETH_CREATEDDATE','CONTMETH_CREATEDTIME',
        'CONTMETH_UPDATEDDATE','CONTMETH_UPDATEDTIME','CONTMETH_CODETABLETAGS',
        'CONTMETH_CREATEDUSER_DR','CONTMETH_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_CONTMETHOD') }}
{% endsnapshot %}