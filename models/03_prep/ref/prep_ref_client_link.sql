{{ config(materialized='table') }}

WITH cte_trakcare AS (    
    SELECT DISTINCT
	    SRC_SYS_CLIENT_ID,
        CLIENT_ID_RAW,
        CLIENT_LINK_RAW,
        CLIENT_ID,
        CLIENT_LINK     
    FROM {{ ref('prep_ref_client_link_details') }}
    WHERE SRC_SYS = 'TRAKCARE'
),

cte_best_practice AS (    
    SELECT DISTINCT
	    SRC_SYS_CLIENT_ID,
        CLIENT_ID_RAW,
        CLIENT_LINK_RAW,
        CLIENT_ID,
        CLIENT_LINK     
    FROM {{ ref('prep_ref_client_link_details') }}
    WHERE SRC_SYS = 'BEST_PRACTICE'
),

cte_echidna AS (    
    SELECT DISTINCT
	    SRC_SYS_CLIENT_ID,
        CLIENT_ID_RAW,
        CLIENT_LINK_RAW,
        CLIENT_ID,
        CLIENT_LINK     
    FROM {{ ref('prep_ref_client_link_details') }}
    WHERE SRC_SYS = 'ECHIDNA'
),

cte_e_tools AS (    
    SELECT DISTINCT
	    SRC_SYS_CLIENT_ID,
        CLIENT_ID_RAW,
        CLIENT_LINK_RAW,
        CLIENT_ID,
        CLIENT_LINK     
    FROM {{ ref('prep_ref_client_link_details') }}
    WHERE SRC_SYS = 'E_TOOLS'
),

cte_supportability AS (    
    SELECT DISTINCT
	    SRC_SYS_CLIENT_ID,
        CLIENT_ID_RAW,
        CLIENT_LINK_RAW,
        CLIENT_ID,
        CLIENT_LINK     
    FROM {{ ref('prep_ref_client_link_details') }}
    WHERE SRC_SYS = 'SUPPORTABILITY'
),

cte_titanium AS (
    SELECT DISTINCT
	    SRC_SYS_CLIENT_ID,
        CLIENT_ID_RAW,
        CLIENT_LINK_RAW,
        CLIENT_ID,
        CLIENT_LINK     
    FROM {{ ref('prep_ref_client_link_details') }}
    WHERE SRC_SYS = 'TITANIUM'
),

cte_trips AS (
    SELECT DISTINCT
	    SRC_SYS_CLIENT_ID,
        CLIENT_ID_RAW,
        CLIENT_LINK_RAW,
        CLIENT_ID,
        CLIENT_LINK     
    FROM {{ ref('prep_ref_client_link_details') }}
    WHERE SRC_SYS = 'TRIPS'
),

cte_distinct_links AS (
SELECT DISTINCT

    COALESCE(
        TC.CLIENT_ID_RAW,
        BP.CLIENT_ID_RAW,
        EC.CLIENT_ID_RAW,
        ET.CLIENT_ID_RAW,
        SU.CLIENT_ID_RAW,
        TI.CLIENT_ID_RAW,
        TR.CLIENT_ID_RAW
    )                           AS CLIENT_ID_RAW,
    COALESCE(
        TC.CLIENT_ID,
        BP.CLIENT_ID,
        EC.CLIENT_ID,
        ET.CLIENT_ID,
        SU.CLIENT_ID,
        TI.CLIENT_ID,
        TR.CLIENT_ID
    )                           AS CLIENT_ID_COALESCE,
    SHA1(CLIENT_ID_COALESCE)    AS CLIENT_ID_HASH,
    
    COALESCE(
        TC.CLIENT_LINK,
        BP.CLIENT_LINK,
        EC.CLIENT_LINK,
        ET.CLIENT_LINK,
        SU.CLIENT_LINK,
        TI.CLIENT_LINK,
        TR.CLIENT_LINK
    )                           AS CLIENT_LINK_COALESCE,
    SHA1(CLIENT_LINK_COALESCE)  AS CLIENT_LINK_HASH,
    
    TC.SRC_SYS_CLIENT_ID        AS TRAKCARE_ID,
    BP.SRC_SYS_CLIENT_ID        AS BEST_PRACTICE_ID,
    EC.SRC_SYS_CLIENT_ID        AS ECHIDNA_ID,
    ET.SRC_SYS_CLIENT_ID        AS E_TOOLS_ID,
    SU.SRC_SYS_CLIENT_ID        AS SUPPORTABILITY_ID,
    TI.SRC_SYS_CLIENT_ID        AS TITANIUM_ID,
    TR.SRC_SYS_CLIENT_ID        AS TRIPS_ID

FROM cte_trakcare                                         AS TC

FULL OUTER JOIN cte_best_practice                         AS BP
    ON TC.CLIENT_LINK = BP.CLIENT_LINK

FULL OUTER JOIN cte_echidna                               AS EC
    ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK) = EC.CLIENT_LINK

FULL OUTER JOIN cte_e_tools                               AS ET
    ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                EC.CLIENT_LINK) = ET.CLIENT_LINK

FULL OUTER JOIN cte_supportability                        AS SU
    ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                EC.CLIENT_LINK, ET.CLIENT_LINK) = SU.CLIENT_LINK

FULL OUTER JOIN cte_titanium                              AS TI
    ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                EC.CLIENT_LINK, ET.CLIENT_LINK,
                SU.CLIENT_LINK) = TI.CLIENT_LINK

FULL OUTER JOIN cte_trips                                 AS TR
    ON COALESCE(TC.CLIENT_LINK, BP.CLIENT_LINK,
                EC.CLIENT_LINK, ET.CLIENT_LINK,
                SU.CLIENT_LINK, TI.CLIENT_LINK) = TR.CLIENT_LINK
)
SELECT
    CLIENT_LINK_HASH,
    CLIENT_ID_HASH,
    TRAKCARE_ID,
    BEST_PRACTICE_ID,
    ECHIDNA_ID,
    E_TOOLS_ID,
    SUPPORTABILITY_ID,
    TITANIUM_ID,
    TRIPS_ID
FROM cte_distinct_links