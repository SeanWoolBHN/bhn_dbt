SELECT
    'REFERRAL_SOURCE_KEY'                               AS REFERRAL_SOURCE_KEY,
    'REF_TYPE'                                          AS REFERRAL_DIMENSION,
    REFT.CODE                                           AS CODE,
    REFT.DESCRIPTION                                    AS DESCRIPTION,
    REFT.NATIONAL_CODE                                  AS NATIONAL_CODE,
    NULL                                                AS ADDRESS,
    NULL                                                AS PHONE,
    NULL                                                AS EMAIL,
    'TRAKCARE'                                          AS SOURCE_SYSTEM
FROM {{ ref('prep_stg_trakcare_pac_referraltype') }}    AS REFT
WHERE REFT.CODE IS NOT NULL

UNION ALL

SELECT
    'REFERRAL_SOURCE_KEY'                               AS REFERRAL_SOURCE_KEY,
    'REF_SOURCE'                                        AS REFERRAL_DIMENSION,
    ATTEND.CODE                                         AS CODE,
    ATTEND.DESCRIPTION                                  AS DESCRIPTION,
    ATTEND.NATIONAL_CODE                                AS NATIONAL_CODE,
    NULL                                                AS ADDRESS,
    NULL                                                AS PHONE,
    NULL                                                AS EMAIL,
    'TRAKCARE'                                          AS SOURCE_SYSTEM
FROM {{ ref('prep_stg_trakcare_pac_sourceofattendance') }} AS ATTEND
WHERE ATTEND.CODE IS NOT NULL

UNION ALL

SELECT
    'REFERRAL_SOURCE_KEY'                               AS REFERRAL_SOURCE_KEY,
    'REFERRAL_ORG'                                      AS REFERRAL_DIMENSION,
    NGO.CODE                                            AS CODE,
    NGO.DESCRIPTION                                     AS DESCRIPTION,
    NULL                                                AS NATIONAL_CODE,
    NGO.ADDRESS                                         AS ADDRESS,
    NGO.PHONE                                           AS PHONE,
    NGO.EMAIL                                           AS EMAIL,
    'TRAKCARE'                                          AS SOURCE_SYSTEM
FROM {{ ref('prep_stg_trakcare_pac_nongovorg') }}       AS NGO
WHERE NGO.CODE IS NOT NULL

UNION ALL

SELECT
    'REFERRAL_SOURCE_KEY'                               AS REFERRAL_SOURCE_KEY,
    'REFERRAL_DESTINATION'                              AS REFERRAL_DIMENSION,
    REFDEP.CODE                                         AS CODE,
    REFDEP.DESCRIPTION                                  AS DESCRIPTION,
    REFDEP.NATIONAL_CODE                                AS NATIONAL_CODE,
    NULL                                                AS ADDRESS,
    NULL                                                AS PHONE,
    NULL                                                AS EMAIL,
    'TRAKCARE'                                          AS SOURCE_SYSTEM
FROM {{ ref('prep_stg_trakcare_pac_referreddeparture') }} AS REFDEP
WHERE REFDEP.CODE IS NOT NULL