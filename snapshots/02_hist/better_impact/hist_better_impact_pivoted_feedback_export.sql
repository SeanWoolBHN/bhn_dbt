{% snapshot HIST_BETTER_IMPACT_PIVOTED_FEEDBACK_EXPORT %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='BETTER_IMPACT',
        unique_key='FEEDBACK_KEY',
        strategy='check',
        check_cols=[
            'DATABASEUSERID',
            'DATEVOLUNTEERED',
            'ACTIVITYCATEGORYNAME',
            'ACTIVITYNAME',
            'FIRSTNAME',
            'LASTNAME',
            'USERNAME',
            'ACTIVITYREPORTGROUPNAME',
            'HOURSWORKED',
            '"FF - Client concerns"',
            '"FF - Client Concerns - 1"',
            '"FF - Good news stories"',
            '"FF - Good news stories - 1"',
            '"FF - If no visits were made please indicate reason"',
            '"FF - KMs"',
            '"FF - Match end reason"',
            '"FF - Name of resident"',
            '"FF - No of visits"',
            '"FF - Type of visit"'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

WITH source AS (
    SELECT
        DATABASEUSERID,
        DATEVOLUNTEERED,
        ACTIVITYCATEGORYNAME,
        ACTIVITYNAME,
        FIRSTNAME,
        LASTNAME,
        USERNAME,
        ACTIVITYREPORTGROUPNAME,
        HOURSWORKED,
        "FF - Client concerns",
        "FF - Client Concerns - 1",
        "FF - Good news stories",
        "FF - Good news stories - 1",
        "FF - If no visits were made please indicate reason",
        "FF - KMs",
        "FF - Match end reason",
        "FF - Name of resident",
        "FF - No of visits",
        "FF - Type of visit",
        ROW_NUMBER() OVER (
            PARTITION BY
                DATABASEUSERID,
                DATEVOLUNTEERED,
                ACTIVITYNAME,
                "FF - Name of resident"
            ORDER BY HOURSWORKED
        ) AS row_num
    FROM {{ source('raw_better_impact', 'PIVOTED_FEEDBACK_EXPORT') }}
)

SELECT
    MD5(
        CAST(DATABASEUSERID AS VARCHAR)                     || '-' ||
        CAST(DATEVOLUNTEERED AS VARCHAR)                    || '-' ||
        COALESCE(ACTIVITYNAME, 'unknown')                   || '-' ||
        COALESCE("FF - Name of resident", 'unknown')        || '-' ||
        CAST(row_num AS VARCHAR)
    )                                                       AS FEEDBACK_KEY,
    DATABASEUSERID,
    DATEVOLUNTEERED,
    ACTIVITYCATEGORYNAME,
    ACTIVITYNAME,
    FIRSTNAME,
    LASTNAME,
    USERNAME,
    ACTIVITYREPORTGROUPNAME,
    HOURSWORKED,
    "FF - Client concerns",
    "FF - Client Concerns - 1",
    "FF - Good news stories",
    "FF - Good news stories - 1",
    "FF - If no visits were made please indicate reason",
    "FF - KMs",
    "FF - Match end reason",
    "FF - Name of resident",
    "FF - No of visits",
    "FF - Type of visit",
    CURRENT_TIMESTAMP()                                     AS _stg_loaded_at

FROM source

{% endsnapshot %}