{% snapshot HIST_ECHIDNA_CLIENTS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='ECHIDNA',
        unique_key='CLIENT_KEY',
        strategy='check',
        check_cols=[
            'CLIENT_FIRST_NAME',
            'CLIENT_MIDDLE_NAME',
            'CLIENT_SURNAME',
            'DATE_OF_BIRTH',
            'DOB_ESTIMATED',
            'AGE_YEARS',
            'AGE_MONTHS',
            'GENDER',
            'MAIN_LANGUAGE_SPOKEN_AT_HOME_ID',
            'PRIMARY_DIAGNOSIS',
            'PHONE_NUMBER',
            'EMAIL',
            'ADDRESS',
            'SUBURB',
            'POSTCODE',
            'STATE',
            'CONTACT_FIRST_NAME',
            'CONTACT_SURNAME',
            'RELATIONSHIP_TO_CLIENT',
            'MAIN_LANGUAGE_SPOKEN_AT_HOME',
            'PHONE_NO',
            'ADDRESS_2',
            'SUBURNE_2',
            'POSTCODE_2',
            'STATE_2',
            'DATE_OF_REFERRAL'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    MD5(
        COALESCE(CLIENT_FIRST_NAME, 'unknown')              || '-' ||
        COALESCE(CLIENT_SURNAME, 'unknown')                 || '-' ||
        COALESCE(CAST(DATE_OF_BIRTH AS VARCHAR), 'unknown') || '-' ||
        COALESCE(EMAIL, 'unknown')                          || '-' ||
        COALESCE(ADDRESS, 'unknown')
    )                                   AS CLIENT_KEY,
    *,
    CURRENT_TIMESTAMP()                 AS _stg_loaded_at

FROM {{ source('raw_echidna', 'ECHIDNA_CLIENTS') }}

{% endsnapshot %}