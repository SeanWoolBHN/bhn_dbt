{% snapshot HIST_TRAKCARE_PAC_LIVINGARRANGEMENT %}

{{
    config(
        unique_key='LIVARR_ROWID',
        strategy='check',
        check_cols=[
            'LIVARR_CODE', 'LIVARR_DESC', 'LIVARR_DATEFROM', 'LIVARR_DATETO',
            'LIVARR_NATIONCODE', 'LIVARR_NATIONCODEDESC', 'LIVARR_OWNER',
            'LIVARR_CODETABLETAGS', 'LIVARR_CREATEDDATE', 'LIVARR_CREATEDTIME',
            'LIVARR_CREATEDUSER_DR', 'LIVARR_UPDATEDDATE', 'LIVARR_UPDATEDTIME',
            'LIVARR_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_trakcare', 'PAC_LIVINGARRANGEMENT') }}

{% endsnapshot %}