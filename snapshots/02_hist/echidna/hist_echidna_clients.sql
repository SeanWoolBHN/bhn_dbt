{% snapshot HIST_ECHIDNA_CLIPS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='ECHIDNA',
        unique_key='CLIENT_KEY',
        strategy='check',
        check_cols=[
            '"CLIENT FIRST NAME"',
            '"CLIENT MIDDLE NAME"',
            '"CLIENT SURNAME"',
            '"DATE OF BIRTH"',
            '"DOB ESTIMATED"',
            '"AGE YEARS"',
            '"AGE MONTHS"',
            'GENDER',
            '"PRIMARY DIAGNOSIS"',
            '"PHONE NUMBER"',
            'EMAIL',
            'ADDRESS',
            'SUBURB',
            'POSTCODE',
            'STATE',
            '"CONTACT FIRST NAME"',
            '"CONTACT SURNAME"',
            '"RELATIONSHIP TO CLIENT"',
            '"MAIN LANGUAGE SPOKEN AT HOME"',
            '"PHONE NO"',
            'SUBURNE',
            '"DATE OF REFERRAL"'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

WITH source AS (
    SELECT
        _AIRBYTE_RAW_ID,
        _AIRBYTE_EXTRACTED_AT,
        _AIRBYTE_META,
        _AIRBYTE_GENERATION_ID,
        "CLIENT FIRST NAME",
        "CLIENT MIDDLE NAME",
        "CLIENT SURNAME",
        "DATE OF BIRTH",
        "DOB ESTIMATED",
        "AGE YEARS",
        "AGE MONTHS",
        GENDER,
        "PRIMARY DIAGNOSIS",
        "PHONE NUMBER",
        EMAIL,
        ADDRESS,
        SUBURB,
        POSTCODE,
        STATE,
        "CONTACT FIRST NAME",
        "CONTACT SURNAME",
        "RELATIONSHIP TO CLIENT",
        "MAIN LANGUAGE SPOKEN AT HOME",
        "PHONE NO",
        SUBURNE,
        "DATE OF REFERRAL",
        _AB_SOURCE_FILE_URL,
        _AB_SOURCE_FILE_LAST_MODIFIED
    FROM {{ source('raw_echidna', 'ECHIDNA_CLIENTS') }}
)

SELECT
    MD5(
        COALESCE("CLIENT FIRST NAME", 'unknown')    || '-' ||
        COALESCE("CLIENT SURNAME", 'unknown')       || '-' ||
        COALESCE("DATE OF BIRTH", 'unknown')        || '-' ||
        COALESCE(EMAIL, 'unknown')                  || '-' ||
        COALESCE(ADDRESS, 'unknown')                || '-' ||
        COALESCE("CONTACT FIRST NAME", 'unknown')
    )                                               AS CLIENT_KEY,
    *,
    CURRENT_TIMESTAMP()                             AS _stg_loaded_at

FROM source

{% endsnapshot %}