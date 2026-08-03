WITH total_hours AS (
    SELECT
        EPISODE_ID,
        SUM(DIRECT_MINUTES) / 60.0                       AS TOTAL_HRS
    FROM {{ ref('prep_model_contact') }}
    WHERE HOSPITAL = 'Alcohol & Drug'
    GROUP BY EPISODE_ID
),

no_dtau_contacts AS (
    SELECT
        EPISODE_ID,
        COUNT(*)                                          AS NO_DTAU_CONTACTS
    FROM {{ ref('prep_model_contact') }}
    WHERE HOSPITAL = 'Alcohol & Drug'
      AND PROGRAM_STREAM_DESC ILIKE '%Bridging support%'
    GROUP BY EPISODE_ID
),

last_contact AS (
    SELECT
        EPISODE_ID,
        MAX(CONTACT_DATE)                                 AS LAST_CONTACT_DT
    FROM {{ ref('prep_model_contact') }}
    GROUP BY EPISODE_ID
),

first_contact AS (
    SELECT
        EPISODE_ID,
        MIN(CONTACT_DATE)                                 AS FIRST_CONTACT_DT
    FROM {{ ref('prep_model_contact') }}
    GROUP BY EPISODE_ID
),

first_fr AS (
    SELECT
        UR,
        MIN(FIRST_REGISTRATION)                           AS FIRST_FR
    FROM {{ ref('prep_model_vadc_form') }}
    WHERE FIRST_REGISTRATION IS NOT NULL
    GROUP BY UR
),

last_fr AS (
    SELECT
        UR,
        MAX(FIRST_REGISTRATION)                           AS LAST_FR
    FROM {{ ref('prep_model_vadc_form') }}
    WHERE FIRST_REGISTRATION IS NOT NULL
    GROUP BY UR
),

ref_in AS (
    SELECT
        VADC_EPISODE_ID,
        MIN(CHILD_SUB)                                    AS MIN_CHILD_SUB
    FROM {{ ref('prep_model_vadc_referral') }}
    WHERE REFERRAL_DIRECTION = 'Referral In'
    GROUP BY VADC_EPISODE_ID
),

ref_in_detail AS (
    SELECT
        R.VADC_EPISODE_ID,
        R.REFERRAL_DIRECTION                              AS REF_IN,
        R.REFERRAL_ORG_CODE                               AS ACSO,
        R.REFERRAL_DATE                                   AS REF_IN_DATE,
        R.REFERRAL_SOURCE_TYPE                            AS PROVIDER_IN_TYPE
    FROM {{ ref('prep_model_vadc_referral') }}            AS R
    INNER JOIN ref_in                                     AS RI
        ON R.VADC_EPISODE_ID = RI.VADC_EPISODE_ID
        AND R.CHILD_SUB = RI.MIN_CHILD_SUB
    WHERE R.REFERRAL_DIRECTION = 'Referral In'
),

ref_out AS (
    SELECT
        VADC_EPISODE_ID,
        MIN(CHILD_SUB)                                    AS MIN_CHILD_SUB
    FROM {{ ref('prep_model_vadc_referral') }}
    WHERE REFERRAL_DIRECTION = 'Referral Out'
    GROUP BY VADC_EPISODE_ID
),

ref_out_detail AS (
    SELECT
        R.VADC_EPISODE_ID,
        R.REFERRAL_DIRECTION                              AS REF_OUT,
        R.REFERRAL_SOURCE_TYPE                            AS PROVIDER_OUT_TYPE
    FROM {{ ref('prep_model_vadc_referral') }}            AS R
    INNER JOIN ref_out                                    AS RO
        ON R.VADC_EPISODE_ID = RO.VADC_EPISODE_ID
        AND R.CHILD_SUB = RO.MIN_CHILD_SUB
    WHERE R.REFERRAL_DIRECTION = 'Referral Out'
),

no_ref_ins AS (
    SELECT
        VADC_EPISODE_ID,
        COUNT(VADC_PROGREF_ID)                            AS NO_REF_INS
    FROM {{ ref('prep_model_vadc_referral') }}
    WHERE REFERRAL_DIRECTION = 'Referral In'
    GROUP BY VADC_EPISODE_ID
),

