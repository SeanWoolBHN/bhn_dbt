WITH slk AS (
    SELECT
        RT.PAT_NO_DR,
        RT.MR_NO,
        ROW_NUMBER() OVER (
            PARTITION BY RT.PAT_NO_DR
            ORDER BY RT.ROW_ID DESC
        ) AS RN
    FROM {{ ref('prep_stg_trakcare_rt_master') }}         AS RT
    INNER JOIN {{ ref('prep_stg_trakcare_rtc_mrecordtype') }} AS TYP
        ON CAST(RT.MR_TYPE_DR AS NUMBER(18,0)) = CAST(TYP.ROW_ID AS NUMBER(18,0))
    WHERE TYP.CODE = 'SLK'
),

mac AS (
    SELECT
        RT.PAT_NO_DR,
        RT.MR_NO,
        ROW_NUMBER() OVER (
            PARTITION BY RT.PAT_NO_DR
            ORDER BY RT.ROW_ID DESC
        ) AS RN
    FROM {{ ref('prep_stg_trakcare_rt_master') }}         AS RT
    INNER JOIN {{ ref('prep_stg_trakcare_rtc_mrecordtype') }} AS TYP
        ON CAST(RT.MR_TYPE_DR AS NUMBER(18,0)) = CAST(TYP.ROW_ID AS NUMBER(18,0))
    WHERE TYP.CODE = 'MAC'
),

ndis AS (
    SELECT
        RT.PAT_NO_DR,
        RT.MR_NO,
        ROW_NUMBER() OVER (
            PARTITION BY RT.PAT_NO_DR
            ORDER BY RT.ROW_ID DESC
        ) AS RN
    FROM {{ ref('prep_stg_trakcare_rt_master') }}         AS RT
    INNER JOIN {{ ref('prep_stg_trakcare_rtc_mrecordtype') }} AS TYP
        ON CAST(RT.MR_TYPE_DR AS NUMBER(18,0)) = CAST(TYP.ROW_ID AS NUMBER(18,0))
    WHERE TYP.CODE = 'NDIS'
)

