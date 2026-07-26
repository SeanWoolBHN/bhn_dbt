{% snapshot HIST_TRAKCARE_PAC_CONTINTERPRETERTYPE %}
{{ config(unique_key='INTERP_ROWID', strategy='check',
    check_cols=['INTERP_CODE','INTERP_DESC','INTERP_OWNER','INTERP_DATETO',
        'INTERP_DATEFROM','INTERP_CREATEDDATE','INTERP_CREATEDTIME',
        'INTERP_UPDATEDDATE','INTERP_UPDATEDTIME','INTERP_CODETABLETAGS',
        'INTERP_CREATEDUSER_DR','INTERP_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_CONTINTERPRETERTYPE') }}
{% endsnapshot %}