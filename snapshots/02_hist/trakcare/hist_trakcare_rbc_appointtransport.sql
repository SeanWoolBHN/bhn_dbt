{% snapshot HIST_TRAKCARE_RBC_APPOINTTRANSPORT %}
{{
    config(
        unique_key='APTR_ROWID',
        strategy='check',
        check_cols=[
            'APTR_CODE', 'APTR_DESC', 'APTR_DATEFROM', 'APTR_DATETO',
            'APTR_CONTACTMETHOD', 'APTR_EMAIL', 'APTR_FAX', 'APTR_PHONE',
            'APTR_ADRESS', 'APTR_OWNER', 'APTR_CODETABLETAGS',
            'APTR_CREATEDDATE', 'APTR_CREATEDTIME', 'APTR_CREATEDUSER_DR',
            'APTR_UPDATEDDATE', 'APTR_UPDATEDTIME', 'APTR_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'RBC_APPOINTTRANSPORT') }}
{% endsnapshot %}