SELECT
    -- ── Identity ────────────────────────────────────────────────────
    PAT.PATIENT_NO::VARCHAR                               AS UR,
    PER.PERSON_ID                                         AS PAPER_ROW_ID,
    CAST(PER.PATIENT_DR AS VARCHAR)                       AS PAPER_PAPMI_DR,
    PAT.PATIENT_ID                                        AS PAPMI_ROW_ID,

    -- ── Name ────────────────────────────────────────────────────────
    -- SSIS uses PAPMI_NAME fields — mapped to our STG aliases
    UPPER(NULLIF(TRIM(PAT.LAST_NAME), ''))                AS SURNAME,
    PAT.FIRST_NAME                                        AS FIRSTNAME,
    PAT.MIDDLE_NAME                                       AS OTHER_NAME,
    TTL.DESC                                              AS TITLE,
    PER.NAME_4                                            AS PREFERRED_NAME,

    -- ── Date of birth ───────────────────────────────────────────────
    PAT.DOB                                               AS DOB,
    PER.EST_DOB                                           AS EST_DOB,
    PER.AGE_YR                                            AS AGE,
    PER.DECEASED                                          AS DECEASED,
    PER.DECEASED_DATE                                     AS DECEASED_DATE,

    -- ── Gender ──────────────────────────────────────────────────────
    -- SSIS uses PA_PERSON.PAPER_SEX_DR for gender
    SEX.DESC                                              AS GENDER,
    SEX_BIRTH.DESC                                        AS GENDER_AT_BIRTH,
    GI.DESC                                               AS GENDER_IDENTITY,
    SEX_INTERP.DESC                                       AS PREFERRED_INTERPRETER_GENDER,

    -- ── ATSI / indigenous status ────────────────────────────────────
    INDST.DESCRIPTION                                     AS INDIG_STATUS,
    CASE
        WHEN PAT.INDIGENOUS_STATUS_DR IN (4, 5, 6)
            THEN 'ATSI'
        ELSE 'Non-ATSI'
    END                                                   AS ATSI,

    -- ── Cultural background ──────────────────────────────────────────
    NAT.DESC                                              AS CULTURAL_BACKGROUND,
    COB.DESC                                              AS COUNTRY_OF_BIRTH,
    REL.DESC                                              AS RELIGION,
    MAR.DESC                                              AS MARITAL_STATUS,
    DEP.DESCRIPTION                                       AS DEPENDENT_CHILDREN,

    -- ── Language ────────────────────────────────────────────────────
    LANG.DESCRIPTION                                      AS PREF_LANG,
    PER.INTERPRETER_REQUIRED                              AS INTERPRETER_REQUIRED,

    -- ── Refugee status ──────────────────────────────────────────────
    PAT.CHC_PATIENT                                       AS REFUGEE_STATUS,
    PER.FREE_TEXT_5                                       AS REFUGEE_YEAR_OF_ARRIVAL,

    -- ── Contact details ─────────────────────────────────────────────
    PAT.MOBILE_PHONE                                      AS MOB,
    PAT.HOME_PHONE                                        AS TEL_H,
    PER.WORK_PHONE                                        AS TEL_O,

    -- Can leave message logic
    CASE
        WHEN PER.CAN_LEAVE_MESSAGES_ON ILIKE '%C%'
            THEN 'Y'
        WHEN LENGTH(PAT.HOME_PHONE) >= 10
            AND PER.CAN_LEAVE_MESSAGES_ON ILIKE '%M%'
            THEN 'Y'
        WHEN LENGTH(PER.WORK_PHONE) >= 10
            AND PER.CAN_LEAVE_MESSAGES_ON ILIKE '%B%'
            THEN 'Y'
        ELSE 'N'
    END                                                   AS MOB_CAN_LEAVE_MESSAGE,

    CASE
        WHEN PER.CAN_LEAVE_MESSAGES_ON ILIKE '%C%'
            THEN PAT.MOBILE_PHONE
        WHEN LENGTH(PAT.HOME_PHONE) >= 10
            AND PER.CAN_LEAVE_MESSAGES_ON ILIKE '%M%'
            THEN PAT.HOME_PHONE
        WHEN LENGTH(PER.WORK_PHONE) >= 10
            AND PER.CAN_LEAVE_MESSAGES_ON ILIKE '%B%'
            THEN PER.WORK_PHONE
        ELSE NULL
    END                                                   AS MOB_TO_LEAVE_MESSAGE_ON,

    PER.APPOINTMENT_SMS                                   AS SMS,
    PAT.EMAIL                                             AS EMAIL,
    PER.PREF_CONTACT_METHOD                               AS PREFERRED_CONTACT_METHOD,

    -- ── Address ─────────────────────────────────────────────────────
    PER.STREET_NAME                                       AS ADDRESS,
    PER.ADDRESS_2                                         AS ADDRESS_LINE_2,
    ZIP.CITY                                              AS SUBURB,
    PER.ZIP_DR                                            AS SUBURB_REF,
    ZIP.POSTCODE                                          AS POSTCODE,
    RGN.DESCRIPTION                                       AS LGA,

    -- ── Social circumstances ────────────────────────────────────────
    SS.DESCRIPTION                                        AS HOMELESS,
    ACCOM.DESC                                            AS ACCOM,
    LIVARR.DESCRIPTION                                    AS LIVING_ARRANGEMENT,
    CARER.DESCRIPTION                                     AS CARER_STATUS,
    COMM.DESCRIPTION                                      AS COMMUNICATION_NEEDS,

    -- ── Employment and financial ─────────────────────────────────────
    EMP.DESCRIPTION                                       AS EMP_STATUS,
    OCC.DESC                                              AS OCC,
    PER.FREE_TEXT_4                                       AS OCCUPATION,
    INC.DESC                                              AS HEALTH_CARE_CARD,
    PENS.DESCRIPTION                                      AS PENSION_TYPE,
    PER.GOVERN_CARD_NO                                    AS PENSION_NO,
    PAT.DVA_NO                                            AS DVA_NUMBER,
    PAT.CARD_TYPE_DR                                      AS PAPMI_CARDTYPE_DR,
    CARD.DESCRIPTION                                      AS CARD_DESC,
    CONC.DESCRIPTION                                      AS CONCCARD_DESC,
    PAT.CONCESSION_CARD_NO                                AS CONCESSION_CARD_NO,
    --PAT.GOVERN_CARD_NO                                    AS GOVERN_CARD_NO,
    --PAT.CHRONIC_COMPLEX_CLIENT                            AS CHRONIC_COMPLEX_CLIENT,

    -- ── Medicare ────────────────────────────────────────────────────
    PAT.MEDICARE_NO                                       AS MEDICARE_NO,
    PAT.MEDICARE_IRN                                      AS MEDICARE_NO_1,
    PAT.MEDICARE_EXPIRY_DATE                              AS MEDICARE_EXP_DATE,

    -- ── Government identifiers ──────────────────────────────────────
    SLK.MR_NO                                             AS SLK,
    MAC.MR_NO                                             AS MAC_NO,
    NDIS.MR_NO                                            AS NDIS_NUMBER,

    -- ── GP / referring doctor ────────────────────────────────────────
    GP.ROWID                                              AS DOCTOR_REF,
    GP.CODE                                               AS CLINIC_CODE,
    GP.PHONE                                              AS GP_PHONE,
    GP.EMAIL                                              AS GP_EMAIL,

    -- ── Remarks ─────────────────────────────────────────────────────
    -- SSIS uses PA_PERSON.PAPER_REMARK for PMI
    PER.REMARK                                            AS PMI,

    -- ── Additional good fields not in SSIS ──────────────────────────
    PAT.ALLERGY                                           AS ALLERGY,
    PAT.VIP_FLAG                                          AS VIP_FLAG,
    PAT.BLACKLIST                                         AS BLACKLIST,
    --PAT.FEEDBACK_CONSENT                                  AS FEEDBACK_CONSENT,
    PAT.CONCESSION_CARD_EXPIRY_DATE                       AS CONCESSION_CARD_EXPIRY

