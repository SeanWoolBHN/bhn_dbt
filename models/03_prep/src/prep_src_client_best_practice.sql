SELECT DISTINCT
    'BP'                                                  AS SRC_SYS,
    'BP-' || INTERNAL_ID                                  AS SRC_SYS_CLIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    DOB,
    EMAIL,
    MOBILE_PHONE,
    IFNULL(ADDRESS_1 || IFNULL(', ' || ADDRESS_2, ''), IFNULL(ADDRESS_2, ''))            AS ADDRESS,
    CITY,
    POSTCODE

FROM {{ ref('prep_stg_best_practice_bps_search_result') }}