{% snapshot HIST_TRAKCARE_PAC_REQUESTTYPE %}
{{ config(unique_key='REQTYP_ROWID', strategy='check',
    check_cols=['REQTYP_CODE','REQTYP_DESC','REQTYP_OWNER','REQTYP_DATETO',
        'REQTYP_DATEFROM','REQTYP_CREATEDDATE','REQTYP_CREATEDTIME',
        'REQTYP_UPDATEDDATE','REQTYP_UPDATEDTIME','REQTYP_CODETABLETAGS',
        'REQTYP_CREATEDUSER_DR','REQTYP_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_REQUESTTYPE') }}
{% endsnapshot %}