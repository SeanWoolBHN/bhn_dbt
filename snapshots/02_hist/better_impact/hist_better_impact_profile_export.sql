{% snapshot HIST_BETTER_IMPACT_PROFILE_EXPORT %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='BETTER_IMPACT',
        unique_key='DATABASEUSERID',
        strategy='check',
        check_cols=[
            'FIRSTNAME',
            'LASTNAME',
            'LEGALFIRSTNAME',
            'MIDDLENAME',
            'SALUTATION',
            'SUFFIX',
            'POSTALCODE',
            'EMAILADDRESS',
            'USERNAME',
            'BIRTHDAY',
            'AGE',
            'CLIENTSTATUS',
            'DATEOFLASTCLIENTSTATUSCHANGE',
            'CLIENTDATEJOINED',
            'YEARSSINCECLIENTDATEJOINED',
            '"CF - Aged Care Facility match information  - Aged care facility (list)"',
            '"CF - Aged Care Funding Details - If relevant select name of Home Care Package Provider or Residential Aged Care Facility where the client resides"',
            '"CF - About Your Client - Gender"',
            '"CF - About Your Client - Country of origin"',
            '"CF - About Your Client - Preferred language"',
            '"CF - About Your Client - Work background"',
            '"CF - Special needs groups (this information is requested by the Dept. of Health) - Does the recipient identify as being from a special needs group?"',
            '"CF - Special needs groups (this information is requested by the Dept. of Health) - If more than one special need applies please list here"',
            '"CF - Match details - Date of match"',
            '"CF - Match details - Name of visitor"',
            '"CF - Match details - Potential volunteer"'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_better_impact', 'PROFILE_EXPORT') }}

{% endsnapshot %}