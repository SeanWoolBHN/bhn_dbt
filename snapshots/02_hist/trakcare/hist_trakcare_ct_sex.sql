{% snapshot HIST_TRAKCARE_CT_SEX %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='CTSEX_ROWID',
        strategy='check',
        check_cols=[
            'CTSEX_CODE', 'CTSEX_DESC', 'CTSEX_GROUPERCODE', 'CTSEX_DATEFROM',
            'CTSEX_DATETO', 'CTSEX_GENDER', 'CTSEX_HL7CODE', 'CTSEX_ICONNAME',
            'CTSEX_OWNER', 'CTSEX_CODETABLETAGS', 'CTSEX_CREATEDDATE',
            'CTSEX_CREATEDTIME', 'CTSEX_CREATEDUSER_DR', 'CTSEX_UPDATEDDATE',
            'CTSEX_UPDATEDTIME', 'CTSEX_UPDATEDUSER_DR',
            'CTSEX_CODETRANSLATED', 'CTSEX_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'CT_SEX') }}

{% endsnapshot %}