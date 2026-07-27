{% snapshot HIST_TRAKCARE_CT_TITLE %}

{{
    config(
        unique_key='TTL_ROWID',
        strategy='check',
        check_cols=[
            'TTL_CODE', 'TTL_DESC', 'TTL_DATEFROM', 'TTL_DATETO',
            'TTL_OWNER', 'TTL_CODETABLETAGS', 'TTL_CREATEDDATE',
            'TTL_CREATEDTIME', 'TTL_CREATEDUSER_DR', 'TTL_UPDATEDDATE',
            'TTL_UPDATEDTIME', 'TTL_UPDATEDUSER_DR', 'TTL_CODETRANSLATED',
            'TTL_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'CT_TITLE') }}

{% endsnapshot %}