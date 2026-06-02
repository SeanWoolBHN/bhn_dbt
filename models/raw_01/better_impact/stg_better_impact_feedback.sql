-- models/staging/stg_better_impact_feedback.sql

WITH source AS (
    SELECT * FROM {{ source('raw_better_impact', 'PIVOTED_FEEDBACK_EXPORT') }}
),

cleaned AS (
    SELECT
        -- Surrogate Key
        MD5(
            CAST(DATABASEUSERID AS VARCHAR) || '-' ||
            CAST(DATEVOLUNTEERED AS VARCHAR) || '-' ||
            COALESCE(ACTIVITYNAME, 'unknown')
        )                                                       AS feedback_key,

        -- Volunteer Identity
        CAST(DATABASEUSERID AS VARCHAR)                         AS database_user_id,
        TRIM(NULLIF(FIRSTNAME, ''))                             AS first_name,
        TRIM(NULLIF(LASTNAME, ''))                              AS last_name,
        TRIM(LOWER(NULLIF(USERNAME, '')))                       AS username,

        -- Activity Details
        DATEVOLUNTEERED                                         AS date_volunteered,
        HOURSWORKED                                             AS hours_worked,
        TRIM(NULLIF(ACTIVITYCATEGORYNAME, ''))                  AS activity_category_name,
        TRIM(NULLIF(ACTIVITYNAME, ''))                          AS activity_name,
        TRIM(NULLIF(ACTIVITYREPORTGROUPNAME, ''))               AS activity_report_group_name,

        -- Freeform Fields
        TRIM(NULLIF("FF - Client concerns", ''))                AS ff_client_concerns,
        TRIM(NULLIF("FF - Client Concerns - 1", ''))            AS ff_client_concerns_1,
        TRIM(NULLIF("FF - Good news stories", ''))              AS ff_good_news_stories,
        TRIM(NULLIF("FF - Good news stories - 1", ''))          AS ff_good_news_stories_1,
        TRIM(NULLIF("FF - If no visits were made please indicate reason", '')) AS ff_no_visit_reason,
        TRIM(NULLIF("FF - KMs", ''))                            AS ff_kms,
        TRIM(NULLIF("FF - Match end reason", ''))               AS ff_match_end_reason,
        TRIM(NULLIF("FF - Name of resident", ''))               AS ff_name_of_resident,
        TRIM(NULLIF("FF - No of visits", ''))                   AS ff_no_of_visits,
        TRIM(NULLIF("FF - Type of visit", ''))                  AS ff_type_of_visit,

        -- Metadata
        CURRENT_TIMESTAMP()                                     AS _stg_loaded_at

    FROM source
)

SELECT * FROM cleaned