WITH total_hours AS (
    -- Total direct hours per episode from AOD contacts
    SELECT
        EPISODE_ID,
        SUM(DIRECT_MINUTES) / 60.0                       AS TOTAL_HRS
    FROM {{ ref('prep_src_contact_trakcare') }}
    WHERE HOSPITAL = 'Alcohol & Drug'
    GROUP BY EPISODE_ID
),

no_dtau_contacts AS (
    -- Count of DTAU/Bridging support contacts per episode
    SELECT
        EPISODE_ID,
        COUNT(*) AS NO_DTAU_CONTACTS
    FROM {{ ref('prep_src_contact_trakcare') }}
    WHERE HOSPITAL = 'Alcohol & Drug'
      AND PROGRAM_STREAM_DESC ILIKE '%Bridging support%'
    GROUP BY EPISODE_ID
),

last_contact AS (
    -- Last contact date per episode
    SELECT
        EPISODE_ID,
        MAX(CONTACT_DATE)                                 AS LAST_CONTACT_DT
    FROM {{ ref('prep_src_contact_trakcare') }}
    GROUP BY EPISODE_ID
),

first_contact AS (
    -- First contact date per episode
    SELECT
        EPISODE_ID,
        MIN(CONTACT_DATE)                                 AS FIRST_CONTACT_DT
    FROM {{ ref('prep_src_contact_trakcare') }}
    GROUP BY EPISODE_ID
),

first_fr AS (
    -- First QVADCFIRSTREG per UR across all VADC questionnaires
    SELECT
        UR,
        MIN(FIRST_REGISTRATION)                           AS FIRST_FR
    FROM {{ ref('prep_src_vadc_form_trakcare') }}
    WHERE FIRST_REGISTRATION IS NOT NULL
    GROUP BY UR
),

last_fr AS (
    -- Last QVADCFIRSTREG per UR across all VADC questionnaires
    SELECT
        UR,
        MAX(FIRST_REGISTRATION)                           AS LAST_FR
    FROM {{ ref('prep_src_vadc_form_trakcare') }}
    WHERE FIRST_REGISTRATION IS NOT NULL
    GROUP BY UR
),

ref_in AS (
    -- First referral IN per VADC episode
    SELECT
        VADC_EPISODE_ID,
        MIN(CHILD_SUB)                                    AS MIN_CHILD_SUB
    FROM {{ ref('prep_src_vadc_referral_trakcare') }}
    WHERE REFERRAL_DIRECTION = 'Referral In'
    GROUP BY VADC_EPISODE_ID
),

ref_in_detail AS (
    -- Detail of first referral IN
    SELECT
        R.VADC_EPISODE_ID,
        R.REFERRAL_DIRECTION                              AS REF_IN,
        R.REFERRAL_ORG_CODE                               AS ACSO,
        R.REFERRAL_DATE                                   AS REF_IN_DATE,
        R.REFERRAL_SOURCE_TYPE                            AS PROVIDER_IN_TYPE
    FROM {{ ref('prep_src_vadc_referral_trakcare') }}     AS R
    INNER JOIN ref_in                                     AS RI
        ON R.VADC_EPISODE_ID = RI.VADC_EPISODE_ID
        AND R.CHILD_SUB = RI.MIN_CHILD_SUB
    WHERE R.REFERRAL_DIRECTION = 'Referral In'
),

ref_out AS (
    -- First referral OUT per VADC episode
    SELECT
        VADC_EPISODE_ID,
        MIN(CHILD_SUB)                                    AS MIN_CHILD_SUB
    FROM {{ ref('prep_src_vadc_referral_trakcare') }}
    WHERE REFERRAL_DIRECTION = 'Referral Out'
    GROUP BY VADC_EPISODE_ID
),

ref_out_detail AS (
    -- Detail of first referral OUT
    SELECT
        R.VADC_EPISODE_ID,
        R.REFERRAL_DIRECTION                              AS REF_OUT,
        R.REFERRAL_SOURCE_TYPE                            AS PROVIDER_OUT_TYPE
    FROM {{ ref('prep_src_vadc_referral_trakcare') }}     AS R
    INNER JOIN ref_out                                    AS RO
        ON R.VADC_EPISODE_ID = RO.VADC_EPISODE_ID
        AND R.CHILD_SUB = RO.MIN_CHILD_SUB
    WHERE R.REFERRAL_DIRECTION = 'Referral Out'
),

