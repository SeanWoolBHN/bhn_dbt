{% snapshot hist_bps_search_result %}

{{
    config(
        unique_key='INTERNALID',
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

SELECT 
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_best_practise', 'BPS_SEARCH_RESULT') }}

{% endsnapshot %}