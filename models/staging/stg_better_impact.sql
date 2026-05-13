{{ config(
    materialized='table',
    schema='SANDBOX'
) }}

SELECT
    -- Core date and time fields
    DATEVOLUNTEERED                                         AS date_volunteered,
    CAST(HOURSWORKED AS NUMBER(10,2))                      AS hours_worked,

    -- Activity fields
    ACTIVITYCATEGORYNAME                                    AS activity_category_name,
    ACTIVITYNAME                                            AS activity_name,
    ACTIVITYREPORTGROUPNAME                                 AS activity_report_group_name,

    -- Volunteer identity fields
    DATABASEUSERID                                          AS database_user_id,
    FIRSTNAME                                               AS first_name,
    LASTNAME                                                AS last_name,
    USERNAME                                                AS username,

    -- Free form fields (renamed to remove special characters)
    "FF Client concerns"                                    AS ff_client_concerns,
    "FF -Client Concerns - 1"                              AS ff_client_concerns_1,
    "FF - Good news stories"                               AS ff_good_news_stories,
    "FF - Good news stories - 1"                           AS ff_good_news_stories_1,
    "FF - If no visits were made please indicate reason"   AS ff_no_visits_reason,
    "FF - KMs"                                             AS ff_kms,
    "FF - Match end reason"                                AS ff_match_end_reason,
    "FF - Name of resident"                                AS ff_name_of_resident,
    "FF - No of visits"                                    AS ff_no_of_visits,
    "FF - Type of visit"                                   AS ff_type_of_visit,

    -- Audit fields
    CURRENT_TIMESTAMP()                                     AS dbt_loaded_at

FROM {{ source('raw_sandbox', 'BETTER_IMPACT') }}