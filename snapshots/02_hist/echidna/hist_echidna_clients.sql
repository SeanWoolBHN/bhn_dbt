{% snapshot HIST_ECHIDNA_CLIENTS %}

{{
    config(
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'EMAIL', 'STATE', 'GENDER', 'SUBURB', 'ADDRESS', 'SUBURNE',
            'PHONE_NO', 'POSTCODE', 'AGE_YEARS', 'AGE_MONTHS',
            'PHONE_NUMBER', 'DOB_ESTIMATED', 'DATE_OF_BIRTH',
            'CLIENT_SURNAME', 'CONTACT_SURNAME', 'DATE_OF_REFERRAL',
            'CLIENT_FIRST_NAME', 'PRIMARY_DIAGNOSIS', 'CLIENT_MIDDLE_NAME',
            'CONTACT_FIRST_NAME', 'RELATIONSHIP_TO_CLIENT',
            'MAIN_LANGUAGE_SPOKEN_AT_HOME',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

WITH cte_max_gen AS (
    SELECT MAX(_AIRBYTE_GENERATION_ID) AS MAX_GEN
    FROM {{ source('raw_echidna', 'ECHIDNA_CLIENTS') }}
)

SELECT
    ec.*
FROM {{ source('raw_echidna', 'ECHIDNA_CLIENTS') }} ec
INNER JOIN cte_max_gen mg
    ON mg.MAX_GEN = ec._AIRBYTE_GENERATION_ID

{% endsnapshot %}