FROM {{ ref('prep_stg_trakcare_pa_person') }}             AS PER

LEFT JOIN {{ ref('prep_stg_trakcare_pa_patmas') }}        AS PAT
    ON PAT.PATIENT_ID = CAST(PER.PERSON_ID AS NUMBER(18,0))

LEFT JOIN slk
    ON CAST(slk.PAT_NO_DR AS NUMBER(18,0)) = PAT.PATIENT_ID
    AND slk.RN = 1

LEFT JOIN mac
    ON CAST(mac.PAT_NO_DR AS NUMBER(18,0)) = PAT.PATIENT_ID
    AND mac.RN = 1

LEFT JOIN ndis
    ON CAST(ndis.PAT_NO_DR AS NUMBER(18,0)) = PAT.PATIENT_ID
    AND ndis.RN = 1

-- Title from PA_PERSON.PAPER_TITLE_DR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_title') }}         AS TTL
    ON CAST(PER.TITLE_DR AS NUMBER(18,0)) = CAST(TTL.ROW_ID AS NUMBER(18,0))

-- Gender from PA_PERSON.PAPER_SEX_DR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX
    ON CAST(PER.SEX_DR AS NUMBER(18,0)) = CAST(SEX.ROW_ID AS NUMBER(18,0))

-- Gender at birth from PA_PERSON.PAPER_BIRTHGENDER_DR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX_BIRTH
    ON CAST(PER.BIRTH_GENDER_DR AS NUMBER(18,0)) = CAST(SEX_BIRTH.ROW_ID AS NUMBER(18,0))

-- Gender identity
LEFT JOIN {{ ref('prep_stg_trakcare_ct_gender_identity') }} AS GI
    ON CAST(PER.GENDER_IDENTITY_DR AS NUMBER(18,0)) = CAST(GI.ROW_ID AS NUMBER(18,0))

-- Preferred interpreter gender
LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX_INTERP
    ON CAST(PER.PREF_GENDER_INTERPRETER_DR AS NUMBER(18,0)) = CAST(SEX_INTERP.ROW_ID AS NUMBER(18,0))

-- Indigenous status from PA_PATMAS per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_indig_status') }}  AS INDST
    ON PAT.INDIGENOUS_STATUS_DR = CAST(INDST.ROW_ID AS NUMBER(18,0))

-- Preferred language from PA_PATMAS per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_preferred_language') }} AS LANG
    ON PAT.PREF_LANGUAGE_DR = CAST(LANG.ROW_ID AS NUMBER(18,0))

-- Cultural background from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_nation') }}        AS NAT
    ON CAST(PER.NATION_DR AS NUMBER(18,0)) = CAST(NAT.ROW_ID AS NUMBER(18,0))

