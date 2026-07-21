SELECT DISTINCT
    'TRIPS'                                               AS SRC_SYS,
    'TR-' || TRIPS_ID                                     AS SRC_SYS_CLIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    DOB,
    EMAIL,
    MOBILE_PHONE,
    STREET                                                AS ADDRESS,
    CITY,
    POSTCODE

FROM {{ ref('prep_stg_trips_clients') }}

WHERE FIRST_NAME IS NOT NULL
  AND LAST_NAME IS NOT NULL