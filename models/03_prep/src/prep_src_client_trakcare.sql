WITH slk AS (
    SELECT
        RT.PAT_NO_DR,
        RT.MR_NO,
        ROW_NUMBER() OVER (
            PARTITION BY RT.PAT_NO_DR
            ORDER BY RT.ROW_ID DESC
        )                                                 AS RN
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
        )                                                 AS RN
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
        )                                                 AS RN
    FROM {{ ref('prep_stg_trakcare_rt_master') }}         AS RT
    INNER JOIN {{ ref('prep_stg_trakcare_rtc_mrecordtype') }} AS TYP
        ON CAST(RT.MR_TYPE_DR AS NUMBER(18,0)) = CAST(TYP.ROW_ID AS NUMBER(18,0))
    WHERE TYP.CODE = 'NDIS'
)

SELECT
    -- ── Source system keys — kept for client matching ────────────────
    'TRAKCARE'                                            AS SRC_SYS,
    PAT.PATIENT_NO::VARCHAR                               AS SRC_SYS_CLIENT_ID,
    PAT.FIRST_NAME                                        AS FIRST_NAME,
    UPPER(NULLIF(TRIM(PAT.LAST_NAME), ''))                AS LAST_NAME,
    PAT.DOB                                               AS DOB,
    PER.STREET_NAME                                       AS ADDRESS,

        -- ── Suburb — CASE override per SSIS for specific ZIP_DR values ──
    CASE
        WHEN PER.ZIP_DR IN (116543,116546,116547,116551,116552,116553)
            THEN 'Armadale North'
        WHEN PER.ZIP_DR IN (116685,116687)
            THEN 'Bentleigh East'
        WHEN PER.ZIP_DR IN (116923,116926,116928,116930,116934)
            THEN 'Black Rock North'
        WHEN PER.ZIP_DR IN (116877,116880)
            THEN 'Brighton'
        WHEN PER.ZIP_DR IN (116887,116888,116889)
            THEN 'Brighton East'
        WHEN PER.ZIP_DR IN (116874,116875,116876,116878,116879,116882)
            THEN 'Brighton North'
        WHEN PER.ZIP_DR IN (116961)
            THEN 'Carrum'
        WHEN PER.ZIP_DR IN (116564,116570,116571)
            THEN 'Caulfield East'
        WHEN PER.ZIP_DR IN (116664,116665,116666,116667,116668,116670)
            THEN 'Caulfield North'
        WHEN PER.ZIP_DR IN (116672,116673,116674,116675,116676,116678)
            THEN 'Caulfield South'
        WHEN PER.ZIP_DR IN (116912,116915,116916,116919,116920,116922)
            THEN 'Cheltenham'
        WHEN PER.ZIP_DR IN (116917,116918)
            THEN 'Cheltenham East'
        WHEN PER.ZIP_DR IN (116708,116709,116710,116711,116712,116713,116714,116715)
            THEN 'Clayton'
        WHEN PER.ZIP_DR IN (116716,116718,116719,116720,116721,116723)
            THEN 'Clayton South'
        WHEN PER.ZIP_DR IN (116542,116544,116545,116548,116549,116554,116565,116566,
                             116567,116568,116572,116573)
            THEN 'Darling South'
        WHEN PER.ZIP_DR IN (116976,116977,116978,116979,116987)
            THEN 'Frankston'
        WHEN PER.ZIP_DR IN (116985,116986)
            THEN 'Frankston East'
        WHEN PER.ZIP_DR IN (116989,116990,116992,116993,116994,116995)
            THEN 'Frankston North'
        WHEN PER.ZIP_DR IN (116972,116973,116974,116975,116980)
            THEN 'Frankston South'
        WHEN PER.ZIP_DR IN (116867,116868,116869)
            THEN 'Gardenvale'
        WHEN PER.ZIP_DR IN (116897,116899,116900)
            THEN 'Hampton East'
        WHEN PER.ZIP_DR IN (116893,116894,116895,116896,116902)
            THEN 'Hampton North'
        WHEN PER.ZIP_DR IN (116563,116569,116576,116593,116594,116595)
            THEN 'Malvern East'
        WHEN PER.ZIP_DR IN (116555,116556,116557,116558,116559,116562)
            THEN 'Malvern North'
        WHEN PER.ZIP_DR IN (115499,115500,115501,115502,115503,115504,115505,115506,
                             115507,115508,115509,115510,115511,115512,115513)
            THEN 'Melbourne'
        WHEN PER.ZIP_DR IN (116936,116940)
            THEN 'Mentone East'
        WHEN PER.ZIP_DR IN (116904,116905)
            THEN 'Moorabbin East'
        WHEN PER.ZIP_DR IN (116945,116946,116947,116949,116954,116955)
            THEN 'Mordialloc'
        WHEN PER.ZIP_DR IN (116883,116885,116886,116890,116891)
            THEN 'North Road'
        WHEN PER.ZIP_DR IN (116691,116692)
            THEN 'Oakleigh East'
        WHEN PER.ZIP_DR IN (116697,116698,116699,116700,116701)
            THEN 'Oakleigh South'
        WHEN PER.ZIP_DR IN (117002,117004,117005)
            THEN 'Ormond'
        WHEN PER.ZIP_DR IN (117017,117022)
            THEN 'Port Melbourne'
        WHEN PER.ZIP_DR IN (116803,116804,116806)
            THEN 'Prahran East'
        WHEN PER.ZIP_DR IN (116963,116964,116965,116966,116967,116970)
            THEN 'Seaford'
        WHEN PER.ZIP_DR IN (117006,117007,117008,117009,117010,117011,117012,117013)
            THEN 'South Melbourne'
        WHEN PER.ZIP_DR IN (116526,116527,116528,116529,116530,116531,116532,116533,
                             116534,116535,116536,116537,116538)
            THEN 'South Yarra'
        WHEN PER.ZIP_DR IN (116808,116827,116830,116835,116836,116840,116845,116846)
            THEN 'St Kilda'
        WHEN PER.ZIP_DR IN (116851,116852,116853,116854,116855,116856,116857,116858,
                             116859,116860,116861,116863)
            THEN 'St Kilda East'
        WHEN PER.ZIP_DR IN (116807,116810,116811,116813,116814,116815,116816,116817,
                             116818,116828,116829,116831,116833,116834,116837,116838,
                             116841,116842,116843,116844,116847,116848,116849,116850)
            THEN 'St Kilda South'
        WHEN PER.ZIP_DR IN (116809,116812,116819,116820,116821,116822,116823,116824,
                             116825,116826,116832,116839)
            THEN 'St Kilda West'
        ELSE ZIP.CITY
    END                                                   AS CITY,

    ZIP.POSTCODE                                          AS POSTCODE,

    PAT.EMAIL                                             AS EMAIL,

    PAT.MOBILE_PHONE                                      AS MOBILE_PHONE,

    -- ── Identity ────────────────────────────────────────────────────
    PAT.PATIENT_NO::VARCHAR                               AS UR,
    PER.PERSON_ID                                         AS PAPER_ROW_ID,
    CAST(PER.PATIENT_DR AS VARCHAR)                       AS PAPER_PAPMI_DR,
    PAT.PATIENT_ID                                        AS PAPMI_ROW_ID,

    -- ── Name ────────────────────────────────────────────────────────
    PER.MIDDLE_NAME                                       AS OTHER_NAME,
    TTL.DESC                                              AS TITLE,
    PER.NAME_4                                            AS PREFERRED_NAME,

    -- ── Date of birth ───────────────────────────────────────────────
    PER.EST_DOB                                           AS EST_DOB,
    PER.AGE_YR                                            AS AGE,
    PER.DECEASED                                          AS DECEASED,
    PER.DECEASED_DATE                                     AS DECEASED_DATE,

    -- ── Gender ──────────────────────────────────────────────────────
    SEX.DESC                                              AS GENDER,
    SEX_BIRTH.DESC                                        AS GENDER_AT_BIRTH,
    GI.DESC                                               AS GENDER_IDENTITY,
    SEX_INTERP.DESC                                       AS PREFERRED_INTERPRETER_GENDER,

    -- ── ATSI ────────────────────────────────────────────────────────
    INDST.DESCRIPTION                                     AS INDIG_STATUS,
    CASE
        WHEN PAT.INDIGENOUS_STATUS_DR IN (4, 5, 6)
            THEN 'ATSI'
        ELSE 'Non-ATSI'
    END                                                   AS ATSI,

    -- ── Cultural background ──────────────────────────────────────────
    NAT.DESC                                             AS CULTURAL_BACKGROUND,
    COB.DESC                                             AS COUNTRY_OF_BIRTH,
    REL.DESC                                             AS RELIGION,
    MAR.DESC                                             AS MARITAL_STATUS,
    DEP.DESCRIPTION                                      AS DEPENDENT_CHILDREN,

    -- ── Language ────────────────────────────────────────────────────
    LANG.DESCRIPTION                                      AS PREF_LANG,
    PER.INTERPRETER_REQUIRED                              AS INTERPRETER_REQUIRED,
    SEX_INTERP.DESC                                       AS PREFERRED_INTERPRETER_GENDER_DESC,

    -- ── Refugee ─────────────────────────────────────────────────────
    PAT.CHC_PATIENT                                       AS REFUGEE_STATUS,
    PER.FREE_TEXT_5                                       AS REFUGEE_YEAR_OF_ARRIVAL,

    -- ── Contact ─────────────────────────────────────────────────────
    PAT.HOME_PHONE                                        AS TEL_H,
    PER.WORK_PHONE                                        AS TEL_O,
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
    PER.PREF_CONTACT_METHOD                               AS PREFERRED_CONTACT_METHOD,

    -- ── Address ─────────────────────────────────────────────────────
    PER.FOREIGN_ADDRESS                                   AS ADDRESS_LINE_2,


    PER.ZIP_DR                                            AS SUBURB_REF,
    RGN.DESCRIPTION                                       AS LGA,

    -- ── Social circumstances ────────────────────────────────────────
    -- HOMELESS — SOCIAL_STATUS_DR per SSIS (fixed from ACCOM_SETTING_DR)
    SS.DESCRIPTION                                        AS HOMELESS,
    ACCOM.DESC                                     AS ACCOM,
    LIVARR.DESCRIPTION                                    AS LIVING_ARRANGEMENT,
    CARER.DESCRIPTION                                     AS CARER_STATUS,
    COMM.DESCRIPTION                                      AS COMMUNICATION_NEEDS,

    -- ── Employment and financial ─────────────────────────────────────
    EMP.DESCRIPTION                                       AS EMP_STATUS,
    OCC.DESC                                       AS OCC,
    PER.FREE_TEXT_4                                       AS OCCUPATION,
    INC.DESC                                              AS HEALTH_CARE_CARD,
    PENS.DESCRIPTION                                      AS PENSION_TYPE,
    PER.GOVERN_CARD_NO                                    AS PENSION_NO,
    PAT.DVA_NO                                            AS DVA_NUMBER,
    PAT.CARD_TYPE_DR                                      AS PAPMI_CARDTYPE_DR,
    CARD.DESCRIPTION                                      AS CARD_DESC,
    CONC.DESCRIPTION                                      AS CONCCARD_DESC,
    --PAT.CONCESSION_CARD_NO                                AS CONCESSION_CARD_NO,
    --PAT.GOVERN_CARD_NO                                    AS GOVERN_CARD_NO,

    -- ── Medicare ────────────────────────────────────────────────────
    PAT.MEDICARE_NO                                       AS MEDICARE_NO,
    PAT.MEDICARE_IRN                                      AS MEDICARE_NO_1,
    PAT.MEDICARE_EXPIRY_DATE                              AS MEDICARE_EXP_DATE,

    -- ── Other financial ─────────────────────────────────────────────
    PAT.CHC_PATIENT                                       AS CHRONIC_COMPLEX_CLIENT,

    -- ── Government identifiers ──────────────────────────────────────
    SLK.MR_NO                                             AS SLK,
    MAC.MR_NO                                             AS MAC_NO,
    NDIS.MR_NO                                            AS NDIS_NUMBER,

    -- ── GP / referring doctor ────────────────────────────────────────
    GP.ROWID                                              AS DOCTOR_REF,
    GP.CODE                                               AS CLINIC_CODE,
    GP.PHONE                                              AS GP_PHONE,
    GP.EMAIL                                              AS GP_EMAIL,

    -- ── Remarks / PMI ───────────────────────────────────────────────
    PER.REMARK                                            AS PMI,

    -- ── Additional good fields not in SSIS ──────────────────────────
    PAT.ALLERGY                                           AS ALLERGY,
    PAT.VIP_FLAG                                          AS VIP_FLAG,
    PAT.BLACKLIST                                         AS BLACKLIST

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

