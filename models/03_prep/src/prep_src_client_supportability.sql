SELECT DISTINCT
    'SUPPORTABILITY'                                      AS SRC_SYS,
    'SU-' || SUPPORTABILITY_ID                           AS SRC_SYS_CLIENT_ID,
    SC.FIRST_NAME,
    SC.LAST_NAME,
    SC.DOB,
    SC.EMAIL,
    SC.MOBILE_PHONE,
    SC.ADDRESS,
    SC.CITY,
    SC.POSTCODE

FROM {{ ref('prep_stg_supportability_client_list_inc_personal_contacts') }} AS SC

WHERE UPPER(RECORD_TYPE) = 'CLIENT'