{% snapshot HIST_BEST_PRACTICE_BPS_SEARCH_RESULT %}

{{
    config(
        schema = 'BEST_PRACTICE',
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
            'EMAIL',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_best_practice', 'BPS_SEARCH_RESULT') }}

{% endsnapshot %}