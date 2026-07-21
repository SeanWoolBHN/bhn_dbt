WITH cte_trakcare AS (
    SELECT DISTINCT
        'TRAKCARE'                                        AS SRC_SYS,
        SRC_SYS_CLIENT_ID,
        FIRST_NAME || LAST_NAME || CAST(DOB AS VARCHAR)
            || ADDRESS || CITY || POSTCODE                AS CLIENT_MATCH
    FROM {{ ref('prep_src_client_trakcare') }}
),

cte_best_practice AS (
    SELECT DISTINCT
        'BEST_PRACTICE'                                   AS SRC_SYS,
        SRC_SYS_CLIENT_ID,
        FIRST_NAME || LAST_NAME || CAST(DOB AS VARCHAR)
            || ADDRESS || CITY || POSTCODE                AS CLIENT_MATCH
    FROM {{ ref('prep_src_client_best_practice') }}
),

cte_echidna AS (
    SELECT DISTINCT
        'ECHIDNA'                                         AS SRC_SYS,
        SRC_SYS_CLIENT_ID,
        FIRST_NAME || LAST_NAME || CAST(DOB AS VARCHAR)
            || ADDRESS || CITY || POSTCODE                AS CLIENT_MATCH
    FROM {{ ref('prep_src_client_echidna') }}
),

cte_e_tools AS (
    SELECT DISTINCT
        'E_TOOLS'                                         AS SRC_SYS,
        SRC_SYS_CLIENT_ID,
        FIRST_NAME || LAST_NAME || CAST(DOB AS VARCHAR)
            || ADDRESS || CITY || POSTCODE                AS CLIENT_MATCH
    FROM {{ ref('prep_src_client_e_tools') }}
),

cte_supportability AS (
    SELECT DISTINCT
        'SUPPORTABILITY'                                  AS SRC_SYS,
        SRC_SYS_CLIENT_ID,
        FIRST_NAME || LAST_NAME || CAST(DOB AS VARCHAR)
            || ADDRESS_1 || CITY || POSTCODE                AS CLIENT_MATCH
    FROM {{ ref('prep_src_client_supportability') }}
),

cte_titanium AS (
    SELECT DISTINCT
        'TITANIUM'                                        AS SRC_SYS,
        SRC_SYS_CLIENT_ID,
        FIRST_NAME || LAST_NAME || CAST(DOB AS VARCHAR)
            || ADDRESS_1 || CITY || POSTCODE                AS CLIENT_MATCH
    FROM {{ ref('prep_src_client_titanium') }}
),

cte_trips AS (
    SELECT DISTINCT
        'TRIPS'                                           AS SRC_SYS,
        SRC_SYS_CLIENT_ID,
        FIRST_NAME || LAST_NAME || CAST(DOB AS VARCHAR)
            || ADDRESS || CITY || POSTCODE                AS CLIENT_MATCH
    FROM {{ ref('prep_src_client_trips') }}
)

SELECT DISTINCT
    MD5(COALESCE(
        TC.CLIENT_MATCH,
        BP.CLIENT_MATCH,
        EC.CLIENT_MATCH,
        ET.CLIENT_MATCH,
        SU.CLIENT_MATCH,
        TI.CLIENT_MATCH,
        TR.CLIENT_MATCH
    ))                                                   AS CLIENT_ID,
    TC.SRC_SYS_CLIENT_ID                                  AS TRAKCARE_ID,
    BP.SRC_SYS_CLIENT_ID                                  AS BEST_PRACTICE_ID,
    EC.SRC_SYS_CLIENT_ID                                  AS ECHIDNA_ID,
    ET.SRC_SYS_CLIENT_ID                                  AS E_TOOLS_ID,
    SU.SRC_SYS_CLIENT_ID                                  AS SUPPORTABILITY_ID,
    TI.SRC_SYS_CLIENT_ID                                  AS TITANIUM_ID,
    TR.SRC_SYS_CLIENT_ID                                  AS TRIPS_ID

FROM cte_trakcare                                         AS TC

FULL OUTER JOIN cte_best_practice                         AS BP
    ON TC.CLIENT_MATCH = BP.CLIENT_MATCH

FULL OUTER JOIN cte_echidna                               AS EC
    ON COALESCE(TC.CLIENT_MATCH, BP.CLIENT_MATCH) = EC.CLIENT_MATCH

FULL OUTER JOIN cte_e_tools                               AS ET
    ON COALESCE(TC.CLIENT_MATCH, BP.CLIENT_MATCH,
                EC.CLIENT_MATCH) = ET.CLIENT_MATCH

FULL OUTER JOIN cte_supportability                        AS SU
    ON COALESCE(TC.CLIENT_MATCH, BP.CLIENT_MATCH,
                EC.CLIENT_MATCH, ET.CLIENT_MATCH) = SU.CLIENT_MATCH

FULL OUTER JOIN cte_titanium                              AS TI
    ON COALESCE(TC.CLIENT_MATCH, BP.CLIENT_MATCH,
                EC.CLIENT_MATCH, ET.CLIENT_MATCH,
                SU.CLIENT_MATCH) = TI.CLIENT_MATCH

FULL OUTER JOIN cte_trips                                 AS TR
    ON COALESCE(TC.CLIENT_MATCH, BP.CLIENT_MATCH,
                EC.CLIENT_MATCH, ET.CLIENT_MATCH,
                SU.CLIENT_MATCH, TI.CLIENT_MATCH) = TR.CLIENT_MATCH