{% snapshot HIST_BETTER_IMPACT_PIVOTED_FEEDBACK_REPORT %}

{{
    config(
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'LASTNAME', 'USERNAME', 'FIRSTNAME', 'HOURSWORKED',
            'ACTIVITYNAME', 'DATABASEUSERID', 'DATEVOLUNTEERED',
            'FF_NO_OF_VISITS', 'FF_TYPE_OF_VISIT', 'ACTIVITYCATEGORYNAME',
            'FF_CLIENT_CONCERNS', 'FF_MATCH_END_REASON',
            'FF_NAME_OF_RESIDENT', 'FF_GOOD_NEWS_STORIES',
            'ACTIVITYREPORTGROUPNAME', 'FF_CLIENT_CONCERNS_1',
            'FF_GOOD_NEWS_STORIES_1',
            'FF_IF_NO_VISITS_WERE_MADE_PLEASE_INDICATE_REASON', 'FF_HMS',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
WITH cte_max_gen AS (
    SELECT MAX(_AIRBYTE_GENERATION_ID) AS MAX_GEN
    FROM {{ source('raw_better_impact', 'PIVOTED_FEEDBACK_REPORT') }}
)


SELECT
    *

FROM {{ source('raw_better_impact', 'PIVOTED_FEEDBACK_REPORT') }} pfr
INNER JOIN cte_max_gen mg
    ON mg.MAX_GEN = pfr._AIRBYTE_GENERATION_ID

{% endsnapshot %}