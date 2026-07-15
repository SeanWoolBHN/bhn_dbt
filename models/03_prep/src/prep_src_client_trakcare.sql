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
    PAT.PATIENT_NO                                        AS UR,
    PAT.PATIENT_ID                                        AS PAPMI_ROW_ID,
    PER.PERSON_ID                                         AS PAPER_ROW_ID,

    -- ── Government identifiers from RT_MASTER ───────────────────────
    SLK.MR_NO                                             AS SLK,
    MAC.MR_NO                                             AS MAC_NUMBER,
    NDIS.MR_NO                                            AS NDIS_NUMBER,

    -- ── Medicare ────────────────────────────────────────────────────
    PAT.MEDICARE_NO                                       AS MEDICARE_NUMBER,
    PAT.MEDICARE_IRN                                      AS MEDICARE_IRN,
    PAT.MEDICARE_EXPIRY_DATE                              AS MEDICARE_EXPIRY_DATE,

    -- ── DVA ─────────────────────────────────────────────────────────
    PAT.DVA_NO                                            AS DVA_NUMBER,

    -- ── Concession card ─────────────────────────────────────────────
    PAT.CONCESSION_CARD_NO                                AS CONCESSION_CARD_NUMBER,
    PAT.CONCESSION_CARD_EXPIRY_DATE                       AS CONCESSION_CARD_EXPIRY,

    -- ── Name ────────────────────────────────────────────────────────
    PAT.LAST_NAME                                         AS SURNAME,
    PAT.FIRST_NAME                                        AS FIRSTNAME,
    PAT.MIDDLE_NAME                                       AS OTHER_NAME,
    PAT.ALIAS                                             AS PREFERRED_NAME,
    TTL.DESC                                              AS TITLE,

    -- ── Date of birth and deceased ──────────────────────────────────
    PAT.DOB                                               AS DOB,
    PAT.DECEASED                                          AS DECEASED,
    PAT.DECEASED_DATE                                     AS DECEASED_DATE,

    -- ── Gender / sex ────────────────────────────────────────────────
    SEX.DESC                                              AS GENDER,
    SEX.CODE                                              AS GENDER_CODE,
    SEX_BIRTH.DESC                                        AS GENDER_AT_BIRTH,
    GI.DESC                                               AS GENDER_IDENTITY,

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
    LANG.DESCRIPTION                                      AS PREF_LANGUAGE,
    PER.INTERPRETER_REQUIRED                              AS INTERPRETER_REQUIRED,

    -- ── Refugee status ──────────────────────────────────────────────
    PAT.CHC_PATIENT                                       AS REFUGEE_STATUS,

    -- ── Contact details ─────────────────────────────────────────────
    PAT.EMAIL                                             AS EMAIL,
    PAT.MOBILE_PHONE                                      AS MOBILE_PHONE,
    PAT.HOME_PHONE                                        AS HOME_PHONE,
    PER.WORK_PHONE                                        AS WORK_PHONE,

    -- ── Address ─────────────────────────────────────────────────────
    PER.STREET_NAME                                       AS ADDRESS,
    PER.ADDRESS_2                                         AS ADDRESS_LINE_2,
    ZIP.CITY                                              AS SUBURB,
    PER.POSTCODE                                          AS POSTCODE,
    RGN.DESCRIPTION                                       AS LGA,

    -- ── Social circumstances ────────────────────────────────────────
    SS.DESCRIPTION                                        AS HOMELESS,
    ACCOM.DESC                                            AS ACCOMMODATION,
    LIVARR.DESCRIPTION                                    AS LIVING_ARRANGEMENT,
    CARER.DESCRIPTION                                     AS CARER_STATUS,
    COMM.DESCRIPTION                                      AS COMMUNICATION_NEEDS,

    -- ── Employment and financial ─────────────────────────────────────
    EMP.DESCRIPTION                                       AS EMPLOYMENT_STATUS,
    OCC.DESC                                              AS OCCUPATION,
    INC.DESC                                              AS HEALTH_CARE_CARD,
    PENS.DESCRIPTION                                      AS PENSION_TYPE,
    CARD.DESCRIPTION                                      AS CARD_TYPE,

    -- ── GP / referring doctor ────────────────────────────────────────
    GP.CODE                                               AS GP_CLINIC_CODE,
    GP.PHONE                                              AS GP_PHONE,
    GP.EMAIL                                              AS GP_EMAIL,

    -- ── Remarks and flags ───────────────────────────────────────────
    PAT.REMARK                                            AS PMI_NOTES,
    PAT.ALLERGY                                           AS ALLERGY,
    PAT.VIP_FLAG                                          AS VIP_FLAG,
    PAT.BLACKLIST                                         AS BLACKLIST

