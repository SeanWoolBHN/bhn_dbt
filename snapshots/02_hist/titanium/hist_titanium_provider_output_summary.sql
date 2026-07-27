{% snapshot HIST_TITANIUM_PROVIDER_OUTPUT_SUMMARY %}

{{
    config(
        unique_key='PROVIDER',
        strategy='check',
        check_cols=[
            'COC',
            'AMOUNT',
            'VISITS',
            'FTAAPPT',
            'PATIENTS',
            'PROVIDER',
            'TEXTBOX62',
            'TOTALAPPT',
            'APPTNOTREAT',
            'PROVIDERNAME',
            'PROVIDERTYPE',
            'FTALENGTHHOURS',
            'PROVIDERREGTYPE',
            'APPTLENGTHHOURS1',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
*
FROM {{ source('raw_titanium', 'PROVIDER_OUTPUT_SUMMARY') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY PROVIDER ORDER BY _AIRBYTE_GENERATION_ID DESC) = 1

{% endsnapshot %}