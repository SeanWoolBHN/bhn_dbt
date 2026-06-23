{% snapshot HIST_TRAKCARE_CT_NATION %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='CTNAT_ROWID',
        strategy='check',
        check_cols=[
            'CTNAT_CODE', 'CTNAT_DESC', 'CTNAT_OWNER', 'CTNAT_CODETABLETAGS',
            'CTNAT_CREATEDDATE', 'CTNAT_CREATEDTIME', 'CTNAT_CREATEDUSER_DR',
            'CTNAT_UPDATEDDATE', 'CTNAT_UPDATEDTIME', 'CTNAT_UPDATEDUSER_DR',
            'CTNAT_RESIDENT', 'CTNAT_DATEFROM', 'CTNAT_DATETO',
            'CTNAT_NATIONALCODE', 'CTNAT_ISO3166CODE',
            'CTNAT_ISO3166ALPHA2CODE', 'CTNAT_ISO3166ALPHA3CODE',
            'CTNAT_NATIONALITYGROUP_DR', 'CTNAT_CODETRANSLATED',
            'CTNAT_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'CT_NATION') }}

{% endsnapshot %}