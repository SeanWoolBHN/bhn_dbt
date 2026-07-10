SELECT
    -- ── Surrogate keys (placeholders) ──────────────────────────────
    'ADS_PROGREF_KEY'                                     AS ADS_PROGREF_KEY,
    'ADS_EPISODE_KEY'                                     AS ADS_EPISODE_KEY,

    -- ── Natural keys ────────────────────────────────────────────────
    REF.VADC_PROG_REF_KEY                                 AS VADC_PROG_REF_KEY,
    REF.VADC_ID                                           AS ADS_EPISODE_ID_RAW,
    REF.QUES_PAR_REF_DR                                   AS PARENT_VADC_DR_RAW,
    REF.CHILD_SUB                                         AS CHILD_SUB,

    -- ── Referral fields ─────────────────────────────────────────────
    REF.VADC_PROG_REF_Q1                                  AS REFERRAL_SOURCE_TYPE,
    REF.VADC_PROG_REF_Q2                                  AS REFERRAL_DIRECTION,
    REF.VADC_PROG_REF_Q3                                  AS REFERRAL_ORG_CODE,
    REF.VADC_PROG_REF_Q4                                  AS REFERRAL_DATE,
    REF.VADC_PROG_REF_Q5                                  AS REFERRAL_NOTES,

    -- ── Source system ───────────────────────────────────────────────
    'TRAKCARE'                                            AS SOURCE_SYSTEM

FROM {{ ref('prep_stg_trakcare_qauxxadvadcqqvadcprogref') }} AS REF

WHERE REF.VADC_ID IS NOT NULL