no_ref_ins AS (
    -- Count of referral INs per VADC episode
    SELECT
        VADC_EPISODE_ID,
        COUNT(VADC_PROGREF_ID)                            AS NO_REF_INS
    FROM {{ ref('prep_src_vadc_referral_trakcare') }}
    WHERE REFERRAL_DIRECTION = 'Referral In'
    GROUP BY VADC_EPISODE_ID
),

primary_doc AS (
    -- Primary drug of concern per outcome
    -- IS_PRINCIPAL_DRUG maps to QVADCOUTDOCQ5 = 'This drug is the client's principal drug of concern'
    SELECT
        VADC_OUTCOME_ID,
        COUNT(VADC_DOC_ID)                                AS NUM_PRIMARY_DRUG,
        MIN(CHILD_SUB)                                    AS MIN_CHILD_SUB
    FROM {{ ref('prep_src_vadc_drug_trakcare') }}
    WHERE AGE_OF_FIRST_USE ILIKE '%principal drug of concern%'
    GROUP BY VADC_OUTCOME_ID
),

primary_doc_detail AS (
    SELECT
        D.VADC_OUTCOME_ID,
        D.DRUG_TYPE_CODE                                  AS PRINCIPAL_DOC,
        D.USE_FREQUENCY                                   AS DOC_DATE,
        D.USE_FREQUENCY                                   AS DOC_OCCURRENCE,
        D.METHOD_OF_USE                                   AS DOC_METHOD,
        D.INJECTION_FLAG                                  AS DOC_QUANTITY,
        D.ADDITIONAL_FLAGS                                AS DOC_MEASURE
    FROM {{ ref('prep_src_vadc_drug_trakcare') }}         AS D
    INNER JOIN primary_doc                                AS PD
        ON D.VADC_OUTCOME_ID = PD.VADC_OUTCOME_ID
        AND D.CHILD_SUB = PD.MIN_CHILD_SUB
    WHERE D.AGE_OF_FIRST_USE ILIKE '%principal drug of concern%'
),

outcome_latest AS (
    -- Latest outcome per episode — ROW_NUMBER to get most recent
    SELECT
        EPISODE_ID,
        VADC_OUTCOME_ID,
        OUTCOME_DATE,
        VADC_OUTCOME_DATE,
        K10_SCORE,
        ROW_NUMBER() OVER (
            PARTITION BY EPISODE_ID
            ORDER BY OUTCOME_DATE DESC NULLS LAST
        )                                                 AS RN
    FROM {{ ref('prep_src_vadc_outcome_trakcare') }}
)

