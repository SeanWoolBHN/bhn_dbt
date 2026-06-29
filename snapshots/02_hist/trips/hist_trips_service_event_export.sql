{% snapshot HIST_TRIPS_SERVICE_EVENT_EXPORT %}

{{
    config(
        schema = 'TRIPS',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'ACL', 'ACR', 'AHC', 'AHH', 'CCL', 'CCR', 'CDC', 'CMG',
            'DAS', 'EOL', 'FLS', 'GAR', 'GCA', 'GCM', 'GMA', 'GOG',
            'GSA', 'GSM', 'MNT', 'MOD', 'MRC', 'MRH', 'NCC', 'NCH',
            'OFS', 'PAG', 'PAH', 'PCR', 'RSC', 'SCL', 'SCR', 'SSP',
            'TRC', 'TRN', 'SYSID', 'FULLNAME', 'RECORDTYPE',
            'LETTERSOFNAME', '_AB_SOURCE_FILE_URL',
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
    ACL, ACR, AHC, AHH, CCL, CCR, CDC, CMG,
    DAS, EOL, FLS, GAR, GCA, GCM, GMA, GOG,
    GSA, GSM, MNT, MOD, MRC, MRH, NCC, NCH,
    OFS, PAG, PAH, PCR, RSC, SCL, SCR, SSP,
    TRC, TRN, SYSID, FULLNAME, RECORDTYPE,
    LETTERSOFNAME,
    _AB_SOURCE_FILE_URL,
    _AB_SOURCE_FILE_LAST_MODIFIED

FROM {{ source('raw_trips', 'SERVICE_EVENT_EXPORT') }}

{% endsnapshot %}