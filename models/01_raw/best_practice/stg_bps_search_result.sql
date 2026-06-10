-- models/raw_01/best_practice/stg_bps_search_result.sql

WITH source AS (
    SELECT * FROM {{ source('raw_best_practise', 'BPS_SEARCH_RESULT') }}
)

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM source