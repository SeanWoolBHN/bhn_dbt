WITH primary_insurance AS (
    -- Get primary insurer per admission ordered by CHILD_SUB DESC per SSIS
    SELECT
        ADM_DR,
        INS_TYPE_DR,
        AUX_INS_TYPE_DR,
        PAYOR_VARIATION_COMMENTS                          AS EPISODE_PAYOR_NOTES,
        ROW_NUMBER() OVER (
            PARTITION BY ADM_DR
            ORDER BY TRY_TO_NUMBER(CHILD_SUB::VARCHAR, 18, 0) DESC NULLS LAST
        )                                                 AS RN
    FROM {{ ref('prep_stg_trakcare_pa_adminsurance') }}
    WHERE DATE_TYPE_TO IS NULL
       OR TRY_TO_DATE(DATE_TYPE_TO::VARCHAR) >= CURRENT_DATE()
),

client_payor_notes AS (
    -- CLIENT_PAYOR_NOTES via PA_PERSONADMINSURANCE
    -- Join key: PA_ADM.PAADM_PAPMI_DR = PAINS_PARREF per SSIS
    SELECT
        PAR_REF,
        PAYOR_VARIATION_COMMENTS,
        ROW_NUMBER() OVER (
            PARTITION BY PAR_REF
            ORDER BY TRY_TO_NUMBER(CHILD_SUB::VARCHAR, 18, 0) DESC NULLS LAST
        )                                                 AS RN
    FROM {{ ref('prep_stg_trakcare_pa_personadminsurance') }}
    WHERE DATE_TYPE_TO IS NULL
       OR DATE_TYPE_TO >= CURRENT_DATE()
)

