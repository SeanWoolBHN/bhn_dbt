{% snapshot HIST_CONNX_EMPLOYEE_DEMOGRAPHICS %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='CONNX',
        unique_key='DEMOGRAPHICS_KEY',
        strategy='check',
        check_cols=[
            'DEPARTMENT',
            'GENDER',
            'DOB',
            'ETHNICITY',
            'NATIONALITY',
            'LANGUAGES_SPOKEN',
            'POSTCODE'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

WITH source AS (
    SELECT
        DEPARTMENT,
        GENDER,
        DOB,
        ETHNICITY,
        NATIONALITY,
        LANGUAGES_SPOKEN,
        POSTCODE
    FROM {{ source('raw_connx', 'EMPLOYEE_DEMOGRAPHICS') }}
)

SELECT
    MD5(
        COALESCE(DEPARTMENT, 'unknown')         || '-' ||
        COALESCE(GENDER, 'unknown')             || '-' ||
        COALESCE(DOB, 'unknown')                || '-' ||
        COALESCE(ETHNICITY, 'unknown')          || '-' ||
        COALESCE(NATIONALITY, 'unknown')        || '-' ||
        COALESCE(LANGUAGES_SPOKEN, 'unknown')   || '-' ||
        COALESCE(POSTCODE, 'unknown')
    )                                           AS DEMOGRAPHICS_KEY,
    *,
    CURRENT_TIMESTAMP()                         AS _stg_loaded_at

FROM source

{% endsnapshot %}