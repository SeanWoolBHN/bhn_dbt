{% snapshot HIST_TITANIUM_PATIENT_DETAIL_REPORT %}

{{
    config(
        schema = 'TITANIUM',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'DR_',
            'FIRSTNAME',
            'LASTNAME',
            'SLK',
            'DOB',
            'SEX',
            'CARDTYPE',
            'ABORIGINALITY',
            'REFUGEE',
            'ASYLUMSEEKER',
            'ADDRESS',
            'SUBURB',
            'POSTCODE',
            'HOMEPHONE',
            'MOBILEPHONE',
            'MEDICARENUMBER',
            'MEDICARESUFFIX',
            'ACCOMMODATION',
            'ELIGIBLE_CHILD_OR_YOUNG_PERSON',
            'ELIGIBLE_PREGNANT_WOMAN',
            'CHILD_OR_YOUNG_PERSON_IN_RESIDENTIAL_CARE',
            'NO_PRIORITY',
            'YOUTH_JUSTICE_CLIENT_IN_CUSTODIAL_CARE',
            'ABORIGINAL_TORRES_STRAIT_ISLANDER',
            'ASYLUM_SEEKER',
            'REFUGEE_PRIORITY',
            'MENTAL_HEALTH_CLIENT',
            'INTELLECTUAL_DISABILITY_CLIENT',
            'HOMELESS_PERSON',
            'EMPTY_VALUE_PRIORITY',
            'INTERPRETERREQ',
            'COUNTRY',
            'LANGUAGE',
            'SCHOOL',
            'RISKSTATUS',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_titanium', 'PATIENT_DETAIL_REPORT') }}

{% endsnapshot %}