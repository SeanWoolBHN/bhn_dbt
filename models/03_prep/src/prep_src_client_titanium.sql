SELECT DISTINCT
    'TITANIUM'                                            AS SRC_SYS,
    'TI-' || TP.DR_ID                                    AS SRC_SYS_CLIENT_ID,
    TP.FIRST_NAME,
    TP.LAST_NAME,
    TP.DOB,
    NULL::VARCHAR                                         AS EMAIL,
    TP.MOBILE_PHONE,
    TP.ADDRESS,
    TP.CITY,
    TP.POSTCODE

FROM {{ ref('prep_stg_titanium_patient_detail_report') }} AS TP