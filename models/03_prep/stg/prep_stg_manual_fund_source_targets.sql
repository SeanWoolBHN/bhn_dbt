SELECT
    FUND_SOURCE_TARGET_KEY,
    ID                                                                    AS ID,
    NULLIF(TRIM(TYPE), 'NULL')                                            AS TYPE,
    NULLIF(TRIM(ABREV), 'NULL')                                           AS ABREV,
    NULLIF(TRIM(UNITS), 'NULL')                                           AS UNITS,
    NULLIF(TRIM(PROGRAM), 'NULL')                                         AS PROGRAM,
    NULLIF(TRIM(DATA_SET_), 'NULL')                                       AS DATA_SET,
    NULLIF(TRIM(VADC_FUND), 'NULL')                                       AS VADC_FUND,
    NULLIF(TRIM(SHORT_DESC), 'NULL')                                      AS SHORT_DESC,
    NULLIF(TRIM(ALT_PROGRAM), 'NULL')                                     AS ALT_PROGRAM,
    COST_CENTER                                                           AS COST_CENTER,
    NULLIF(TRIM(FUND_SOURCE), 'NULL')                                     AS FUND_SOURCE,
    NULLIF(TRIM(LOOKUPVALUE), 'NULL')                                     AS LOOKUP_VALUE,
    NULLIF(TRIM(SUB_PROGRAM), 'NULL')                                     AS SUB_PROGRAM,
    NULLIF(TRIM(SHORTFUNDDESC), 'NULL')                                   AS SHORT_FUND_DESC,
    MONTHLYTARGETS                                                        AS MONTHLY_TARGETS,
    YEARLY_TARGETS                                                        AS YEARLY_TARGETS,
    NULLIF(TRIM(LEGACY_ORGANISATION), 'NULL')                             AS LEGACY_ORGANISATION,
    NULLIF(TRIM(PROGRAM_STREAM_DESC), 'NULL')                             AS PROGRAM_STREAM_DESC,

    _AIRBYTE_EXTRACTED_AT                                                 AS AIRBYTE_EXTRACTED_TS

FROM {{ ref('HIST_MANUAL_FUND_SOURCE_TARGETS') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')