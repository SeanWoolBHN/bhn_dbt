SELECT
    EP.EPISODE_ID,
    EP.UR,
    CL.DOB,
    CL.AGE,
    CL.GENDER,
    CL.GENDER_AT_BIRTH,
    EP.INDIG,
    CL.ATSI,
    EP.EPISODE_DT,
    EP.GOVT_CAT_CODE,
    EP.GOVT_CAT_DESC,
    EP.PROGRAM_STREAM_CODE,
    EP.PROGRAM_STREAM_DESC                                AS PROGRAM_STREAM,

    -- Parent stream
    CASE
        WHEN EP.PROGRAM_STREAM_CODE IN ('AODTSCRC5', 'AD50-100')
            THEN 'Care and Recovery Coordination - 34300'
        WHEN EP.PROGRAM_STREAM_CODE IN ('AODTSNRW5', 'AD11-100', 'AD11-116')
            THEN 'Non-Residential Withdrawal - 34303'
        WHEN EP.PROGRAM_STREAM_DESC ILIKE '%Counselling%'
            THEN 'Counselling - 34301'
        WHEN EP.PROGRAM_STREAM_DESC ILIKE '%Intake%'
            THEN 'Intake - 34306'
        WHEN EP.PROGRAM_STREAM_DESC ILIKE '%Assessment%'
            THEN 'Assessment - 34307'
        WHEN EP.PROGRAM_STREAM_DESC = 'AOD Brief Intervention - Drug Diversion Appointment Line (DDAL)'
            THEN 'Assessment - 34307'
    END                                                   AS PARENT_STREAM,

    -- Stream
    CASE
        WHEN EP.PROGRAM_STREAM_CODE IN ('AODTSCRC5', 'AD50-100')
            THEN 'CRC'
        WHEN EP.PROGRAM_STREAM_CODE IN ('AODTSNRW5', 'AD11-100', 'AD11-116')
            THEN 'NRW'
        WHEN EP.PROGRAM_STREAM_CODE = 'AD20-100'
            THEN 'Counselling'
        WHEN EP.PROGRAM_STREAM_CODE = 'AODTSCOU5'
            THEN 'Counselling'
        WHEN EP.PROGRAM_STREAM_CODE = 'AD80-100'
            THEN 'Intake - General'
        WHEN EP.PROGRAM_STREAM_CODE IN ('AD71-100', 'AD71-102')
            THEN TRIM(REPLACE(EP.PROGRAM_STREAM_DESC, 'AOD', ''))
        WHEN EP.PROGRAM_STREAM_CODE = 'AODACSOA'
            THEN 'Comprehensive Assessment - ACSO'
        WHEN EP.PROGRAM_STREAM_CODE IN (
            'AD21-134', 'AD21-135', 'AD21-136', 'AD21-102',
            'AD52-132', 'AD52-133'
        ) THEN TRIM(
            SUBSTR(
                EP.PROGRAM_STREAM_DESC,
                CHARINDEX('-', EP.PROGRAM_STREAM_DESC) + 2
            )
        )
        ELSE 'Other'
    END                                                   AS STREAM,

    EP.DISCHARGE_DT,
    EP.DAYS_OPEN,
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
    COALESCE(NULLIF(CO.CP, ''), NULLIF(EP.EPISODE_CP, '')) AS CP,
    CO.CONTACT_DATE                                       AS CONTACT_DT,
    CO.ORD_SUB_CAT,
    CO.ORD_ITEM,
    CO.DIRECT_MINUTES / 60                                AS DIRECT,
    CO.INDIRECT_MINUTES / 60                              AS INDIRECT,
    CO.TRAVEL_MINUTES / 60                                AS TRAVEL

FROM {{ ref('prep_model_episode') }}                      AS EP

INNER JOIN {{ ref('prep_model_client') }}          AS CL
    ON CL.UR = EP.UR

-- Filter to VADC program streams via funding category mapping
INNER JOIN {{ ref('prep_ref_funding_category_national_code_mapping') }} AS NC
    ON NC.DEPARTMENT_CODE = EP.PROGRAM_STREAM_CODE
    AND NC.GOVERNMENT_SUBCATEGORY_DESC = 'Victorian Alcohol and other Drug collection'

INNER JOIN {{ ref('prep_model_contact') }}                AS CO
    ON CO.EPISODE_ID = EP.EPISODE_ID

WHERE EP.SERVICE = 'Alcohol & Drug'
  AND (
      YEAR(EP.DISCHARGE_DT) >= CASE
          WHEN MONTH(CURRENT_DATE()) <= 6
              THEN YEAR(CURRENT_DATE()) - 2
          ELSE YEAR(CURRENT_DATE()) - 1
      END
      OR EP.DISCHARGE_DT IS NULL
  )