primary_doc AS (
    SELECT
        VADC_OUTCOME_ID,
        MIN(CHILD_SUB)                                    AS MIN_CHILD_SUB
    FROM {{ ref('prep_model_vadc_drug') }}
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
    FROM {{ ref('prep_model_vadc_drug') }}                AS D
    INNER JOIN primary_doc                                AS PD
        ON D.VADC_OUTCOME_ID = PD.VADC_OUTCOME_ID
        AND D.CHILD_SUB = PD.MIN_CHILD_SUB
    WHERE D.AGE_OF_FIRST_USE ILIKE '%principal drug of concern%'
),

outcome_latest AS (
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
    FROM {{ ref('prep_model_vadc_outcome') }}
)

SELECT
    -- ── Legacy org — derived from EpisodeTeam per SSIS ──────────────
    CASE
        WHEN EP.EPISODE_TEAM ILIKE '%Prahran%'
          OR EP.EPISODE_TEAM ILIKE '%Southport%'
          OR EP.EPISODE_TEAM ILIKE '%Bentleigh East%'
          OR EP.EPISODE_TEAM ILIKE '%Fitzroy St%'
          OR EP.EPISODE_TEAM ILIKE '%Pharmacotherapy%'
            THEN 1
        WHEN EP.EPISODE_TEAM ILIKE '%Parkdale%'
          OR EP.EPISODE_TEAM ILIKE '%Chelsea%'
          OR EP.EPISODE_TEAM IN (
              'AOD Counselling', 'AOD Brief Intervention',
              'AOD Assessment', 'AOD and Counselling'
          )   THEN 2
    END                                                   AS LEGACY_ORGANISATION_ID,

    CASE
        WHEN EP.EPISODE_TEAM ILIKE '%Prahran%'
          OR EP.EPISODE_TEAM ILIKE '%Southport%'
          OR EP.EPISODE_TEAM ILIKE '%Bentleigh East%'
          OR EP.EPISODE_TEAM ILIKE '%Fitzroy St%'
          OR EP.EPISODE_TEAM ILIKE '%Pharmacotherapy%'
            THEN 'Star Health'
        WHEN EP.EPISODE_TEAM ILIKE '%Parkdale%'
          OR EP.EPISODE_TEAM ILIKE '%Chelsea%'
          OR EP.EPISODE_TEAM IN (
              'AOD Counselling', 'AOD Brief Intervention',
              'AOD Assessment', 'AOD and Counselling'
          )   THEN 'Central Bayside'
    END                                                   AS LEGACY_ORGANISATION_NAME,

    -- ── Episode identity ────────────────────────────────────────────
    'SH' || EP.EPISODE_ID::VARCHAR                        AS IEPISODE_ID,
    EP.EPISODE_ID,
    'SH' || EP.UR::VARCHAR                                AS IUR,
    EP.UR,

    -- ── Client demographics ─────────────────────────────────────────
    CL.DOB,
    CL.AGE,
    CL.GENDER,
    FORM.BIRTH_SEX                                        AS GENDER_AT_BIRTH,
    FORM.ATSI_STATUS                                      AS INDIG,
    FORM.ATSI,
    CL.MEDICARE_NO,
    CL.MEDICARE_NO_1,

    -- ── Episode dates ───────────────────────────────────────────────
    EP.EPISODE_DT,
    EP.DISCHARGE_DT,
    EP.SERVICE,
    EP.EPISODE_CP,
    EP.EPISODE_TEAM,
    EP.REF_TYPE,
    EP.REF_REC_DT,
    EP.REF_CREATE_DT,
    EP.INITIATED_BY,
    EP.REFERRAL_ORG,
    EP.EXT_REQUESTOR_NAME,
    EP.REF_PRIORITY,
    EP.REF_SOURCE,
    EP.INT_REF_TEAM,
    EP.REFERRAL_DESTINATION,
    EP.PRESENTING_COMPLAINT,
    EP.REFERRAL_REASON,
    EP.ASSESSMENT_REVIEW,
    NULL::VARCHAR                                         AS DOWNGRADE,
    EP.EPISODE_ACTIVE,
    EP.DAYS_OPEN,

    -- ── VADC program stream ─────────────────────────────────────────
    EP.PROGRAM_STREAM_CODE,
    CASE
        WHEN EP.PROGRAM_STREAM_CODE = 'AODACSOA'  THEN 'AD71-100'
        WHEN EP.PROGRAM_STREAM_CODE = 'AODTSCOU5' THEN 'AD20-100'
        WHEN EP.PROGRAM_STREAM_CODE = 'AODTSCRC5' THEN 'AD50-100'
        WHEN EP.PROGRAM_STREAM_CODE = 'AODTSNRW5' THEN 'AD11-100'
        ELSE EP.PROGRAM_STREAM_CODE
    END                                                   AS MAPPED_PROGRAM_STREAM_CODE,
    EP.PROGRAM_STREAM_DESC                                AS PROGRAM_STREAM,
    EP.GOVT_CAT_CODE                                      AS PARENT_STREAM,
    REPLACE(EP.PROGRAM_STREAM_DESC, '–', '-')             AS STREAM,
    NULL::VARCHAR                                         AS DTAU_STREAM,

    -- ── VADC questionnaire fields ───────────────────────────────────
    FORM.VADC_EPISODE_ID                                  AS Q_ROW_ID,
    FORM.MARAM_RISK                                       AS QVADCMARAM,
    COALESCE(FORM.FORENSIC_TYPE, 'Non Forensic')          AS FORENSIC_TYPE,
    NULL::VARCHAR                                         AS FORENSIC_DESC,
    FORM.FAMILY_VIOLENCE_FLAG                             AS QVADCFAM_VIOLENCE,
    FORM.TARGET_GROUP,
    COALESCE(
        FORM.TREATMENT_LENGTH::VARCHAR,
        'Not stated / inadequately described'
    )                                                     AS END_OF_TREATMENT_REASON,
    FORM.PERCENTAGE_COMPLETED,
    FORM.EPISODE_ID                                       AS SERVICE_EVENT_REF,
    FORM.QUESTIONNAIRE_DATE                               AS VADC_QUESTIONNAIRE_DATE,
    FORM.EPISODE_CP                                       AS VADC_QUESTION_CP,
    FORM.FIRST_REGISTRATION                               AS QVADCFIRSTREG,
    FORM.PRESENTING_DRUG_OF_CONCERN                       AS QVADCOUTCODE,
    FORM.ASSESSMENT_COMPLETED                             AS QVADCASSESS_COMP,
    FORM.TREATMENT_LENGTH,
    CASE
        WHEN FORM.TREATMENT_LENGTH IN ('Extended', 'Complex Client')
            THEN 'Complex'
        ELSE 'Standard'
    END                                                   AS PROGRAM_TYPE,
    FORM.MALTREATMENT_FLAG                                AS QVADCMALTRT,
    FORM.MALTREATMENT_PERPETRATOR                         AS PERPETRATOR,

    -- ── Outcome fields ──────────────────────────────────────────────
    OUTC.VADC_OUTCOME_ID                                  AS OUTCOME_ID,
    OUTC.VADC_OUTCOME_DATE                                AS OUTC_DATE,
    OUTC.K10_SCORE,

    -- ── PROGREF / referral in-out ────────────────────────────────────
    NRI.NO_REF_INS,
    RID.REF_IN,
    ROD.REF_OUT,
    RID.REF_IN_DATE,
    RID.ACSO,
    RID.PROVIDER_IN_TYPE,
    ROD.PROVIDER_OUT_TYPE,

    -- ── First / last FR ─────────────────────────────────────────────
    FFR.FIRST_FR,
    LFR.LAST_FR,

    -- ── Contact summary ─────────────────────────────────────────────
    LCO.LAST_CONTACT_DT,
    FCO.FIRST_CONTACT_DT,

    -- ── Drug of concern ─────────────────────────────────────────────
    PDC.MIN_CHILD_SUB                                     AS NUM_PRIMARY_DRUG_OF_CONCERN,
    PDD.PRINCIPAL_DOC,
    PDD.DOC_DATE,
    PDD.DOC_OCCURRENCE,
    PDD.DOC_METHOD,
    PDD.DOC_QUANTITY,
    PDD.DOC_MEASURE,

    -- ── Hours ───────────────────────────────────────────────────────
    COALESCE(TH.TOTAL_HRS, 0)                             AS TOTAL_HRS,
    NULL::FLOAT                                           AS DIRECT,
    COALESCE(NDC.NO_DTAU_CONTACTS, 0)                     AS NO_DTAU_CONTACTS,
    NULL::VARCHAR                                         AS RELATIONSHIP_TO_SELF,

    -- ── Validity ────────────────────────────────────────────────────
    CASE
        WHEN FORM.VADC_EPISODE_ID IS NULL
            THEN 'VADC Questionnaire must be attached to be valid'
        WHEN COALESCE(TH.TOTAL_HRS, 0) <= 0
            THEN 'The episode must have at least one contact to be valid'
        WHEN FORM.PERCENTAGE_COMPLETED IN (
            'Not Stated / Inadequately Described', 'None of course completed'
        )   THEN 'Percentage Completed must be at least 25% to be Valid'
        WHEN (
            LEFT(EP.PROGRAM_STREAM_CODE, 4) IN ('AD71', 'AD11', 'AD20', 'AD50')
            OR EP.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
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
              LEFT(EP.PROGRAM_STREAM_CODE, 4) IN ('AD11', 'AD20', 'AD50')
              OR EP.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
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
              LEFT(EP.PROGRAM_STREAM_CODE, 4) IN ('AD11', 'AD20', 'AD50')
              OR EP.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
          )   THEN 'Assessment date cannot be greater than first contact date to be valid'
        WHEN FORM.FIRST_REGISTRATION IS NULL
          AND (
              LEFT(EP.PROGRAM_STREAM_CODE, 4) IN ('AD21', 'AD52', 'AD71', 'AD11', 'AD20', 'AD50')
              OR EP.PROGRAM_STREAM_CODE IN ('AODTSCOU5', 'AODTSCRC5', 'AODTSNRW5')
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

FROM {{ ref('prep_model_episode') }}                      AS EP

LEFT JOIN {{ ref('prep_model_vadc_form') }}               AS FORM
    ON EP.EPISODE_ID = FORM.EPISODE_ID

LEFT JOIN {{ ref('prep_model_client') }}           AS CL
    ON EP.UR = CL.UR

LEFT JOIN outcome_latest                                  AS OUTC
    ON EP.EPISODE_ID = OUTC.EPISODE_ID
    AND OUTC.RN = 1

LEFT JOIN total_hours                                     AS TH
    ON EP.EPISODE_ID = TH.EPISODE_ID

LEFT JOIN no_dtau_contacts                                AS NDC
    ON EP.EPISODE_ID = NDC.EPISODE_ID

LEFT JOIN last_contact                                    AS LCO
    ON EP.EPISODE_ID = LCO.EPISODE_ID

LEFT JOIN first_contact                                   AS FCO
    ON EP.EPISODE_ID = FCO.EPISODE_ID

LEFT JOIN first_fr                                        AS FFR
    ON EP.UR = FFR.UR

LEFT JOIN last_fr                                         AS LFR
    ON EP.UR = LFR.UR

LEFT JOIN no_ref_ins                                      AS NRI
    ON FORM.VADC_EPISODE_ID = NRI.VADC_EPISODE_ID

LEFT JOIN ref_in_detail                                   AS RID
    ON FORM.VADC_EPISODE_ID = RID.VADC_EPISODE_ID

LEFT JOIN ref_out_detail                                  AS ROD
    ON FORM.VADC_EPISODE_ID = ROD.VADC_EPISODE_ID

LEFT JOIN primary_doc                                     AS PDC
    ON OUTC.VADC_OUTCOME_ID = PDC.VADC_OUTCOME_ID

LEFT JOIN primary_doc_detail                              AS PDD
    ON OUTC.VADC_OUTCOME_ID = PDD.VADC_OUTCOME_ID

WHERE EP.PROGRAM_STREAM_CODE ILIKE 'AD%'
   OR EP.PROGRAM_STREAM_CODE ILIKE 'AOD%'