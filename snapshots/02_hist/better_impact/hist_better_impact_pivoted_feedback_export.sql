{% snapshot HIST_BETTER_IMPACT_PIVOTED_FEEDBACK_REPORT %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='BETTER_IMPACT',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            '"FF - KMS"',
            'LASTNAME',
            'USERNAME',
            'FIRSTNAME',
            'HOURSWORKED',
            'ACTIVITYNAME',
            'DATABASEUSERID',
            'DATEVOLUNTEERED',
            '"FF - NO OF VISITS"',
            '"FF - TYPE OF VISIT"',
            'ACTIVITYCATEGORYNAME',
            '"FF - CLIENT CONCERNS"',
            '"FF - MATCH END REASON"',
            '"FF - NAME OF RESIDENT"',
            '"FF - GOOD NEWS STORIES"',
            'ACTIVITYREPORTGROUPNAME',
            '"FF - CLIENT CONCERNS - 1"',
            '"FF - GOOD NEWS STORIES - 1"',
            '"FF - IF NO VISITS WERE MADE PLEASE INDICATE REASON"',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    _AIRBYTE_RAW_ID,
    _AIRBYTE_EXTRACTED_AT,
    _AIRBYTE_META,
    _AIRBYTE_GENERATION_ID,
    "FF - KMS",
    LASTNAME,
    USERNAME,
    FIRSTNAME,
    HOURSWORKED,
    ACTIVITYNAME,
    DATABASEUSERID,
    DATEVOLUNTEERED,
    "FF - NO OF VISITS",
    "FF - TYPE OF VISIT",
    _AB_SOURCE_FILE_URL,
    ACTIVITYCATEGORYNAME,
    "FF - CLIENT CONCERNS",
    "FF - MATCH END REASON",
    "FF - NAME OF RESIDENT",
    "FF - GOOD NEWS STORIES",
    ACTIVITYREPORTGROUPNAME,
    "FF - CLIENT CONCERNS - 1",
    "FF - GOOD NEWS STORIES - 1",
    _AB_SOURCE_FILE_LAST_MODIFIED,
    "FF - IF NO VISITS WERE MADE PLEASE INDICATE REASON",
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_better_impact', 'PIVOTED_FEEDBACK_REPORT') }}

{% endsnapshot %}