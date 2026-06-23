{% snapshot HIST_TRAKCARE_CT_GENDERIDENTITY %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='GENID_ROWID',
        strategy='check',
        check_cols=[
            'GENID_CODE', 'GENID_DESC', 'GENID_DATEFROM', 'GENID_DATETO',
            'GENID_OWNER', 'GENID_CODETABLETAGS', 'GENID_CREATEDDATE',
            'GENID_CREATEDTIME', 'GENID_CREATEDUSER_DR', 'GENID_UPDATEDDATE',
            'GENID_UPDATEDTIME', 'GENID_UPDATEDUSER_DR', 'GENID_GROUPCODE',
            'GENID_HL7MAPPING', 'GENID_GENDER'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'CT_GENDERIDENTITY') }}

{% endsnapshot %}