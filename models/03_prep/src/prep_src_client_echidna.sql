WITH cte_client_id AS (
    SELECT
        FIRST_NAME,
        LAST_NAME,
        DOB,
        IFNULL(FIRST_NAME, 'FIRST')
        || IFNULL(LAST_NAME, 'LAST')
        || IFNULL(CAST(DOB AS VARCHAR), 'DOB')          AS CLIENT_DETAILS,
        ROW_NUMBER() OVER (
            ORDER BY
                IFNULL(FIRST_NAME, 'FIRST')
                || IFNULL(LAST_NAME, 'LAST')
                || IFNULL(CAST(DOB AS VARCHAR), 'DOB')
        )                                               AS ROW_NUM
    FROM (
        SELECT DISTINCT
            FIRST_NAME,
            LAST_NAME,
            DOB
        FROM {{ ref('prep_stg_echidna_clients') }}
    ) AS deduped
)

SELECT DISTINCT
    'ECHIDNA'                                             AS SRC_SYS,
    'EC-' || CTE.ROW_NUM                                  AS SRC_SYS_CLIENT_ID,
    EC.FIRST_NAME,
    EC.LAST_NAME,
    EC.DOB,
    EC.EMAIL,
    COALESCE(EC.PHONE_NO, EC.PHONE_NO_2)                  AS MOBILE_PHONE,
    EC.ADDRESS_1                                          AS ADDRESS,
    COALESCE(EC.CITY, EC.CITY_2)                          AS CITY,
    EC.POSTCODE

FROM cte_client_id                                        AS CTE

INNER JOIN {{ ref('prep_stg_echidna_clients') }}          AS EC
    ON CTE.CLIENT_DETAILS = IFNULL(EC.FIRST_NAME, 'FIRST')
                         || IFNULL(EC.LAST_NAME, 'LAST')
                         || IFNULL(CAST(EC.DOB AS VARCHAR), 'DOB')