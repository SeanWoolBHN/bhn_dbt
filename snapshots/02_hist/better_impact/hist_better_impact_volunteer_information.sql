{% snapshot HIST_BETTER_IMPACT_VOLUNTEER_INFORMATION %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='BETTER_IMPACT',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'BIRTHDAY', 'LASTNAME', 'FIRSTNAME', 'POSTALCODE',
            'DATABASEUSERID', 'VOLUNTEERSTATUS', 'VOLUNTEERDATEJOINED',
            'DATEOFLASTVOLUNTEERSTATUSCHANGE',
            'CF_ABOUT_YOU_PLEASE_INDICATE_YOUR_GENDER',
            '"CF_SPECIAL_NEEDS_GROUPS_(THIS_INFORMATION_IS_REQUESTED_BY_THE_DEPT._OF_HEALTH)_IF_MORE_THAN_ONE_SPECIAL_NEED_APPLIES_PLEASE_LIST_HERE"',
            '"CF_SPECIAL_NEEDS_GROUPS_(THIS_INFORMATION_IS_REQUESTED_BY_THE_DEPT._OF_HEALTH)_DOES_THE_RECIPIENT_IDENTIFY_AS_BEING_FROM_A_SPECIAL_NEEDS_GROUP?"',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_better_impact', 'VOLUNTEER_INFORMATION') }}

{% endsnapshot %}