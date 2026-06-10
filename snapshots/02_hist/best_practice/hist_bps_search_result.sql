{% snapshot hist_bps_search_result %}

{{
    config(
        unique_key='internalid',
        strategy='check',
        check_cols=[
            'SURNAME',
            'FIRSTNAME',
            'MIDDLENAME',
            'PREFERREDNAME',
            'TITLE',
            'ADDRESS1',
            'ADDRESS2',
            'CITY',
            'POSTCODE',
            'FULLADDRESS',
            'DOB',
            'AGE',
            'SEX',
            'MEDICARENO',
            'MEDICARELINENO',
            'MEDICAREEXPIRY',
            'RECORDNO',
            'PENSIONNO',
            'DVANO',
            'HOMEPHONE',
            'WORKPHONE',
            'MOBILEPHONE',
            'EMAIL'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT * FROM {{ ref('stg_bps_search_result') }}

{% endsnapshot %}