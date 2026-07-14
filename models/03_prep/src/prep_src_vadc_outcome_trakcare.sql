SELECT
    -- ── Natural keys ────────────────────────────────────────────────
    OUT.VADC_OUT_ID                                       AS VADC_OUTCOME_ID,
    OUT.ADM_DR                                            AS EPISODE_ID,
    OUT.PATIENT_DR                                        AS PATIENT_DR_RAW,

    -- ── UR resolved from PA_PATMAS ──────────────────────────────────
    PAT.PATIENT_NO                                        AS UR,

    -- ── Outcome measurement dates ───────────────────────────────────
    OUT.QUES_DATE                                         AS OUTCOME_DATE,
    OUT.QUES_TIME                                         AS OUTCOME_TIME,
    OUT.VADC_OUT_DATE                                     AS VADC_OUTCOME_DATE,
    OUT.CREATED_DATE                                      AS CREATED_DATE,
    OUT.CREATED_TIME                                      AS CREATED_TIME,

    -- ── K10 psychological distress score ────────────────────────────
    OUT.VADC_OUT_K10                                      AS K10_SCORE,
    OUT.VADC_OUT_K10_OBS_DR                               AS K10_OBSERVATION_DR,

    -- ── AUDIT alcohol use score ─────────────────────────────────────
    OUT.VADC_OUT_AUDIT                                    AS AUDIT_SCORE,
    OUT.VADC_OUT_AUDIT_OBS_DR                             AS AUDIT_OBSERVATION_DR,

    -- ── DUDIT drug use score ────────────────────────────────────────
    OUT.VADC_OUT_DUDIT                                    AS DUDIT_SCORE,
    OUT.VADC_OUT_DUDIT_OBS_DR                             AS DUDIT_OBSERVATION_DR,

    -- ── Employment and study ────────────────────────────────────────
    OUT.VADC_OUT_EMPL                                     AS EMPLOYMENT_STATUS,
    OUT.VADC_OUT_EMPL_OBS_DR                              AS EMPLOYMENT_OBSERVATION_DR,
    OUT.VADC_OUT_STUDY                                    AS STUDY_STATUS,
    OUT.VADC_OUT_STUDY_OBS_DR                             AS STUDY_OBSERVATION_DR,

    -- ── Accommodation ───────────────────────────────────────────────
    OUT.VADC_OUT_ACCOM                                    AS ACCOMMODATION_STATUS,
    OUT.VADC_OUT_ACCOM_OBS_DR                             AS ACCOMMODATION_OBSERVATION_DR,

    -- ── Risk and safety ─────────────────────────────────────────────
    OUT.VADC_OUT_RISK_SELF                                AS RISK_TO_SELF,
    OUT.VADC_OUT_RISK_SELF_OBS_DR                         AS RISK_TO_SELF_OBS_DR,
    OUT.VADC_OUT_RISK_OTH                                 AS RISK_TO_OTHERS,
    OUT.VADC_OUT_RISK_OTH_OBS_DR                          AS RISK_TO_OTHERS_OBS_DR,
    OUT.VADC_OUT_VIOLENT                                  AS VIOLENT_BEHAVIOUR,
    OUT.VADC_OUT_VIOLENT_OBS_DR                           AS VIOLENT_BEHAVIOUR_OBS_DR,
    OUT.VADC_OUT_VIOLENT_V2                               AS VIOLENT_BEHAVIOUR_V2,
    OUT.VADC_OUT_VIOLENT_V2_OBS_DR                        AS VIOLENT_BEHAVIOUR_V2_OBS_DR,

    -- ── Health ──────────────────────────────────────────────────────
    OUT.VADC_OUT_PHYS_HLTH                                AS PHYSICAL_HEALTH,
    OUT.VADC_OUT_PHYS_HLTH_OBS_DR                         AS PHYSICAL_HEALTH_OBS_DR,
    OUT.VADC_OUT_PSYCH_HLTH                               AS PSYCHOLOGICAL_HEALTH,
    OUT.VADC_OUT_PSYCH_HLTH_OBS_DR                        AS PSYCHOLOGICAL_HEALTH_OBS_DR,

    -- ── Injecting behaviour ─────────────────────────────────────────
    OUT.VADC_OUT_INJ_DAYS                                 AS INJECTING_DAYS,
    OUT.VADC_OUT_INJ_DAYS_OBS_DR                          AS INJECTING_DAYS_OBS_DR,

    -- ── Quality of life ─────────────────────────────────────────────
    OUT.VADC_OUT_QTY_LIFE                                 AS QUALITY_OF_LIFE,
    OUT.VADC_OUT_QTY_LIFE_OBS_DR                          AS QUALITY_OF_LIFE_OBS_DR,

    -- ── Arrest ──────────────────────────────────────────────────────
    OUT.VADC_OUT_ARREST                                   AS ARREST_FLAG,
    OUT.VADC_OUT_ARREST_OBS_DR                            AS ARREST_OBSERVATION_DR,

    -- ── 14-day follow-up variants ───────────────────────────────────
    OUT.VADC_OUT_PHYS_HLTH_14                             AS PHYSICAL_HEALTH_14DAY,
    OUT.VADC_OUT_PSYCH_HLTH_14                            AS PSYCHOLOGICAL_HEALTH_14DAY,
    OUT.VADC_OUT_RISK_SELF_14                             AS RISK_TO_SELF_14DAY,
    OUT.VADC_OUT_RISK_OTH_14                              AS RISK_TO_OTHERS_14DAY,
    OUT.VADC_OUT_VIOLENT_14                               AS VIOLENT_BEHAVIOUR_14DAY,
    OUT.VADC_OUT_QTY_LIFE_14                              AS QUALITY_OF_LIFE_14DAY,
    OUT.VADC_OUT_ARREST_14                                AS ARREST_FLAG_14DAY,

    -- ── Audit ───────────────────────────────────────────────────────
    CONCAT_WS(' ',
        NULLIF(TRIM(USR.FIRST_NAME), ''),
        NULLIF(TRIM(USR.LAST_NAME), '')
    )                                                     AS CREATED_BY_USER,

    -- ── Source system ───────────────────────────────────────────────
    'TRAKCARE'                                            AS SOURCE_SYSTEM

FROM {{ ref('prep_stg_trakcare_qauxxadout') }}            AS OUT

-- UR resolution via patient master
LEFT JOIN {{ ref('prep_stg_trakcare_pa_patmas') }}        AS PAT
    ON CAST(OUT.PATIENT_DR AS VARCHAR) = CAST(PAT.PATIENT_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ss_user') }}          AS USR
    ON CAST(OUT.CREATED_USER_DR AS VARCHAR) = CAST(USR.ROW_ID AS VARCHAR)

WHERE OUT.VADC_OUT_ID IS NOT NULL