SELECT

    ADM.ADM_NO::VARCHAR                                   AS EPISODE_ID,
    PAT.PATIENT_NO::VARCHAR                               AS UR,

    -- ── Client demographics ─────────────────────────────────────────
    PAT.DOB                                               AS DOB,
    DATEDIFF('year', PAT.DOB, CURRENT_DATE())             AS AGE,
    SEX.DESC                                              AS GENDER,
    SEX_BIRTH.DESC                                        AS GENDER_AT_BIRTH,
    COB.DESC                                              AS COUNTRY_OF_BIRTH,
    LANG.DESCRIPTION                                      AS PREF_LANG,
    INDST.DESCRIPTION                                     AS INDIG,
    CASE
        WHEN PAT.INDIGENOUS_STATUS_DR IN (4, 5, 6)
            THEN 'ATSI'
        ELSE 'Not ATSI'
    END                                                   AS ATSI,
    SS.DESCRIPTION                                        AS HOMELESS,

    -- ── Payor / plan — via PA_ADMINSURANCE ──────────────────────────
    -- CURRENT_PAYOR uses ARC_INSURANCETYPE per SSIS
    INSTYPE.DESCRIPTION                                   AS CURRENT_PAYOR,
    -- CURRENT_PLAN uses ARC_AUXILINSURTYPE per SSIS
    AUX.DESCRIPTION                                       AS CURRENT_PLAN,
    INS.EPISODE_PAYOR_NOTES                               AS EPISODE_PAYOR_NOTES,
    -- CLIENT_PAYOR_NOTES via PA_PERSONADMINSURANCE per SSIS
    CPN.PAYOR_VARIATION_COMMENTS                          AS CLIENT_PAYOR_NOTES,

    -- ── Episode dates ───────────────────────────────────────────────
    ADM.ADM_DATE                                          AS EPISODE_DT,

    -- ── Program stream — via PA_ADM2 → CT_NFMI_CATEGDEPART → CT_NFMI_CATEGORY
    CAT.CODE                                              AS GOVT_CAT_CODE,
    CAT.DESCRIPTION                                       AS GOVT_CAT_DESC,
    PROG.CODE                                             AS PROGRAM_STREAM_CODE,
    PROG.DESCRIPTION                                      AS PROGRAM_STREAM_DESC,

    -- ── Episode financial year quarter ──────────────────────────────
    CASE
        WHEN MONTH(ADM.ADM_DATE) BETWEEN 4 AND 6
            THEN (YEAR(ADM.ADM_DATE) - 1)::VARCHAR
                 || '-' || RIGHT(YEAR(ADM.ADM_DATE)::VARCHAR, 2) || ' Q4'
        WHEN MONTH(ADM.ADM_DATE) BETWEEN 1 AND 3
            THEN (YEAR(ADM.ADM_DATE) - 1)::VARCHAR
                 || '-' || RIGHT(YEAR(ADM.ADM_DATE)::VARCHAR, 2) || ' Q3'
        WHEN MONTH(ADM.ADM_DATE) BETWEEN 10 AND 12
            THEN YEAR(ADM.ADM_DATE)::VARCHAR
                 || '-' || RIGHT((YEAR(ADM.ADM_DATE) + 1)::VARCHAR, 2) || ' Q2'
        WHEN MONTH(ADM.ADM_DATE) BETWEEN 7 AND 9
            THEN YEAR(ADM.ADM_DATE)::VARCHAR
                 || '-' || RIGHT((YEAR(ADM.ADM_DATE) + 1)::VARCHAR, 2) || ' Q1'
    END                                                   AS EPISODE_REF_QTR,
    YEAR(ADM.ADM_DATE)                                    AS EPISODE_REF_YEAR,
    MONTHNAME(ADM.ADM_DATE)                               AS EPISODE_REF_MONTH,
    MONTH(ADM.ADM_DATE)                                   AS EPISODE_REF_MMONTH,

    -- ── Discharge dates ─────────────────────────────────────────────
    ADM.DISCHARGE_DATE                                    AS DISCHARGE_DT,
    DATEDIFF('day', ADM.ADM_DATE,
        COALESCE(ADM.DISCHARGE_DATE, CURRENT_DATE()))     AS DAYS_OPEN,

    CASE
        WHEN MONTH(ADM.DISCHARGE_DATE) BETWEEN 4 AND 6
            THEN (YEAR(ADM.DISCHARGE_DATE) - 1)::VARCHAR
                 || '-' || RIGHT(YEAR(ADM.DISCHARGE_DATE)::VARCHAR, 2) || ' Q4'
        WHEN MONTH(ADM.DISCHARGE_DATE) BETWEEN 1 AND 3
            THEN (YEAR(ADM.DISCHARGE_DATE) - 1)::VARCHAR
                 || '-' || RIGHT(YEAR(ADM.DISCHARGE_DATE)::VARCHAR, 2) || ' Q3'
        WHEN MONTH(ADM.DISCHARGE_DATE) BETWEEN 10 AND 12
            THEN YEAR(ADM.DISCHARGE_DATE)::VARCHAR
                 || '-' || RIGHT((YEAR(ADM.DISCHARGE_DATE) + 1)::VARCHAR, 2) || ' Q2'
        WHEN MONTH(ADM.DISCHARGE_DATE) BETWEEN 7 AND 9
            THEN YEAR(ADM.DISCHARGE_DATE)::VARCHAR
                 || '-' || RIGHT((YEAR(ADM.DISCHARGE_DATE) + 1)::VARCHAR, 2) || ' Q1'
    END                                                   AS EPISODE_DISCHARGE_QTR,
    YEAR(ADM.DISCHARGE_DATE)                              AS DISCHARGE_YEAR,
    MONTHNAME(ADM.DISCHARGE_DATE)                         AS DISCHARGE_MONTH,
    MONTH(ADM.DISCHARGE_DATE)                             AS DISCHARGE_MMONTH,

    -- ── Episode active — from PAADM_CURRENT per SSIS ────────────────
    ADM.PAADM_CURRENT                                     AS EPISODE_ACTIVE,

    -- ── Referral status — now wired via PAC_REFERRALSTATUS ──────────
    RST.DESCRIPTION                                       AS REFERRAL_STATUS,

    -- ── Service / hospital ──────────────────────────────────────────
    HOSP.DESCRIPTION                                      AS SERVICE,
    HOSP.CODE                                             AS SERVICE_CODE,

    -- ── Episode CP — PAADM_ADMDOCCODEDR per SSIS ────────────────────
    CP_EP.DESCRIPTION                                     AS EPISODE_CP,
    CP_EP.CODE                                            AS EPISODE_CP_CODE,

    -- ── Episode team — PAADM_DEPCODE_DR per SSIS ────────────────────
    LOC_TEAM.DESCRIPTION                                  AS EPISODE_TEAM,
    LOC_TEAM.CODE                                         AS EPISODE_TEAM_CODE,

    -- ── Referral type ───────────────────────────────────────────────
    REFT.DESCRIPTION                                      AS REF_TYPE,
    REFT.CODE                                             AS REF_TYPE_CODE,

    -- ── Referral dates ──────────────────────────────────────────────
    ADM.DATE_RECEIVED                                     AS REF_REC_DT,
    ADM.CREATED_DATE                                      AS REF_CREATE_DT,

    -- ── Referral created quarter ────────────────────────────────────
    CASE
        WHEN MONTH(ADM.CREATED_DATE) BETWEEN 4 AND 6
            THEN (YEAR(ADM.CREATED_DATE) - 1)::VARCHAR
                 || '-' || RIGHT(YEAR(ADM.CREATED_DATE)::VARCHAR, 2) || ' Q4'
        WHEN MONTH(ADM.CREATED_DATE) BETWEEN 1 AND 3
            THEN (YEAR(ADM.CREATED_DATE) - 1)::VARCHAR
                 || '-' || RIGHT(YEAR(ADM.CREATED_DATE)::VARCHAR, 2) || ' Q3'
        WHEN MONTH(ADM.CREATED_DATE) BETWEEN 10 AND 12
            THEN YEAR(ADM.CREATED_DATE)::VARCHAR
                 || '-' || RIGHT((YEAR(ADM.CREATED_DATE) + 1)::VARCHAR, 2) || ' Q2'
        WHEN MONTH(ADM.CREATED_DATE) BETWEEN 7 AND 9
            THEN YEAR(ADM.CREATED_DATE)::VARCHAR
                 || '-' || RIGHT((YEAR(ADM.CREATED_DATE) + 1)::VARCHAR, 2) || ' Q1'
    END                                                   AS REF_CREATED_QTR,
    YEAR(ADM.CREATED_DATE)                                AS REF_CREATED_YEAR,
    MONTHNAME(ADM.CREATED_DATE)                           AS REF_CREATED_MONTH,
    MONTH(ADM.CREATED_DATE)                               AS REF_CREATED_MMONTH,

    -- ── Referral created by ─────────────────────────────────────────
    USR.NAME                                              AS REF_CREATED_BY,

    -- ── Initiated by ────────────────────────────────────────────────
    RES.DESCRIPTION                                       AS INITIATED_BY,

    -- ── Referral org ────────────────────────────────────────────────
    NGO.DESCRIPTION                                       AS REFERRAL_ORG,
    NGO.CODE                                              AS REFERRAL_ORG_CODE,
    NGO.ADDRESS_1                                         AS REFERRAL_ORG_ADDRESS,
    NGO.PHONE                                             AS REFERRAL_ORG_PHONE,
    NGO.EMAIL                                             AS REFERRAL_ORG_EMAIL,
    NGO_ZIP.POSTCODE                                      AS REFERRAL_ORG_POSTCODE,
    NGO_ZIP.CITY                                          AS REFERRAL_ORG_SUBURB,

    -- ── External requestor ──────────────────────────────────────────
    ADM.FAMILY_DOCTOR                                     AS EXT_REQUESTOR_NAME,

    -- ── Referral priority — now wired via PAC_REFERRALPRIORITY ──────
    REFPRI.DESCRIPTION                                    AS REF_PRIORITY,

    -- ── Referral source ─────────────────────────────────────────────
    ATTEND.DESCRIPTION                                    AS REF_SOURCE,
    ATTEND.CODE                                           AS REF_SOURCE_CODE,

    -- ── Internal referral team ──────────────────────────────────────
    INT_LOC.DESCRIPTION                                   AS INT_REF_TEAM,

    -- ── Referral destination ────────────────────────────────────────
    REFDEP.DESCRIPTION                                    AS REFERRAL_DESTINATION,
    REFDEP.CODE                                           AS REFERRAL_DESTINATION_CODE,

    -- ── Consent ─────────────────────────────────────────────────────
    ADM.CONSENT_REC_FUND_INFO                             AS DATA_COLLECTION_CONSENT,
    ADM.CONFIRM_REFERRAL                                  AS CONSENT_TO_REFERRAL,

    -- ── Presenting issue / complaint ────────────────────────────────
    ADM.REMARK                                            AS PRESENTING_ISSUE,
    MR.PRESENTING_COMPLAINT                               AS PRESENTING_COMPLAINT,

    -- ── Referral reason — now wired via PAC_ADMREASON ───────────────
    REA.DESCRIPTION                                       AS REFERRAL_REASON,
    ADM.ADM_REASON_DR                                     AS REFERRAL_REASON_DR_RAW,

    -- ── Assessment review — PAADM_DatePatRefferedAssess per SSIS ────
    ADM.DATE_PAT_REFFERED_ASSESS                          AS ASSESSMENT_REVIEW,

    -- ── Discharge classification — via MR_ADM → PAC_DISCHCLASSIFICATION
    DSCL.DESCRIPTION                                      AS DISCHARGE_CLASSIFICATION,

    -- ── Raw FKs kept for debugging ──────────────────────────────────
    ADM.REF_STAT_DR                                       AS REFERRAL_STATUS_DR_RAW,
    ADM.REFERRAL_PRIORITY_DR                              AS REFERRAL_PRIORITY_DR_RAW,
    ADM.APPOINT_DR                                        AS PAADM_APPOINT_DR