SELECT

    EP.UR                                                 AS UR,

    -- ── Client demographics ─────────────────────────────────────────
    CL.DOB                                                AS DOB,
    CL.AGE                                                AS AGE,
    CL.GENDER                                             AS GENDER,
    FORM.BIRTH_SEX                                        AS GENDER_AT_BIRTH,
    FORM.ATSI_STATUS                                      AS INDIG,
    FORM.ATSI                                             AS ATSI,
    CL.MEDICARE_NO                                        AS MEDICARE_NO,
    CL.MEDICARE_NO_1                                      AS MEDICARE_NO_1,

    -- ── Episode dates ───────────────────────────────────────────────
    EP.EPISODE_DT                                         AS EPISODE_DT,
    EP.DISCHARGE_DT                                       AS DISCHARGE_DT,

    -- ── Episode team / service / CP ─────────────────────────────────
    EP.SERVICE                                            AS SERVICE,
    EP.EPISODE_CP                                         AS EPISODE_CP,
    EP.EPISODE_TEAM                                       AS EPISODE_TEAM,

    -- ── Referral fields ─────────────────────────────────────────────
    EP.REF_TYPE                                           AS REF_TYPE,
    EP.REF_REC_DT                                         AS REF_REC_DT,
    EP.REF_CREATE_DT                                      AS REF_CREATE_DT,
    EP.INT_REF_TEAM                                       AS INT_REF_TEAM,
    EP.REFERRAL_ORG                                       AS REFERRAL_ORG,
    EP.EXT_REQUESTOR_NAME                                 AS EXT_REQUESTOR_NAME,
    NULL::VARCHAR                                         AS REF_PRIORITY,
    EP.REF_SOURCE                                         AS REF_SOURCE,
    EP.REFERRAL_DESTINATION                               AS REFERRAL_DESTINATION,

    -- ── Presenting complaint / referral reason ──────────────────────
    NULL::VARCHAR                                         AS PRESENTING_COMPLAINT,
    EP.REFERRAL_REASON                                    AS REFERRAL_REASON,

    -- ── Assessment review / downgrade — pending ─────────────────────
    NULL::VARCHAR                                         AS ASSESSMENT_REVIEW,
    NULL::VARCHAR                                         AS DOWNGRADE,

    -- ── Program stream ──────────────────────────────────────────────
    EP.EPISODE_ACTIVE                                     AS EPISODE_ACTIVE,
    EP.DAYS_OPEN                                          AS DAYS_OPEN,

    -- ── VADC program stream ─────────────────────────────────────────
    PROG.PROGRAM_STREAM_CODE                              AS PROGRAM_STREAM_CODE,

    -- Mapped program stream code per SSIS remapping
    CASE
        WHEN PROG.PROGRAM_STREAM_CODE = 'AODACSOA'  THEN 'AD71-100'
        WHEN PROG.PROGRAM_STREAM_CODE = 'AODTSCOU5' THEN 'AD20-100'
        WHEN PROG.PROGRAM_STREAM_CODE = 'AODTSCRC5' THEN 'AD50-100'
        WHEN PROG.PROGRAM_STREAM_CODE = 'AODTSNRW5' THEN 'AD11-100'
        ELSE PROG.PROGRAM_STREAM_CODE
    END                                                   AS MAPPED_PROGRAM_STREAM_CODE,

    PROG.PROGRAM_STREAM_DESC                              AS PROGRAM_STREAM,
    PROG.GOVT_CAT_CODE                                    AS PARENT_STREAM,

    -- Stream — replace en-dash with hyphen per SSIS logic
    REPLACE(PROG.STREAM, '–', '-')                        AS STREAM,

    -- DTAU_Stream — placeholder pending confirmation of derivation
    NULL::VARCHAR                                         AS DTAU_STREAM,

    -- ── VADC questionnaire fields ───────────────────────────────────
    FORM.VADC_EPISODE_ID                                  AS Q_ROW_ID,
    FORM.MARAM_RISK                                       AS QVADCMARAM,
    COALESCE(FORM.FORENSIC_TYPE, 'Non Forensic')          AS FORENSIC_TYPE,
    NULL::VARCHAR                                         AS FORENSIC_DESC,
    FORM.FAMILY_VIOLENCE_FLAG                             AS QVADCFAM_VIOLENCE,
    FORM.TARGET_GROUP                                     AS TARGET_GROUP,
    COALESCE(
        FORM.TREATMENT_LENGTH::VARCHAR,
        'Not stated / inadequately described'
    )                                                     AS END_OF_TREATMENT_REASON,
    FORM.PERCENTAGE_COMPLETED                             AS PERCENTAGE_COMPLETED,
    FORM.EPISODE_ID                                       AS SERVICE_EVENT_REF,
    FORM.QUESTIONNAIRE_DATE                               AS VADC_QUESTIONNAIRE_DATE,
    FORM.EPISODE_CP                                       AS VADC_QUESTION_CP,
    FORM.FIRST_REGISTRATION                               AS QVADCFIRSTREG,
    FORM.PRESENTING_DRUG_OF_CONCERN                       AS QVADCOUTCODE,
    FORM.ASSESSMENT_COMPLETED                             AS QVADCASSESS_COMP,
    FORM.TREATMENT_LENGTH                                 AS TREATMENT_LENGTH,
    FORM.MALTREATMENT_FLAG                                AS QVADCMALTRT,
    FORM.MALTREATMENT_PERPETRATOR                         AS PERPETRATOR,

    -- ── Program type derived from treatment length ───────────────────
    CASE
        WHEN FORM.TREATMENT_LENGTH IN ('Extended', 'Complex Client')
            THEN 'Complex'
        ELSE 'Standard'
    END                                                   AS PROGRAM_TYPE,

    -- ── Outcome fields ──────────────────────────────────────────────
    OUTC.VADC_OUTCOME_ID                                  AS OUTCOME_ID,
    OUTC.VADC_OUTCOME_DATE                                AS OUTC_DATE,
    OUTC.K10_SCORE                                        AS K10_SCORE,

    -- ── PROGREF / referral in-out fields ────────────────────────────
    NRI.NO_REF_INS                                        AS NO_REF_INS,
    RID.REF_IN                                            AS REF_IN,
    ROD.REF_OUT                                           AS REF_OUT,
    RID.REF_IN_DATE                                       AS REF_IN_DATE,
    RID.ACSO                                              AS ACSO,
    RID.PROVIDER_IN_TYPE                                  AS PROVIDER_IN_TYPE,
    ROD.PROVIDER_OUT_TYPE                                 AS PROVIDER_OUT_TYPE,

    -- ── First / last QVADCFIRSTREG across client history ────────────
    FFR.FIRST_FR                                          AS FIRST_FR,
    LFR.LAST_FR                                           AS LAST_FR,

    -- ── Contact summary fields ──────────────────────────────────────
    LCO.LAST_CONTACT_DT                                   AS LAST_CONTACT_DT,
    FCO.FIRST_CONTACT_DT                                  AS FIRST_CONTACT_DT,

    -- ── Drug of concern fields ──────────────────────────────────────
    PDC.NUM_PRIMARY_DRUG                                  AS NUM_PRIMARY_DRUG_OF_CONCERN,
    PDD.PRINCIPAL_DOC                                     AS PRINCIPAL_DOC,
    PDD.DOC_DATE                                          AS DOC_DATE,
    PDD.DOC_OCCURRENCE                                    AS DOC_OCCURRENCE,
    PDD.DOC_METHOD                                        AS DOC_METHOD,
    PDD.DOC_QUANTITY                                      AS DOC_QUANTITY,
    PDD.DOC_MEASURE                                       AS DOC_MEASURE,

    -- ── Hours ───────────────────────────────────────────────────────
    COALESCE(TH.TOTAL_HRS, 0)                             AS TOTAL_HRS,
    NULL::FLOAT                                           AS DIRECT,

    -- ── DTAU contact count ──────────────────────────────────────────
    COALESCE(NDC.NO_DTAU_CONTACTS, 0)                     AS NO_DTAU_CONTACTS,

    -- ── Relationship to self — placeholder ──────────────────────────
    NULL::VARCHAR                                         AS RELATIONSHIP_TO_SELF,

    -- ── Validity check ──────────────────────────────────────────────
    CASE
        WHEN FORM.VADC_EPISODE_ID IS NULL
            THEN 'VADC Questionnaire must be attached to be valid'
        WHEN COALESCE(TH.TOTAL_HRS, 0) <= 0
            THEN 'The episode must have at least one contact to be valid'
        WHEN FORM.PERCENTAGE_COMPLETED IN (
            'Not Stated / Inadequately Described',
            'None of course completed'
        )   THEN 'Percentage Completed must be at least 25% to be Valid'
        WHEN (
            LEFT(PROG.PROGRAM_STREAM_CODE, 4) IN ('AD71', 'AD11', 'AD20', 'AD50')
            OR PROG.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
        ) AND OUTC.VADC_OUTCOME_ID IS NULL
            THEN 'An outcome Questionnaire must be present to be valid'
        WHEN OUTC.VADC_OUTCOME_ID IS NOT NULL
          AND OUTC.VADC_OUTCOME_DATE > EP.DISCHARGE_DT
            THEN 'Outcome Questionnaire completed after discharge Date'
        WHEN COALESCE(
                FORM.TREATMENT_LENGTH::VARCHAR,
                'Not stated / inadequately described'
             ) = 'Not stated / inadequately described'
          AND (
              LEFT(PROG.PROGRAM_STREAM_CODE, 4) IN ('AD11', 'AD20', 'AD50')
              OR PROG.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
          )   THEN 'End of Treatment Reason must be completed to be valid'
        WHEN ROD.REF_OUT IS NOT NULL
          AND ROD.PROVIDER_OUT_TYPE IN ('Self', 'Family member/friend')
            THEN 'Self or Family member/friend are not valid provider types for Referral out'
        WHEN RID.REF_IN IS NOT NULL
          AND RID.PROVIDER_IN_TYPE NOT IN (
              'Police', 'Court', 'Self',
              'Family member/friend', 'Correctional Service'
          )   THEN 'Police, Court, Correctional Service, Self or Family member/friend are the only valid provider types for Referral in'
        WHEN EP.DISCHARGE_DT < LCO.LAST_CONTACT_DT
            THEN 'Discharge dt must be greater than Last contactdt to be Valid'
        WHEN FORM.ASSESSMENT_COMPLETED > FCO.FIRST_CONTACT_DT
          AND (
              LEFT(PROG.PROGRAM_STREAM_CODE, 4) IN ('AD11', 'AD20', 'AD50')
              OR PROG.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
          )   THEN 'Assessment date cannot be greater than first contact date to be valid'
        WHEN FORM.FIRST_REGISTRATION IS NULL
          AND (
              LEFT(PROG.PROGRAM_STREAM_CODE, 4) IN ('AD21', 'AD52', 'AD71', 'AD11', 'AD20', 'AD50')
              OR PROG.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
          )   THEN 'Date first registered cannot be empty to be Valid'
        WHEN EP.EPISODE_DT > FCO.FIRST_CONTACT_DT
            THEN 'Episode Date cannot be greater than First Contactdt to be valid'
        WHEN FCO.FIRST_CONTACT_DT > EP.DISCHARGE_DT
            THEN 'Contact cannot occur after discharge date to be valid'
        WHEN RID.REF_IN IS NOT NULL
          AND RID.REF_IN_DATE > EP.EPISODE_DT
            THEN 'Referral IN Date cannot be greater than Episode start date to be valid'
        WHEN RID.REF_IN IS NOT NULL
          AND RID.REF_IN_DATE > FCO.FIRST_CONTACT_DT
            THEN 'Referral IN Date cannot be greater than First Contact date to be valid'
        ELSE 'Valid'
    END                                                   AS VALIDITY

