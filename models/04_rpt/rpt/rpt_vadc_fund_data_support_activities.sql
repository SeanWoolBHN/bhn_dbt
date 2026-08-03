-- Drives from rpt_vadc_fund_data joined to contacts filtered to AOD Support Activity
-- Equivalent to SSIS VADCFundata_SupportActivities

SELECT DISTINCT
    VF.EPISODE_ID,
    VF.UR,
    VF.DOB,
    VF.AGE,
    VF.GENDER,
    VF.GENDER_AT_BIRTH,
    VF.INDIG,
    VF.ATSI,
    VF.MEDICARE_NO,
    VF.MEDICARE_NO_1,
    VF.EPISODE_DT,
    VF.DISCHARGE_DT,
    VF.SERVICE,
    VF.EPISODE_CP,
    VF.EPISODE_TEAM,
    VF.REF_TYPE,
    VF.REF_REC_DT,
    VF.REF_CREATE_DT,
    VF.INITIATED_BY,
    VF.REFERRAL_ORG,
    VF.EXT_REQUESTOR_NAME,
    VF.REF_PRIORITY,
    VF.REF_SOURCE,
    VF.INT_REF_TEAM,
    VF.REFERRAL_DESTINATION,
    VF.PRESENTING_COMPLAINT,
    VF.REFERRAL_REASON,
    VF.ASSESSMENT_REVIEW,
    -- Truncate time component to 00:00:00 per SSIS
    CAST(CAST(CO.CONTACT_DATE_TIME AS DATE) AS TIMESTAMP)  AS CONTACT_DATE_TIME,
    VF.PROGRAM_STREAM_CODE,
    VF.MAPPED_PROGRAM_STREAM_CODE,
    VF.PROGRAM_STREAM,
    VF.PARENT_STREAM,
    REPLACE(VF.STREAM, '–', '-')                           AS STREAM,
    REPLACE(VF.DTAU_STREAM, '–', '-')                      AS DTAU_STREAM,
    VF.DOWNGRADE,
    VF.FORENSIC_DESC,
    VF.NO_DTAU_CONTACTS,
    VF.RELATIONSHIP_TO_SELF,
    VF.Q_ROW_ID,
    VF.QVADCMARAM,
    VF.FORENSIC_TYPE,
    VF.QVADCFAM_VIOLENCE,
    VF.TARGET_GROUP,
    VF.END_OF_TREATMENT_REASON,
    VF.PERCENTAGE_COMPLETED,
    VF.SERVICE_EVENT_REF,
    VF.VADC_QUESTIONNAIRE_DATE,
    VF.VADC_QUESTION_CP,
    VF.QVADCFIRSTREG,
    VF.QVADCOUTCODE,
    VF.QVADCASSESS_COMP,
    VF.TREATMENT_LENGTH,
    VF.PROGRAM_TYPE,
    VF.QVADCMALTRT,
    VF.PERPETRATOR,
    VF.OUTCOME_ID,
    VF.OUTC_DATE,
    VF.K10_SCORE,
    VF.NO_REF_INS,
    VF.REF_IN_DATE,
    VF.ACSO,
    VF.FIRST_FR,
    VF.LAST_FR,
    VF.LAST_CONTACT_DT,
    VF.FIRST_CONTACT_DT,
    VF.NUM_PRIMARY_DRUG_OF_CONCERN,
    VF.PRINCIPAL_DOC,
    VF.DOC_DATE,
    VF.DOC_OCCURRENCE,
    VF.DOC_METHOD,
    VF.DOC_QUANTITY,
    VF.DOC_MEASURE,
    VF.TOTAL_HRS,
    CO.DIRECT_MINUTES                                      AS DIRECT,
    CO.INDIRECT_MINUTES                                    AS INDIRECT,
    CO.CONTACT_METHOD,

    -- Validity per SSIS
    CASE
        WHEN VF.Q_ROW_ID IS NULL
            THEN 'VADC Questionnaire must be attached to be valid'
        WHEN CO.DIRECT_MINUTES < 15
          OR CO.INDIRECT_MINUTES IS NOT NULL
            THEN 'Support Activity must be entered in Direct time and greater than or = to 15 min'
        WHEN CO.CONTACT_METHOD != 'Support Activity'
            THEN 'Contact Method must be Support Activity'
        WHEN VF.PROGRAM_STREAM_CODE IN (
            'AODTSCRC5', 'AD50-100', 'AD21-135', 'AD21-136', 'AD21-134',
            'AD21-102', 'AD52-133', 'AD52-132', 'AD52-131', 'AD52-130', 'AD52-116'
        ) THEN 'Support Activity contacts can not be associated with ' || VF.PROGRAM_STREAM
    END                                                    AS ERROR,

    VF.REF_IN,
    VF.REF_OUT,
    VF.PROVIDER_IN_TYPE,
    VF.PROVIDER_OUT_TYPE

FROM {{ ref('rpt_vadc_fund_data') }}                       AS VF

INNER JOIN {{ ref('prep_model_contact') }}                 AS CO
    ON VF.EPISODE_ID = CO.EPISODE_ID
    AND CO.ORD_SUB_CAT = 'AOD Support Activity'
    AND CO.REQUEST_STATUS = 'Completed'

WHERE VF.SERVICE = 'Alcohol & Drug'
  AND (
      YEAR(VF.DISCHARGE_DT) >= CASE
          WHEN MONTH(CURRENT_DATE()) <= 6
              THEN YEAR(CURRENT_DATE()) - 2
          ELSE YEAR(CURRENT_DATE()) - 1
      END
      OR VF.DISCHARGE_DT IS NULL
  )