-- Title
LEFT JOIN {{ ref('prep_stg_trakcare_ct_title') }}         AS TTL
    ON CAST(PER.TITLE_DR AS NUMBER(18,0)) = CAST(TTL.ROW_ID AS NUMBER(18,0))

-- Gender from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX
    ON CAST(PER.SEX_DR AS NUMBER(18,0)) = CAST(SEX.ROW_ID AS NUMBER(18,0))

-- Gender at birth
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

-- Dependent children from PA_PERSON per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_pac_dependentchildren') }} AS DEP
    ON CAST(PER.DEPEND_CHILDREN_DR AS NUMBER(18,0)) = CAST(DEP.ROW_ID AS NUMBER(18,0))

-- ZIP / suburb / postcode
LEFT JOIN {{ ref('prep_stg_trakcare_ct_zip') }}           AS ZIP
    ON CAST(PER.ZIP_DR AS NUMBER(18,0)) = CAST(ZIP.ROW_ID AS NUMBER(18,0))

-- LGA
LEFT JOIN {{ ref('prep_stg_trakcare_ct_region') }}        AS RGN
    ON CAST(PER.REGION_DR AS NUMBER(18,0)) = CAST(RGN.ROW_ID AS NUMBER(18,0))

-- HOMELESS — SOCIAL_STATUS_DR per SSIS (was incorrectly ACCOM_SETTING_DR)
LEFT JOIN {{ ref('prep_stg_trakcare_ct_socialstatus') }}  AS SS
    ON CAST(PER.SOCIAL_STATUS_DR AS NUMBER(18,0)) = CAST(SS.ROW_ID AS NUMBER(18,0))

