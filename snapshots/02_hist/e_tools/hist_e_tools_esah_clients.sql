{% snapshot HIST_E_TOOLS_ESAH_CLIENTS %}

{{
    config(
        schema='E_TOOLS',
        unique_key='EPISODE_ID',
        strategy='check',
        check_cols=[
            'S_NO', 'OUTLET', 'STATUS', 'PARTICIPANT_ID',
            'CARE_RECIPIENT_ID', 'TITLE', 'FIRST_NAME', 'LAST_NAME',
            'BUDGET_CLASSIFICATION_AS_AT_REPORT_DATE',
            'INTERIM_OR_FULL_SERVICE_OFFER_AS_AT_REPORT_DATE',
            'SUBURB', 'ADDRESS_LINE_1', 'ADDRESS_LINE_2', 'STATE',
            'POSTCODE', 'EMAIL', 'CARE_MANAGER', 'CARE_PARTNER',
            'PHONE', 'MOBILE', 'DATE_OF_BIRTH',
            'PAYOR_PROGRAMME_CLASSIFICATION_LEVEL',
            'START_DATE', 'ONGOING_BUDGET', 'RESTORATIVE_CARE',
            'END_OF_LIFE', 'ASSISTIVE_TECHNOLOGY', 'HOME_MODIFICATION',
            'CLIENT_FUNDED', 'DISCHARGED_DATE', 'DISCHARGED_REASON',
            'MAC_ID', 'IS_VULNERABLE', 'REASSESSMENT_DATE',
            'ASSESSMENT_TYPE', 'ASSESSMENT_DATE',
            'CARE_PLAN_REVIEW_TYPE', 'CARE_PLAN_REVIEW_DATE',
            'PREFERRED_METHOD_OF_CONTACT',
            'ABORIGINAL_OR_TORRES_STRAIT_ISLANDER_ORIGIN'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_e_tools', 'ESAH_CLIENTS') }}

{% endsnapshot %}