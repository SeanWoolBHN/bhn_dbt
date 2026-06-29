{% snapshot HIST_TRAKCARE_PAC_PREFERREDLANGUAGE %}

{{
    config(
        schema='TRAKCARE',
        unique_key='PREFL_ROWID',
        strategy='check',
        check_cols=[
            'PREFL_CODE', 'PREFL_DESC', 'PREFL_VEMDCODE', 'PREFL_DATEFROM',
            'PREFL_DATETO', 'PREFL_OWNER', 'PREFL_CODETABLETAGS',
            'PREFL_CREATEDDATE', 'PREFL_CREATEDTIME', 'PREFL_CREATEDUSER_DR',
            'PREFL_UPDATEDDATE', 'PREFL_UPDATEDTIME', 'PREFL_UPDATEDUSER_DR',
            'PREFL_DIALECT', 'PREFL_CODETRANSLATED', 'PREFL_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'PAC_PREFERREDLANGUAGE') }}

{% endsnapshot %}