-- Country of birth from PA_PATMAS per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_country') }}       AS COB
    ON PAT.BIRTH_COUNTRY_DR = CAST(COB.ROW_ID AS NUMBER(18,0))

-- Religion from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_religion') }}      AS REL
    ON CAST(PER.RELIGION_DR AS NUMBER(18,0)) = CAST(REL.ROW_ID AS NUMBER(18,0))

-- Marital status from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_marital') }}       AS MAR
    ON CAST(PER.MARITAL_DR AS NUMBER(18,0)) = CAST(MAR.ROW_ID AS NUMBER(18,0))

-- Dependent children from PA_PERSON.PAPER_DEPENDCHILDREN_DR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_dependentchildren') }} AS DEP
    ON CAST(PER.DEPEND_CHILDREN_DR AS NUMBER(18,0)) = CAST(DEP.ROW_ID AS NUMBER(18,0))

-- ZIP / suburb / postcode from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_zip') }}           AS ZIP
    ON CAST(PER.ZIP_DR AS NUMBER(18,0)) = CAST(ZIP.ROW_ID AS NUMBER(18,0))

-- LGA from CT_REGION via CT_ZIP.CTZIP_REGION_DR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_region') }}        AS RGN
    ON CAST(PER.REGION_DR AS NUMBER(18,0)) = CAST(RGN.ROW_ID AS NUMBER(18,0))

-- Social status / homeless from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_socialstatus') }}  AS SS
    ON CAST(PER.ACCOM_SETTING_DR AS NUMBER(18,0)) = CAST(SS.ROW_ID AS NUMBER(18,0))

-- Accommodation setting from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_accom_setting') }} AS ACCOM
    ON CAST(PER.ACCOM_SETTING_DR AS NUMBER(18,0)) = CAST(ACCOM.ROW_ID AS NUMBER(18,0))

-- Living arrangement from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_living_arrangement') }} AS LIVARR
    ON CAST(PER.LIVING_ARRANGEMENT_DR AS NUMBER(18,0)) = CAST(LIVARR.ROW_ID AS NUMBER(18,0))

-- Carer availability from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_careravailability') }} AS CARER
    ON CAST(PER.CARER_AVAILABILITY_DR AS NUMBER(18,0)) = CAST(CARER.ROW_ID AS NUMBER(18,0))

-- Communication needs from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_communication_needs') }} AS COMM
    ON CAST(PER.COMMUNICATION_NEEDS_DR AS NUMBER(18,0)) = CAST(COMM.ROW_ID AS NUMBER(18,0))

-- Employment status from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_employment_status') }} AS EMP
    ON CAST(PER.EMPLOYMENT_STATUS_DR AS NUMBER(18,0)) = CAST(EMP.ROW_ID AS NUMBER(18,0))

-- Occupation from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_occupation') }}    AS OCC
    ON CAST(PER.OCCUPATION_DR AS NUMBER(18,0)) = CAST(OCC.ROW_ID AS NUMBER(18,0))

-- Source of income from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_source_of_income') }} AS INC
    ON CAST(PER.SOURCE_OF_INCOME_DR AS NUMBER(18,0)) = CAST(INC.ROW_ID AS NUMBER(18,0))

-- Pension type from PA_PATMAS per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_pensiontype') }}  AS PENS
    ON PAT.PENSION_TYPE_DR = CAST(PENS.ROW_ID AS NUMBER(18,0))

-- Card type from PA_PATMAS per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_cardtype') }}     AS CARD
    ON PAT.CARD_TYPE_DR = CAST(CARD.ROW_ID AS NUMBER(18,0))

-- Concession card type from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_concessioncardtype') }} AS CONC
    ON CAST(PER.CONCESSION_CARD_TYPE_DR AS NUMBER(18,0)) = CAST(CONC.ROW_ID AS NUMBER(18,0))

-- GP / referring doctor clinic from PA_PERSON.PAPER_FAMILYDOCTORCLINIC_DR per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_refdoctorclinic') }} AS GP
    ON CAST(PER.FAMILY_DOCTOR_CLINIC_DR AS VARCHAR) = CAST(GP.ROWID AS VARCHAR)

WHERE PAT.PATIENT_NO IS NOT NULL