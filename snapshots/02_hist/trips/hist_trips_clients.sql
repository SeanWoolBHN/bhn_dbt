{% snapshot HIST_TRIPS_CLIENTS %}

{{
    config(
        unique_key='SYSID',
        strategy='check',
        check_cols=[
            'AGE', 'LGA', 'SEX', 'TOWN', 'ZONE', 'HOIST', 'PHONE',
            'STATE', 'SYSID', 'TITLE', 'DVANUM', 'MAPREF', 'PAIDBY',
            'STREET', 'COMMENT', 'PROFILE', 'SPECIAL', 'SUPPORT',
            'SURNAME', 'DLNUMBER', 'EXITDATE', 'EXITFLAG', 'POSTCODE',
            'PREFNAME', 'PRIORITY', 'UNIQUEID', 'ENTRYDATE', 'GIVENNAME',
            'NEWSLCODE', 'CLIENTNAME', 'FUNDSOURCE', 'LASTASSESS',
            'PENSIONNUM', 'UPDATEFLAG', 'WHEELCHAIR', 'ACCOUNTCODE',
            'CLIENTCLASS', 'DATEOFBIRTH', 'SENDACCOUNT', 'SILENTPHONE',
            'CLIENT_EMAIL', 'HOMELANGUAGE', 'SPECIALNEEDS',
            'COUNTRYOFBIRTH', 'REFERRALSOURCE', 'ACCOMMODATIONTYPE',
            'CLIENT_WORK_PHONE', 'INDIGENOUS_STATUS', 'LINKED_CARER_NAME',
            'LIVINGARRANGMENTS', 'CLIENT_MOBILE_PHONE',
            'LAST_VERIFIED_TRIP_DATE', 'LINKED_CARER_ACCOUNT_CODE',
            'CONSENT_TO_PROVIDE_DETAILS', 'CONSENT_FOR_FUTURE_CONTACTS',
            'INTERESTED_IN_SHARING_STORY',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trips', 'TRIPS_CLIENTS') }}
QUALIFY ROW_NUMBER() OVER (PARTITION BY SYSID ORDER BY _AIRBYTE_GENERATION_ID DESC) = 1

{% endsnapshot %}