FROM {{ ref('prep_stg_trakcare_pa_patmas') }}             AS PAT

INNER JOIN {{ ref('prep_stg_trakcare_pa_adm') }}          AS ADM
    ON ADM.PATIENT_DR = PAT.PATIENT_ID

-- Gender from PA_PATMAS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX
    ON PAT.SEX_DR = CAST(SEX.ROW_ID AS NUMBER(18,0))

-- PA_PERSON for gender at birth and social status
LEFT JOIN {{ ref('prep_stg_trakcare_pa_person') }}        AS PER
    ON PAT.PERSON_DR = CAST(PER.PERSON_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX_BIRTH
    ON CAST(PER.BIRTH_GENDER_DR AS NUMBER(18,0)) = CAST(SEX_BIRTH.ROW_ID AS NUMBER(18,0))

-- Country of birth
LEFT JOIN {{ ref('prep_stg_trakcare_ct_country') }}       AS COB
    ON PAT.BIRTH_COUNTRY_DR = CAST(COB.ROW_ID AS NUMBER(18,0))

-- Preferred language
LEFT JOIN {{ ref('prep_stg_trakcare_pac_preferred_language') }} AS LANG
    ON PAT.PREF_LANGUAGE_DR = CAST(LANG.ROW_ID AS NUMBER(18,0))

-- Indigenous status
LEFT JOIN {{ ref('prep_stg_trakcare_pac_indig_status') }}  AS INDST
    ON PAT.INDIGENOUS_STATUS_DR = CAST(INDST.ROW_ID AS NUMBER(18,0))

-- Homeless — PAPER_SOCIALSTATUS_DR per SSIS (not ACCOM_SETTING_DR)
LEFT JOIN {{ ref('prep_stg_trakcare_ct_socialstatus') }}  AS SS
    ON CAST(PER.SOCIAL_STATUS_DR AS NUMBER(18,0)) = CAST(SS.ROW_ID AS NUMBER(18,0))

-- Primary insurance CTE
LEFT JOIN primary_insurance                               AS INS
    ON ADM.ADM_ID = INS.ADM_DR
    AND INS.RN = 1

-- CURRENT_PAYOR — ARC_INSURANCETYPE per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_arc_insurancetype') }} AS INSTYPE
    ON CAST(INS.INS_TYPE_DR AS VARCHAR) = CAST(INSTYPE.ROW_ID AS VARCHAR)

-- CURRENT_PLAN — ARC_AUXILINSURTYPE per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_arc_auxilinsurtype') }} AS AUX
    ON CAST(INS.AUX_INS_TYPE_DR AS VARCHAR) = CAST(AUX.ROW_ID AS VARCHAR)

-- CLIENT_PAYOR_NOTES — PA_PERSONADMINSURANCE via PAADM_PAPMI_DR per SSIS
LEFT JOIN client_payor_notes                              AS CPN
    ON ADM.PATIENT_DR = CPN.PAR_REF
    AND CPN.RN = 1

-- PA_ADM2 → CT_NFMI_CATEGDEPART → CT_NFMI_CATEGORY for program stream
LEFT JOIN {{ ref('prep_stg_trakcare_pa_adm2') }}      AS ADM2
    ON CAST(ADM.ADM2_DR AS VARCHAR) = CAST(ADM2.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS PROG
    ON CAST(ADM2.NFMI_CATEG_DEPART_DR AS VARCHAR) = CAST(PROG.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_category') }} AS CAT
    ON CAST(PROG.PAR_REF AS NUMBER(18,0)) = CAST(CAT.ROW_ID AS NUMBER(18,0))

-- Referral status — now wired
LEFT JOIN {{ ref('prep_stg_trakcare_pac_referralstatus') }} AS RST
    ON CAST(ADM.REF_STAT_DR AS VARCHAR) = CAST(RST.ROW_ID AS VARCHAR)

-- Service / hospital
LEFT JOIN {{ ref('prep_stg_trakcare_ct_hospital') }}      AS HOSP
    ON ADM.HOSPITAL_DR = HOSP.ROW_ID

-- Episode CP — PAADM_ADMDOCCODEDR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}      AS CP_EP
    ON CAST(ADM.ADM_DOC_CODE_DR AS VARCHAR) = CAST(CP_EP.ROW_ID AS VARCHAR)

-- Episode team — PAADM_DEPCODE_DR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_loc') }}           AS LOC_TEAM
    ON ADM.DEP_CODE_DR = LOC_TEAM.ROW_ID

-- Internal referral team
LEFT JOIN {{ ref('prep_stg_trakcare_ct_loc') }}           AS INT_LOC
    ON ADM.INTERNAL_REF_LOC_DR = INT_LOC.ROW_ID

-- Referral type
LEFT JOIN {{ ref('prep_stg_trakcare_pac_referraltype') }} AS REFT
    ON ADM.REFERRAL_TYPE_DR = REFT.ROW_ID

-- Source of attendance
LEFT JOIN {{ ref('prep_stg_trakcare_pac_sourceofattendance') }} AS ATTEND
    ON ADM.SOURCE_OF_ATTEND_DR = ATTEND.ROW_ID

-- Referral destination via DISPOS_DR
LEFT JOIN {{ ref('prep_stg_trakcare_pac_referreddeparture') }} AS REFDEP
    ON ADM.DISPOS_DR = REFDEP.ROW_ID

-- Referring organisation
LEFT JOIN {{ ref('prep_stg_trakcare_pac_nongovorg') }}    AS NGO
    ON ADM.NON_GOV_ORG_DR = NGO.ROW_ID

-- NGO zip
LEFT JOIN {{ ref('prep_stg_trakcare_ct_zip') }}           AS NGO_ZIP
    ON CAST(NGO.ZIP_DR AS NUMBER(18,0)) = NGO_ZIP.ROW_ID

-- Referral priority — now wired
LEFT JOIN {{ ref('prep_stg_trakcare_pac_referralpriority') }} AS REFPRI
    ON CAST(ADM.REFERRAL_PRIORITY_DR AS VARCHAR) = CAST(REFPRI.ROW_ID AS VARCHAR)

-- Referral created by
LEFT JOIN {{ ref('prep_stg_trakcare_ss_user') }}          AS USR
    ON ADM.CREATED_USER = USR.ROW_ID

-- Initiated by
LEFT JOIN {{ ref('prep_stg_trakcare_rb_resource') }}      AS RES
    ON ADM.CURRENT_RESOURCE_DR = RES.ROW_ID

-- MR_ADM — for presenting complaint and discharge classification
LEFT JOIN {{ ref('prep_stg_trakcare_mr_adm') }}           AS MR
    ON ADM.ADM_ID = MR.ADM_DR

-- PAC_ADMREASON — referral reason
LEFT JOIN {{ ref('prep_stg_trakcare_pac_admreason') }}    AS REA
    ON CAST(ADM.ADM_REASON_DR AS VARCHAR) = CAST(REA.ROW_ID AS VARCHAR)

-- PAC_DISCHCLASSIFICATION — via MR_ADM.DISCH_CLASSIF_DR
LEFT JOIN {{ ref('prep_stg_trakcare_pac_dischclassification') }} AS DSCL
    ON CAST(MR.DISCH_CLASSIF_DR AS VARCHAR) = CAST(DSCL.ROW_ID AS VARCHAR)

WHERE PAT.PATIENT_NO IS NOT NULL