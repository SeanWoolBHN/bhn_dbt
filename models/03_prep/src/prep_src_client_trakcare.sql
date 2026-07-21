SELECT DISTINCT
    'TRAKCARE'                                                            AS SRC_SYS,
    NULLIF(PAT.PATIENT_NO, 'NULL')                                        AS SRC_SYS_CLIENT_ID,
    NULLIF(INITCAP(COALESCE(PAT.FIRST_NAME, PER.FIRST_NAME)), 'NULL')    AS FIRST_NAME,
    NULLIF(INITCAP(COALESCE(PAT.LAST_NAME, PER.LAST_NAME)), 'NULL')      AS LAST_NAME,
    TRY_TO_DATE(COALESCE(PAT.DOB::VARCHAR, PER.DOB::VARCHAR))            AS DOB,
    NULLIF(LOWER(COALESCE(PER.EMAIL, PAT.EMAIL)), 'null')                AS EMAIL,
    COALESCE(PAT.MOBILE_PHONE, PER.MOBILE_PHONE)                        AS MOBILE_PHONE,
    INITCAP(PER.STREET_NAME_LINE_1)
        || IFNULL(', ' || INITCAP(PER.ADDRESS_2), '')                    AS ADDRESS,
    ZIP.CITY                                                              AS CITY,
    ZIP.POSTCODE                                                          AS POSTCODE

FROM {{ ref('prep_stg_trakcare_pa_patmas') }}                            AS PAT

LEFT JOIN {{ ref('prep_stg_trakcare_pa_person') }}                       AS PER
    ON PAT.PATIENT_ID = PER.PERSON_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_zip') }}                          AS ZIP
    ON PER.ZIP_DR = ZIP.ROW_ID