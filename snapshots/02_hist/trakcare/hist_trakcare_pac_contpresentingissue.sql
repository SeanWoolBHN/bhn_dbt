{% snapshot HIST_TRAKCARE_PAC_CONTPRESENTINGISSUE %}
{{ config(unique_key='PRESISS_ROWID', strategy='check',
    check_cols=['PRESISS_CODE','PRESISS_DESC','PRESISS_OWNER','PRESISS_DATETO',
        'PRESISS_DATEFROM','PRESISS_CREATEDDATE','PRESISS_CREATEDTIME',
        'PRESISS_UPDATEDDATE','PRESISS_UPDATEDTIME','PRESISS_CODETABLETAGS',
        'PRESISS_CREATEDUSER_DR','PRESISS_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_CONTPRESENTINGISSUE') }}
{% endsnapshot %}