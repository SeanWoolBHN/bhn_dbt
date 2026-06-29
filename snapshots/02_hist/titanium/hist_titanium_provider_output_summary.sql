{% snapshot HIST_TITANIUM_PROVIDER_OUTPUT_SUMMARY %}

{{
    config(
        schema = 'TITANIUM',
        unique_key='_AIRBYTE_RAW_ID',
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
    _AIRBYTE_RAW_ID,
    _AIRBYTE_EXTRACTED_AT,
    _AIRBYTE_META,
    _AIRBYTE_GENERATION_ID,
    COC,
    AMOUNT,
    VISITS,
    FTAAPPT,
    PATIENTS,
    PROVIDER,
    TEXTBOX62,
    TOTALAPPT,
    APPTNOTREAT,
    PROVIDERNAME,
    PROVIDERTYPE,
    FTALENGTHHOURS,
    PROVIDERREGTYPE,
    APPTLENGTHHOURS1,
    _AB_SOURCE_FILE_URL,
    _AB_SOURCE_FILE_LAST_MODIFIED
FROM {{ source('raw_titanium', 'PROVIDER_OUTPUT_SUMMARY') }}

{% endsnapshot %}