FROM {{ ref('prep_src_episode_trakcare') }}               AS EP

-- VADC form / questionnaire
LEFT JOIN {{ ref('prep_src_vadc_form_trakcare') }}        AS FORM
    ON EP.EPISODE_ID = FORM.EPISODE_ID

-- Client demographics
LEFT JOIN {{ ref('prep_src_client_trakcare_sean') }}           AS CL
    ON EP.UR = CL.UR

-- Program stream
LEFT JOIN {{ ref('prep_ref_program') }}          AS PROG
    ON EP.EPISODE_ID = PROG.PROGRAM_STREAM_CODE

-- Outcome — latest per episode
LEFT JOIN outcome_latest                                  AS OUTC
    ON EP.EPISODE_ID = OUTC.EPISODE_ID
    AND OUTC.RN = 1

-- Contact summary CTEs
LEFT JOIN total_hours                                     AS TH
    ON EP.EPISODE_ID = TH.EPISODE_ID

LEFT JOIN no_dtau_contacts                                AS NDC
    ON EP.EPISODE_ID = NDC.EPISODE_ID

LEFT JOIN last_contact                                    AS LCO
    ON EP.EPISODE_ID = LCO.EPISODE_ID

LEFT JOIN first_contact                                   AS FCO
    ON EP.EPISODE_ID = FCO.EPISODE_ID

-- First/last QVADCFIRSTREG
LEFT JOIN first_fr                                        AS FFR
    ON EP.UR = FFR.UR

LEFT JOIN last_fr                                         AS LFR
    ON EP.UR = LFR.UR

-- Referral in/out
LEFT JOIN no_ref_ins                                      AS NRI
    ON FORM.VADC_EPISODE_ID = NRI.VADC_EPISODE_ID

LEFT JOIN ref_in_detail                                   AS RID
    ON FORM.VADC_EPISODE_ID = RID.VADC_EPISODE_ID

LEFT JOIN ref_out_detail                                  AS ROD
    ON FORM.VADC_EPISODE_ID = ROD.VADC_EPISODE_ID

-- Drug of concern
LEFT JOIN primary_doc                                     AS PDC
    ON OUTC.VADC_OUTCOME_ID = PDC.VADC_OUTCOME_ID

LEFT JOIN primary_doc_detail                              AS PDD
    ON OUTC.VADC_OUTCOME_ID = PDD.VADC_OUTCOME_ID

WHERE PROG.PROGRAM_STREAM_CODE ILIKE 'AD%'
   OR PROG.PROGRAM_STREAM_CODE ILIKE 'AOD%'