{% snapshot HIST_SUPPORTABILITY_CLIENT_LIST_INC_PERSONAL_CONTACTS %}

{{
    config(
        schema='SUPPORTABILITY',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'AGE', 'LGA', 'ATSI', 'TAGS', 'STATE', 'GENDER', 'REGION',
            'SUBURB', 'ADDRESS', 'LANGUAGE', 'POSTCODE', 'RELATIONSHIP',
            'END_DATE', 'DEBTOR_ID', 'LAST_NAME', 'FIRST_NAME',
            'HOME_PHONE', 'START_DATE', 'NDIS_NUMBER', 'RECORD_TYPE',
            'MOBILE_PHONE', 'DATE_OF_BIRTH', 'EMAIL_ADDRESS',
            'REASON_FOR_EXIT', 'COUNTRY_OF_BIRTH', 'CARER_PREFERENCES',
            'LAST_JOURNAL_DATE', 'SUPPORTABILITY_ID', 'IS_BILLING_CONTACT',
            'IS_PRIMARY_CONTACT', 'LAST_ACTIVITY_DATE', 'PRIMARY_DISABILITY',
            'LABOUR_FORCE_STATUS', 'LIVING_ARRANGEMENTS',
            'HOUSEHOLD_COMPOSITION', 'IS_REGISTERED_TO_VOTE',
            'HIGHEST_LEVEL_OF_EDUCATION', 'UNIQUE_STUDENT_IDENTIFIER_USI_',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_supportability', 'CLIENT_LIST_INC_PERSONAL_CONTACTS') }}

{% endsnapshot %}