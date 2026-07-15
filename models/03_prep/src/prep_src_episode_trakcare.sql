SELECT
    PAT.PATIENT_NO                                      AS UR, --UR
    ADM.ADM_NO                                          AS EPISODE_ID,--EPISODEID

    -- ── Episode dates ───────────────────────────────────────────────
    ADM.ADM_DATE                                        AS EPISODE_DT,--EPISODEDT
    ADM.DISCHARGE_DATE                                  AS DISCHARGE_DT,--DISCHARGEDT
    'PROGRAMSTREAMCODE'                                 AS PROGRAM_STREAM_CODE_PENDING,

    -- ── Derived date fields ─────────────────────────────────────────
    DATEDIFF(
        'day',
        ADM.ADM_DATE,
        COALESCE(ADM.DISCHARGE_DATE, CURRENT_DATE())
    )                                                   AS DAYS_OPEN,

    CASE
        WHEN ADM.DISCHARGE_DATE IS NULL THEN TRUE
        ELSE FALSE
    END                                                 AS EPISODE_ACTIVE,

    ADM.REF_DATE                                        AS REFERRAL_RECEIVED_DT,
    ADM.CREATED_DATE                                    AS REFERRAL_CREATED_DT,
    ADM.CONFIRM_REFERRAL                                AS CONSENT_TO_REFERRAL,
    ADM.CONSENT_REC_FUND_INFO                           AS DATA_COLLECTION_CONSENT,
    ADM.ADM_REASON_DR                                   AS REFERRAL_REASON_DR_RAW,
    ADM.REMARK                                          AS PRESENTING_ISSUE,

    -- ── Location / team ─────────────────────────────────────────────
    LOC.DESCRIPTION                                     AS EPISODE_TEAM, --EPISODETEAM
    LOC.CODE                                            AS EPISODE_TEAM_CODE,

    -- ── Service / hospital ──────────────────────────────────────────
    HOSP.DESCRIPTION                                    AS SERVICE,
    HOSP.CODE                                           AS SERVICE_CODE,

    -- ── Program stream (pending) ────────────────────────────────────
    'PROGRAM_STREAM_CODE_PENDING'                       AS PROGRAM_STREAM_CODE,
    'PROGRAM_STREAM_DESC_PENDING'                       AS PROGRAM_STREAM_DESC,

    -- ── Care provider ───────────────────────────────────────────────
    CONCAT_WS(' ',
        NULLIF(TRIM(CP.FIRST_NAME), ''),
        NULLIF(TRIM(CP.LAST_NAME), '')
    )                                                   AS EPISODE_CP, 
    CP.CODE                                             AS EPISODE_CP_CODE,

    -- ── Referral details ────────────────────────────────────────────
    REFT.DESCRIPTION                                    AS REF_TYPE,
    REFT.CODE                                           AS REF_TYPE_CODE,
    ATTEND.DESCRIPTION                                  AS REF_SOURCE,
    ATTEND.CODE                                         AS REF_SOURCE_CODE,
    NGO.DESCRIPTION                                     AS REFERRAL_ORG,
    NGO.CODE                                            AS REFERRAL_ORG_CODE,
    INT_LOC.DESCRIPTION                                 AS INT_REF_TEAM,
    REFDEP.DESCRIPTION                                  AS REFERRAL_DESTINATION,
    REFDEP.CODE                                         AS REFERRAL_DESTINATION_CODE,
    ADM.REF_STAT_DR                                     AS REFERRAL_STATUS_DR_RAW,
    ADM.REFERRAL_PRIORITY_DR                            AS REFERRAL_PRIORITY_DR_RAW,

    -- ── Payor / plan (pending) ──────────────────────────────────────
    'PAYOR_PENDING'                                     AS PAYOR,
    'PLAN_PENDING'                                      AS PLAN,

    -- ── Financial year quarter ──────────────────────────────────────
    CASE
        WHEN MONTH(ADM.ADM_DATE) >= 7
            THEN YEAR(ADM.ADM_DATE)::VARCHAR
                 || '-' || (YEAR(ADM.ADM_DATE) + 1)::VARCHAR
                 || ' Q'
                 || CASE
                        WHEN MONTH(ADM.ADM_DATE) IN (7, 8, 9)    THEN '1'
                        WHEN MONTH(ADM.ADM_DATE) IN (10, 11, 12) THEN '2'
                        WHEN MONTH(ADM.ADM_DATE) IN (1, 2, 3)    THEN '3'
                        ELSE '4'
                    END
        ELSE (YEAR(ADM.ADM_DATE) - 1)::VARCHAR
             || '-' || YEAR(ADM.ADM_DATE)::VARCHAR
             || ' Q'
             || CASE
                    WHEN MONTH(ADM.ADM_DATE) IN (7, 8, 9)    THEN '1'
                    WHEN MONTH(ADM.ADM_DATE) IN (10, 11, 12) THEN '2'
                    WHEN MONTH(ADM.ADM_DATE) IN (1, 2, 3)    THEN '3'
                    ELSE '4'
                END
    END                                                 AS EPISODE_REF_QTR,

    -- ── Misc ────────────────────────────────────────────────────────
    ADM.TYPE                                            AS ANON_CLIENT_ORG

FROM {{ ref('prep_stg_trakcare_pa_patmas') }}           AS PAT

INNER JOIN {{ ref('prep_stg_trakcare_pa_adm') }}        AS ADM
    ON ADM.PATIENT_DR = PAT.PATIENT_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_loc') }}         AS LOC
    ON ADM.TEMP_LOC_DR = LOC.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_loc') }}         AS INT_LOC
    ON ADM.INTERNAL_REF_LOC_DR = INT_LOC.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_hospital') }}    AS HOSP
    ON ADM.HOSPITAL_DR = HOSP.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}    AS CP
    ON ADM.HCP_DR = CP.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_pac_referraltype') }} AS REFT
    ON ADM.REFERRAL_TYPE_DR = REFT.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_pac_sourceofattendance') }} AS ATTEND
    ON ADM.SOURCE_OF_ATTEND_DR = ATTEND.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_pac_nongovorg') }}  AS NGO
    ON ADM.NON_GOV_ORG_DR = NGO.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_pac_referreddeparture') }} AS REFDEP
    ON ADM.DISPOS_DR = REFDEP.ROW_ID

WHERE PAT.PATIENT_NO IS NOT NULL