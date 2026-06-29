{% snapshot HIST_TRAKCARE_CT_OCCUPATION %}

{{
    config(
        schema='TRAKCARE',
        unique_key='CTOCC_ROWID',
        strategy='check',
        check_cols=[
            'CTOCC_CODE', 'CTOCC_DESC', 'CTOCC_DATEFROM', 'CTOCC_DATETO',
            'CTOCC_OWNER', 'CTOCC_CODETABLETAGS', 'CTOCC_CREATEDDATE',
            'CTOCC_CREATEDTIME', 'CTOCC_CREATEDUSER_DR', 'CTOCC_UPDATEDDATE',
            'CTOCC_UPDATEDTIME', 'CTOCC_UPDATEDUSER_DR',
            'CTOCC_CODETRANSLATED', 'CTOCC_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'CT_OCCUPATION') }}

{% endsnapshot %}