{% snapshot HIST_TRIPS_CLIENTS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRIPS',
        unique_key='SYSID',
        strategy='check',
        check_cols=[
            'SYSID',
            'ACCOUNTCODE',
            'DLNUMBER',
            'UPDATEFLAG',
            'EXITFLAG',
            'ENTRYDATE',
            'EXITDATE',
            'LASTASSESS',
            'DATEOFBIRTH',
            'CLIENTNAME',
            'TITLE',
            'SURNAME',
            'GIVENNAME',
            'PREFNAME',
            'SEX',
            'STREET',
            'TOWN',
            'STATE',
            'POSTCODE',
            'LGA',
            'ZONE',
            'MAPREF',
            'PHONE',
            'SILENTPHONE',
            'CLIENT_WORK_PHONE',
            'CLIENT_MOBILE_PHONE',
            'CLIENT_EMAIL',
            'WHEELCHAIR',
            'HOIST',
            'SPECIAL',
            'SENDACCOUNT',
            'FUNDSOURCE',
            'PAIDBY',
            'CLIENTCLASS',
            'PROFILE',
            'PRIORITY',
            'SUPPORT',
            'PENSIONNUM',
            'DVANUM',
            'NEWSLCODE',
            'SPECIALNEEDS',
            'COUNTRYOFBIRTH',
            'LIVINGARRANGMENTS',
            'ACCOMMODATIONTYPE',
            'REFERRALSOURCE',
            'HOMELANGUAGE',
            'COMMENT',
            'AGE',
            'LAST_VERIFIED_TRIP_DATE',
            'INDIGENOUS_STATUS',
            'LINKED_CARER_NAME',
            'LINKED_CARER_ACCOUNT_CODE',
            'CONSENT_TO_PROVIDE_DETAILS',
            'CONSENT_FOR_FUTURE_CONTACTS',
            'INTERESTED_IN_SHARING_STORY'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trips', 'TRIPS_CLIENTS') }}

{% endsnapshot %}