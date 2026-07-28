SELECT
    NULLIF(TRIM(ST_ROWID), 'NULL')                                        AS ROW_ID,
    NULLIF(TRIM(ST_PARREF), 'NULL')                                       AS PAR_REF,
    ST_CHILDSUB                                                           AS CHILD_SUB,
    ST_DATE                                                               AS STATUS_DATE,
    ST_TIME                                                               AS STATUS_TIME,
    ST_STATUS_DR                                                          AS STATUS_DR,
    ST_USER_DR                                                            AS USER_DR,
    NULLIF(TRIM(ST_REASON), 'NULL')                                       AS REASON,
    NULLIF(TRIM(ST_TEXTSTATUS), 'NULL')                                   AS TEXT_STATUS,
    NULLIF(TRIM(ST_ORDEXECSTATUS_DR), 'NULL')                             AS ORD_EXEC_STATUS_DR

FROM {{ ref('HIST_TRAKCARE_OE_ORDSTATUS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')