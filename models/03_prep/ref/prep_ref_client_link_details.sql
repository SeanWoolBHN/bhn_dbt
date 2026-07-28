{{ config(materialized='table') }}

WITH all_clients AS (
    SELECT SRC_SYS, SRC_SYS_CLIENT_ID, FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_trakcare') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID, FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_best_practice') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID, FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_e_tools') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID, FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_echidna') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID, FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_supportability') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID, FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_titanium') }}

    UNION ALL

    SELECT SRC_SYS, SRC_SYS_CLIENT_ID, FIRST_NAME, LAST_NAME, DOB, ADDRESS, CITY, POSTCODE
    FROM {{ ref('prep_src_client_trips') }}
),

raw_keys AS (
    SELECT
        *,
        UPPER(
            IFNULL(FIRST_NAME, '') || '|' || IFNULL(LAST_NAME, '') || '|' ||
            IFNULL(CAST(DOB AS VARCHAR), '') || '|' || IFNULL(ADDRESS, '') || '|' ||
            IFNULL(CITY, '') || '|' || IFNULL(POSTCODE, '')
        )                                                 AS CLIENT_ID_RAW,
        UPPER(
            FIRST_NAME || '|' || LAST_NAME || '|' ||
            CAST(DOB AS VARCHAR) || '|' ||
            ADDRESS || '|' || CITY || '|' || POSTCODE
        )                                                 AS CLIENT_LINK_RAW
    FROM all_clients
)

SELECT DISTINCT
    CLIENT_ID_RAW,
    {{ format_client_link('CLIENT_ID_RAW') }}             AS CLIENT_ID,
    SHA1({{ format_client_link('CLIENT_ID_RAW') }})       AS CLIENT_ID_HASH,
    CLIENT_LINK_RAW,
    {{ format_client_link('CLIENT_LINK_RAW') }}           AS CLIENT_LINK,
    SHA1({{ format_client_link('CLIENT_LINK_RAW') }})     AS CLIENT_LINK_HASH,
    SRC_SYS,
    SRC_SYS_CLIENT_ID,
    FIRST_NAME,
    LAST_NAME,
    DOB,
    ADDRESS,
    CITY,
    POSTCODE

FROM raw_keys