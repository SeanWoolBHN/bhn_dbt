SELECT 
    CL.CLIENT_ID_HASH,
    COALESCE(TC.FIRST_NAME, BP.FIRST_NAME, EC.FIRST_NAME, ET.FIRST_NAME, SU.FIRST_NAME, TI.FIRST_NAME, TR.FIRST_NAME)                AS FIRST_NAME,
    COALESCE(TC.LAST_NAME, BP.LAST_NAME, EC.LAST_NAME, ET.LAST_NAME, SU.LAST_NAME, TI.LAST_NAME, TR.LAST_NAME)                       AS LAST_NAME,
    COALESCE(TC.DOB, BP.DOB, EC.DOB, ET.DOB, SU.DOB, TI.DOB, TR.DOB)                                                                AS DOB,
    COALESCE(TC.ADDRESS, BP.ADDRESS, EC.ADDRESS, ET.ADDRESS, SU.ADDRESS, TI.ADDRESS, TR.ADDRESS)                                     AS ADDRESS,
    COALESCE(TC.CITY, BP.CITY, EC.CITY, ET.CITY, SU.CITY, TI.CITY, TR.CITY)                                                         AS CITY,
    COALESCE(TC.POSTCODE, BP.POSTCODE, EC.POSTCODE, ET.POSTCODE, SU.POSTCODE, TI.POSTCODE, TR.POSTCODE)                             AS POSTCODE,
    COALESCE(TC.EMAIL, BP.EMAIL, EC.EMAIL, ET.EMAIL, SU.EMAIL, TI.EMAIL, TR.EMAIL)                                                  AS EMAIL,
    COALESCE(TC.MOBILE_PHONE, BP.MOBILE_PHONE, EC.MOBILE_PHONE, ET.MOBILE_PHONE, SU.MOBILE_PHONE, TI.MOBILE_PHONE, TR.MOBILE_PHONE) AS MOBILE_PHONE,
    TC.AGE,
    TC.UR,
    TC.GENDER,
    TC.PREF_LANG,
    TC.ATSI,
    TC.HOMELESS,
    TC.MEDICARE_NO_1,
    TC.MEDICARE_NO,
    TC.GENDER_AT_BIRTH,
    TC.NDIS_NUMBER

FROM {{ ref('prep_ref_client_link') }}                AS CL

LEFT JOIN {{ ref('prep_src_client_best_practice') }}     AS BP
    ON CL.BEST_PRACTICE_ID = BP.SRC_SYS_CLIENT_ID

LEFT JOIN {{ ref('prep_src_client_echidna') }}           AS EC
    ON CL.ECHIDNA_ID = EC.SRC_SYS_CLIENT_ID

LEFT JOIN {{ ref('prep_src_client_e_tools') }}           AS ET
    ON CL.E_TOOLS_ID = ET.SRC_SYS_CLIENT_ID

LEFT JOIN {{ ref('prep_src_client_supportability') }}    AS SU
    ON CL.SUPPORTABILITY_ID = SU.SRC_SYS_CLIENT_ID

LEFT JOIN {{ ref('prep_src_client_titanium') }}          AS TI
    ON CL.TITANIUM_ID = TI.SRC_SYS_CLIENT_ID

LEFT JOIN {{ ref('prep_src_client_trakcare') }}          AS TC
    ON CL.TRAKCARE_ID = TC.SRC_SYS_CLIENT_ID

LEFT JOIN {{ ref('prep_src_client_trips') }}             AS TR
    ON CL.TRIPS_ID = TR.SRC_SYS_CLIENT_ID