FROM {{ ref('prep_stg_trakcare_pa_patmas') }}             AS PAT

INNER JOIN {{ ref('prep_stg_trakcare_pa_person') }}       AS PER
    ON PAT.PERSON_DR = CAST(PER.PERSON_ID AS NUMBER(18,0))

LEFT JOIN slk
    ON CAST(slk.PAT_NO_DR AS NUMBER(18,0)) = PAT.PATIENT_ID
    AND slk.RN = 1

LEFT JOIN mac
    ON CAST(mac.PAT_NO_DR AS NUMBER(18,0)) = PAT.PATIENT_ID
    AND mac.RN = 1

LEFT JOIN ndis
    ON CAST(ndis.PAT_NO_DR AS NUMBER(18,0)) = PAT.PATIENT_ID
    AND ndis.RN = 1

LEFT JOIN {{ ref('prep_stg_trakcare_ct_title') }}         AS TTL
    ON PAT.TITLE_DR = CAST(TTL.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX
    ON PAT.SEX_DR = CAST(SEX.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS SEX_BIRTH
    ON CAST(PER.SEX_DR AS NUMBER(18,0)) = CAST(SEX_BIRTH.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_gender_identity') }} AS GI
    ON CAST(PER.GENDER_IDENTITY_DR AS NUMBER(18,0)) = CAST(GI.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_indig_status') }} AS INDST
    ON PAT.INDIGENOUS_STATUS_DR = CAST(INDST.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_preferred_language') }} AS LANG
    ON PAT.PREF_LANGUAGE_DR = CAST(LANG.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_nation') }}        AS NAT
    ON CAST(PER.NATION_DR AS NUMBER(18,0)) = CAST(NAT.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_country') }}       AS COB
    ON PAT.BIRTH_COUNTRY_DR = CAST(COB.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_religion') }}      AS REL
    ON CAST(PER.RELIGION_DR AS NUMBER(18,0)) = CAST(REL.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_marital') }}       AS MAR
    ON CAST(PER.MARITAL_DR AS NUMBER(18,0)) = CAST(MAR.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_dependentchildren') }} AS DEP
    ON CAST(PER.COMMUNICATION_NEEDS_DR AS NUMBER(18,0)) = CAST(DEP.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_zip') }}           AS ZIP
    ON CAST(PER.ZIP_DR AS NUMBER(18,0)) = CAST(ZIP.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_region') }}        AS RGN
    ON CAST(PER.REGION_DR AS NUMBER(18,0)) = CAST(RGN.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_socialstatus') }}  AS SS
    ON CAST(PER.ACCOM_SETTING_DR AS NUMBER(18,0)) = CAST(SS.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_accom_setting') }} AS ACCOM
    ON CAST(PER.ACCOM_SETTING_DR AS NUMBER(18,0)) = CAST(ACCOM.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_living_arrangement') }} AS LIVARR
    ON CAST(PER.LIVING_ARRANGEMENT_DR AS NUMBER(18,0)) = CAST(LIVARR.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_careravailability') }} AS CARER
    ON CAST(PER.ACCOM_SETTING_DR AS NUMBER(18,0)) = CAST(CARER.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_communication_needs') }} AS COMM
    ON CAST(PER.COMMUNICATION_NEEDS_DR AS NUMBER(18,0)) = CAST(COMM.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_employment_status') }} AS EMP
    ON CAST(PER.EMPLOYMENT_STATUS_DR AS NUMBER(18,0)) = CAST(EMP.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_ct_occupation') }}    AS OCC
    ON CAST(PER.OCCUPATION_DR AS NUMBER(18,0)) = CAST(OCC.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_source_of_income') }} AS INC
    ON CAST(PER.SOURCE_OF_INCOME_DR AS NUMBER(18,0)) = CAST(INC.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_pensiontype') }}  AS PENS
    ON PAT.PENSION_TYPE_DR = CAST(PENS.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_cardtype') }}     AS CARD
    ON PAT.CARD_TYPE_DR = CAST(CARD.ROW_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pac_refdoctorclinic') }} AS GP
    ON CAST(PAT.REF_DOC_DR AS VARCHAR) = CAST(GP.ROWID AS VARCHAR)

WHERE PAT.PATIENT_NO IS NOT NULL