SELECT
    RTMAS_ROWID                                                           AS ROW_ID,
    NULLIF(TRIM(RTMAS_MRNO), 'NULL')                                      AS MR_NO,
    NULLIF(TRIM(RTMAS_TYPE), 'NULL')                                      AS TYPE,
    NULLIF(TRIM(RTMAS_ACTIVE), 'NULL')                                    AS ACTIVE,
    NULLIF(TRIM(RTMAS_LOOKUP), 'NULL')                                    AS LOOKUP,
    NULLIF(TRIM(RTMAS_STATUS), 'NULL')                                    AS STATUS,
    RTMAS_EXPDAYS                                                         AS EXP_DAYS,
    RTMAS_PATNO_DR                                                        AS PAT_NO_DR,
    RTMAS_MRTYPE_DR                                                       AS MR_TYPE_DR,
    RTMAS_DATECREATE                                                      AS CREATED_DATE,
    RTMAS_TIMECREATE                                                      AS CREATED_TIME,
    RTMAS_HOMELOC_DR                                                      AS HOME_LOC_DR,
    RTMAS_HOSPITAL_DR                                                     AS HOSPITAL_DR,
    RTMAS_CREATELOC_DR                                                    AS CREATE_LOC_DR,
    RTMAS_USERCREATE_DR                                                   AS CREATED_USER_DR

FROM {{ ref('HIST_TRAKCARE_RT_MASTER') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')