-- Accommodation setting
LEFT JOIN {{ ref('prep_stg_trakcare_pac_accom_setting') }} AS ACCOM
    ON CAST(PER.ACCOM_SETTING_DR AS NUMBER(18,0)) = CAST(ACCOM.ROW_ID AS NUMBER(18,0))

-- Living arrangement
LEFT JOIN {{ ref('prep_stg_trakcare_pac_living_arrangement') }} AS LIVARR
    ON CAST(PER.LIVING_ARRANGEMENT_DR AS NUMBER(18,0)) = CAST(LIVARR.ROW_ID AS NUMBER(18,0))

-- Carer availability
LEFT JOIN {{ ref('prep_stg_trakcare_pac_careravailability') }} AS CARER
    ON CAST(PER.CARER_AVAILABILITY_DR AS NUMBER(18,0)) = CAST(CARER.ROW_ID AS NUMBER(18,0))

-- Communication needs
LEFT JOIN {{ ref('prep_stg_trakcare_pac_communication_needs') }} AS COMM
    ON CAST(PER.COMMUNICATION_NEEDS_DR AS NUMBER(18,0)) = CAST(COMM.ROW_ID AS NUMBER(18,0))

-- Employment status
LEFT JOIN {{ ref('prep_stg_trakcare_pac_employment_status') }} AS EMP
    ON CAST(PER.EMPLOYMENT_STATUS_DR AS NUMBER(18,0)) = CAST(EMP.ROW_ID AS NUMBER(18,0))

-- Occupation
LEFT JOIN {{ ref('prep_stg_trakcare_ct_occupation') }}    AS OCC
    ON CAST(PER.OCCUPATION_DR AS NUMBER(18,0)) = CAST(OCC.ROW_ID AS NUMBER(18,0))

-- Source of income
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

-- GP / referring doctor clinic
LEFT JOIN {{ ref('prep_stg_trakcare_pac_refdoctorclinic') }} AS GP
    ON CAST(PER.FAMILY_DOCTOR_CLINIC_DR AS VARCHAR) = CAST(GP.ROWID AS VARCHAR)

WHERE PAT.PATIENT_NO IS NOT NULL