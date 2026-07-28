{% snapshot HIST_TRAKCARE_PAC_CONTLOCALGOAL %}
{{ config(unique_key='LOCGOAL_ROWID', strategy='check',
    check_cols=['LOCGOAL_CODE','LOCGOAL_DESC','LOCGOAL_OWNER','LOCGOAL_DATETO',
        'LOCGOAL_DATEFROM','LOCGOAL_CREATEDDATE','LOCGOAL_CREATEDTIME',
        'LOCGOAL_UPDATEDDATE','LOCGOAL_UPDATEDTIME','LOCGOAL_CODETABLETAGS',
        'LOCGOAL_CREATEDUSER_DR','LOCGOAL_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_CONTLOCALGOAL') }}
{% endsnapshot %}