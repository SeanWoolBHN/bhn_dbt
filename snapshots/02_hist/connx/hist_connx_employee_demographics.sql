{% snapshot HIST_CONNX_EMPLOYEE_DEMOGRAPHICS %}

{{
    config(
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'DOB', 'GENDER', 'POSTCODE', 'DEPARTMENT', 'NATIONALITY',
            'LANGUAGES_SPOKEN', 'ETHNICITY',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

WITH cte_max_gen AS (
    SELECT MAX(_AIRBYTE_GENERATION_ID) AS MAX_GEN
    FROM {{ source('raw_connx', 'EMPLOYEE_DEMOGRAPHICS') }}
)

SELECT
    ed.*

FROM {{ source('raw_connx', 'EMPLOYEE_DEMOGRAPHICS') }} ed
INNER JOIN cte_max_gen mg
    ON mg.MAX_GEN = ed._AIRBYTE_GENERATION_ID

{% endsnapshot %}