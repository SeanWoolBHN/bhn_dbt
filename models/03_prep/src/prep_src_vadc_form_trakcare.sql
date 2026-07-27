SELECT
    -- ── Natural keys ────────────────────────────────────────────────
    VADC.VADC_ID                                          AS VADC_EPISODE_ID,
    VADC.ADM_DR                                           AS EPISODE_ID,
    VADC.PATIENT_DR                                       AS PATIENT_DR_RAW,
    PAT.PATIENT_NO                                        AS UR,

    -- ── Campus / Legacy Org ─────────────────────────────────────────
    VADC.VADC_OUT_CODE                                    AS LEGACY_ORG_ID,

    -- ── Questionnaire dates ─────────────────────────────────────────
    VADC.QUES_DATE                                        AS QUESTIONNAIRE_DATE,
    VADC.QUES_TIME                                        AS QUESTIONNAIRE_TIME,
    VADC.CREATED_DATE                                     AS CREATED_DATE,
    VADC.CREATED_TIME                                     AS CREATED_TIME,

    -- ── Care provider ───────────────────────────────────────────────
    VADC.CONSULT_DR                                       AS CONSULT_DR_RAW,
    CONCAT_WS(' ',
        NULLIF(TRIM(CP.FIRST_NAME), ''),
        NULLIF(TRIM(CP.LAST_NAME), '')
    )                                                     AS EPISODE_CP,
    CP.CODE                                               AS EPISODE_CP_CODE,

    -- ── ATSI status ─────────────────────────────────────────────────
    -- Joined via PA_PATMAS.PAPMI_INDIGSTAT_DR → PAC_INDIGSTATUS
    -- Required for VADC government reporting — DTAU stream depends on ATSI
    INDST.DESCRIPTION                                     AS ATSI_STATUS,
    CASE
        WHEN PAT.INDIGENOUS_STATUS_DR IN ('4', '5', '6')
            THEN 'ATSI'
        ELSE 'Non-ATSI'
    END                                                   AS ATSI,

    -- ── VADC treatment fields ───────────────────────────────────────
    VADC.VADC_FOR_TYP                                     AS FORENSIC_TYPE,
    VADC.VADC_CRS_LEN                                     AS TREATMENT_LENGTH,
    VADC.VADC_PER_COMP                                    AS PERCENTAGE_COMPLETED,
    VADC.VADC_TARG_POP                                    AS TARGET_GROUP,
    VADC.VADC_MARAM                                       AS MARAM_RISK,
    VADC.VADC_FAM_VIOLENCE                                AS FAMILY_VIOLENCE_FLAG,
    VADC.VADC_TIER                                        AS SERVICE_TIER,
    VADC.VADC_DEL_SET                                     AS DELIVERY_SETTING,
    VADC.VADC_SIG_GOAL                                    AS SIGNIFICANT_GOAL,
    VADC.VADC_ASSESS_COMP                                 AS ASSESSMENT_COMPLETED,
    VADC.VADC_FIRST_REG                                   AS FIRST_REGISTRATION,

    -- ── Client demographics at time of episode ──────────────────────
    VADC.VADC_BIRTH_SEX                                   AS BIRTH_SEX,
    VADC.VADC_GENDER_REAS                                 AS GENDER_REASON,
    VADC.VADC_ABI                                         AS ABI_FLAG,
    VADC.VADC_LGB                                         AS LGB_FLAG,
    VADC.VADC_MAL_TRT                                     AS MALTREATMENT_FLAG,
    VADC.VADC_MAL_PERP                                    AS MALTREATMENT_PERPETRATOR,
    VADC.VADC_MAL_PERP_1                                  AS MALTREATMENT_PERPETRATOR_1,
    VADC.VADC_MH_DIAG                                     AS MENTAL_HEALTH_DIAGNOSIS,
    VADC.VADC_MH_DIAG_1                                   AS MENTAL_HEALTH_DIAGNOSIS_1,
    VADC.VADC_MASCOT                                      AS MASCOT_FLAG,
    VADC.VADC_PRES_DRUG_OC                                AS PRESENTING_DRUG_OF_CONCERN,

    -- ── Audit / status ──────────────────────────────────────────────
    VADC.STATUS_DR                                        AS STATUS_DR_RAW,
    CONCAT_WS(' ',
        NULLIF(TRIM(USR.FIRST_NAME), ''),
        NULLIF(TRIM(USR.LAST_NAME), '')
    )                                                     AS CREATED_BY_USER
    

FROM {{ ref('prep_stg_trakcare_qauxxadvadc') }}           AS VADC

LEFT JOIN {{ ref('prep_stg_trakcare_pa_patmas') }}        AS PAT
    ON CAST(VADC.PATIENT_DR AS VARCHAR) = CAST(PAT.PATIENT_ID AS VARCHAR)

-- ATSI lookup via patient master indigenous status reference
LEFT JOIN {{ ref('prep_stg_trakcare_pac_indig_status') }}  AS INDST
    ON CAST(PAT.INDIGENOUS_STATUS_DR AS VARCHAR) = CAST(INDST.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}      AS CP
    ON CAST(VADC.CONSULT_DR AS VARCHAR) = CAST(CP.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ss_user') }}          AS USR
    ON CAST(VADC.CREATED_USER_DR AS VARCHAR) = CAST(USR.ROW_ID AS VARCHAR)

WHERE VADC.VADC_ID IS NOT NULL