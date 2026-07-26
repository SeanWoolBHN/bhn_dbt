WITH cte_trakcare AS (
    SELECT DISTINCT
        SRC_SYS_CLIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CAST(DOB AS VARCHAR)                              AS DOB,
        ADDRESS,
        CITY,
        POSTCODE,
        UPPER(FIRST_NAME || '|' || LAST_NAME || '|' || CAST(DOB AS VARCHAR)
              || '|' || ADDRESS || '|' || CITY || '|' || POSTCODE) AS CLIENT_LINK
    FROM {{ ref('prep_src_client_trakcare') }}
),

cte_best_practice AS (
    SELECT DISTINCT
        SRC_SYS_CLIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CAST(DOB AS VARCHAR)                              AS DOB,
        ADDRESS,
        CITY,
        POSTCODE,
        UPPER(FIRST_NAME || '|' || LAST_NAME || '|' || CAST(DOB AS VARCHAR)
              || '|' || ADDRESS || '|' || CITY || '|' || POSTCODE) AS CLIENT_LINK
    FROM {{ ref('prep_src_client_best_practice') }}
),

cte_echidna AS (
    SELECT DISTINCT
        SRC_SYS_CLIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CAST(DOB AS VARCHAR)                              AS DOB,
        ADDRESS,
        CITY,
        POSTCODE,
        UPPER(FIRST_NAME || '|' || LAST_NAME || '|' || CAST(DOB AS VARCHAR)
              || '|' || ADDRESS || '|' || CITY || '|' || POSTCODE) AS CLIENT_LINK
    FROM {{ ref('prep_src_client_echidna') }}
),

cte_e_tools AS (
    SELECT DISTINCT
        SRC_SYS_CLIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CAST(DOB AS VARCHAR)                              AS DOB,
        ADDRESS,
        CITY,
        POSTCODE,
        UPPER(FIRST_NAME || '|' || LAST_NAME || '|' || CAST(DOB AS VARCHAR)
              || '|' || ADDRESS || '|' || CITY || '|' || POSTCODE) AS CLIENT_LINK
    FROM {{ ref('prep_src_client_e_tools') }}
),

cte_supportability AS (
    SELECT DISTINCT
        SRC_SYS_CLIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CAST(DOB AS VARCHAR)                              AS DOB,
        ADDRESS                                           AS ADDRESS,
        CITY,
        POSTCODE,
        UPPER(FIRST_NAME || '|' || LAST_NAME || '|' || CAST(DOB AS VARCHAR)
              || '|' || ADDRESS || '|' || CITY || '|' || POSTCODE) AS CLIENT_LINK
    FROM {{ ref('prep_src_client_supportability') }}
),

cte_titanium AS (
    SELECT DISTINCT
        SRC_SYS_CLIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CAST(DOB AS VARCHAR)                              AS DOB,
        ADDRESS                                           AS ADDRESS,
        CITY,
        POSTCODE,
        UPPER(FIRST_NAME || '|' || LAST_NAME || '|' || CAST(DOB AS VARCHAR)
              || '|' || ADDRESS || '|' || CITY || '|' || POSTCODE) AS CLIENT_LINK
    FROM {{ ref('prep_src_client_titanium') }}
),

cte_trips AS (
    SELECT DISTINCT
        SRC_SYS_CLIENT_ID,
        FIRST_NAME,
        LAST_NAME,
        CAST(DOB AS VARCHAR)                              AS DOB,
        ADDRESS,
        CITY,
        POSTCODE,
        UPPER(FIRST_NAME || '|' || LAST_NAME || '|' || CAST(DOB AS VARCHAR)
              || '|' || ADDRESS || '|' || CITY || '|' || POSTCODE) AS CLIENT_LINK
    FROM {{ ref('prep_src_client_trips') }}
),

cte_distinct_links AS (
    SELECT DISTINCT
        SHA1(CONCAT_WS('|',
            COALESCE(TC.FIRST_NAME, BP.FIRST_NAME, EC.FIRST_NAME, ET.FIRST_NAME,
                     SU.FIRST_NAME, TI.FIRST_NAME, TR.FIRST_NAME, ''),
            COALESCE(TC.LAST_NAME, BP.LAST_NAME, EC.LAST_NAME, ET.LAST_NAME,
                     SU.LAST_NAME, TI.LAST_NAME, TR.LAST_NAME, ''),
            COALESCE(TC.DOB, BP.DOB, EC.DOB, ET.DOB,
                     SU.DOB, TI.DOB, TR.DOB, ''),
            COALESCE(TC.ADDRESS, BP.ADDRESS, EC.ADDRESS, ET.ADDRESS,
                     SU.ADDRESS, TI.ADDRESS, TR.ADDRESS, ''),
            COALESCE(TC.CITY, BP.CITY, EC.CITY, ET.CITY,
                     SU.CITY, TI.CITY, TR.CITY, ''),
            COALESCE(TC.POSTCODE, BP.POSTCODE, EC.POSTCODE, ET.POSTCODE,
                     SU.POSTCODE, TI.POSTCODE, TR.POSTCODE, '')
        ))                                                AS CLIENT_ID_HASH,
        SHA1(COALESCE(
            TC.CLIENT_LINK, BP.CLIENT_LINK, EC.CLIENT_LINK, ET.CLIENT_LINK,
            SU.CLIENT_LINK, TI.CLIENT_LINK, TR.CLIENT_LINK
        ))                                                AS CLIENT_LINK_HASH,
        TC.SRC_SYS_CLIENT_ID                              AS TRAKCARE_ID,
        BP.SRC_SYS_CLIENT_ID                              AS BEST_PRACTICE_ID,
        EC.SRC_SYS_CLIENT_ID                              AS ECHIDNA_ID,
        ET.SRC_SYS_CLIENT_ID                              AS E_TOOLS_ID,
        SU.SRC_SYS_CLIENT_ID                              AS SUPPORTABILITY_ID,
        TI.SRC_SYS_CLIENT_ID                              AS TITANIUM_ID,
        TR.SRC_SYS_CLIENT_ID                              AS TRIPS_ID

    FROM cte_trakcare                                     AS TC

    FULL OUTER JOIN cte_best_practice                     AS BP
        ON TC.CLIENT_LINK = BP.CLIENT_LINK

    FULL OUTER JOIN cte_echidna                           AS EC
        ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK) = EC.CLIENT_LINK

    FULL OUTER JOIN cte_e_tools                           AS ET
        ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                    EC.CLIENT_LINK) = ET.CLIENT_LINK

    FULL OUTER JOIN cte_supportability                    AS SU
        ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                    EC.CLIENT_LINK, ET.CLIENT_LINK) = SU.CLIENT_LINK

    FULL OUTER JOIN cte_titanium                          AS TI
        ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                    EC.CLIENT_LINK, ET.CLIENT_LINK,
                    SU.CLIENT_LINK) = TI.CLIENT_LINK

    FULL OUTER JOIN cte_trips                             AS TR
        ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                    EC.CLIENT_LINK, ET.CLIENT_LINK,
                    SU.CLIENT_LINK, TI.CLIENT_LINK) = TR.CLIENT_LINK
)

SELECT * FROM cte_distinct_links