
{{ config(materialized='table') }}

SELECT DISTINCT
    -- 
    UPPER(IFNULL(FIRST_NAME,'')||'|'||IFNULL(LAST_NAME,'')||'|'||IFNULL(CAST(DOB AS VARCHAR),'')
          ||'|'||IFNULL(ADDRESS,'')||'|'||IFNULL(CITY,'')||'|'||IFNULL(POSTCODE,''))                        AS CLIENT_ID_RAW,

    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(       
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENT_ID_RAW
            ,' ',''),'-',''),'/',''),'\\',''),',',''),')',''),'(',''),'*','')
            ,':',''),';',''),'_',''),'#',''),'~',''),'!',''),'%',''),'^',''),'"','')                        AS CLIENT_ID,
            
    SHA1(CLIENT_ID)                                                                                         AS CLIENT_ID_HASH,

    -- 
    UPPER(FIRST_NAME||'|'||LAST_NAME||'|'||CAST(DOB AS VARCHAR)||'|'||ADDRESS||'|'||CITY||'|'||POSTCODE)    AS CLIENT_LINK_RAW,
    
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(       
    REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(CLIENT_LINK_RAW
            ,' ',''),'-',''),'/',''),'\\',''),',',''),')',''),'(',''),'*','')
            ,':',''),';',''),'_',''),'#',''),'~',''),'!',''),'%',''),'^',''),'"','')                        AS CLIENT_LINK,
    
    SHA1(CLIENT_LINK)                                                                                       AS CLIENT_LINK_HASH,
    
    SRC_SYS,
    SRC_SYS_CLIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    DOB,
    ADDRESS,
    CITY,
    POSTCODE

FROM (
    SELECT SRC_SYS, SRC_SYS_CLIENT_ID
         , FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_trakcare') }}        -- 107,276

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID
         , FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_best_practice') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID
         , FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_e_tools') }}        -- 204

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID
         , FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_echidna') }}         -- 1103

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID
         , FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_supportability') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID
         , FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_titanium') }}        -- 102,632

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID
         , FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_trips') }}           -- 5,848
    
) AS all_clients
