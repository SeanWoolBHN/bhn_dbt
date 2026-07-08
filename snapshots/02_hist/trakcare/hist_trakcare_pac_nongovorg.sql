{% snapshot HIST_TRAKCARE_PAC_NONGOVORG %}
{{
    config(
        schema='TRAKCARE',
        unique_key='NGO_ROWID',
        strategy='check',
        check_cols=[
            'NGO_CODE', 'NGO_DESC', 'NGO_ADDRESS', 'NGO_CITY_DR',
            'NGO_ZIP_DR', 'NGO_PROVINCE_DR', 'NGO_PHONE', 'NGO_FAX',
            'NGO_EMAIL', 'NGO_CONTACTMETHOD', 'NGO_DATEFROM', 'NGO_DATETO',
            'NGO_SCHOOL', 'NGO_OWNER', 'NGO_CODETABLETAGS',
            'NGO_PATHOLOGYPROVIDER', 'NGO_CREATEDDATE', 'NGO_CREATEDTIME',
            'NGO_CREATEDUSER_DR', 'NGO_UPDATEDDATE', 'NGO_UPDATEDTIME',
            'NGO_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'PAC_NONGOVORG') }}
{% endsnapshot %}