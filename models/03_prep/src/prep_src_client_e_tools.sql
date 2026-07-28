WITH cte_esah AS (
    -- ESAH clients with full contact details
    SELECT DISTINCT
        'ET-' || ESAH.CARE_RECIPIENT_ID                   AS SRC_SYS_CLIENT_ID,
        ESAH.FIRST_NAME,
        ESAH.LAST_NAME,
        ESAH.DOB,
        ESAH.EMAIL,
        ESAH.MOBILE_PHONE,
        IFNULL(ESAH.ADDRESS_1, '')
            || IFNULL(',' || ESAH.ADDRESS_2, '')          AS ADDRESS,
        ESAH.SUBURB                                       AS CITY,
        ESAH.POSTCODE,
        ESAH.CLIENT_STATUS
    FROM {{ ref('prep_stg_e_tools_esah_clients') }}       AS ESAH
),

cte_cust_minus AS (
    -- Clients in CUSTOMER_LIST but NOT in ESAH
    SELECT CARE_RECIPIENT_ID
    FROM {{ ref('prep_stg_e_tools_customer_list') }}
    MINUS
    SELECT CARE_RECIPIENT_ID
    FROM {{ ref('prep_stg_e_tools_esah_clients') }}
),

cte_cust AS (
    -- CUSTOMER_LIST clients not in ESAH — no contact details available
    SELECT DISTINCT
        'ET-' || ET.CARE_RECIPIENT_ID                     AS SRC_SYS_CLIENT_ID,
        ET.FIRST_NAME,
        ET.LAST_NAME,
        ET.DOB,
        NULL::VARCHAR                                     AS EMAIL,
        NULL::VARCHAR                                     AS MOBILE_PHONE,
        NULL::VARCHAR                                     AS ADDRESS,
        NULL::VARCHAR                                     AS CITY,
        NULL::VARCHAR                                     AS POSTCODE,
        ET.CLIENT_STATUS
    FROM {{ ref('prep_stg_e_tools_customer_list') }}      AS ET
    WHERE ET.CARE_RECIPIENT_ID IN (
        SELECT CARE_RECIPIENT_ID FROM cte_cust_minus
    )
),

cte_cust_null AS (
    -- CUSTOMER_LIST clients with NULL CARE_RECIPIENT_ID
    SELECT DISTINCT
        'ET-' || ET.CARE_RECIPIENT_ID                     AS SRC_SYS_CLIENT_ID,
        ET.FIRST_NAME,
        ET.LAST_NAME,
        ET.DOB,
        NULL::VARCHAR                                     AS EMAIL,
        NULL::VARCHAR                                     AS MOBILE_PHONE,
        NULL::VARCHAR                                     AS ADDRESS,
        NULL::VARCHAR                                     AS CITY,
        NULL::VARCHAR                                     AS POSTCODE,
        ET.CLIENT_STATUS
    FROM {{ ref('prep_stg_e_tools_customer_list') }}      AS ET
    WHERE ET.CARE_RECIPIENT_ID IS NULL
)

SELECT 'E_TOOLS' AS SRC_SYS, * FROM cte_esah
UNION ALL
SELECT 'E_TOOLS' AS SRC_SYS, * FROM cte_cust
UNION ALL
SELECT 'E_TOOLS' AS SRC_SYS, * FROM cte_cust_null