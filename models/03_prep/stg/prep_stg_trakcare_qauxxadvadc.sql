SELECT
    ID                                                                    AS VADC_ID,

    -- Links to other tables
    NULLIF(TRIM(QUESPAADMDR), 'NULL')                                     AS ADM_DR,
    NULLIF(TRIM(QUESPAPATMASDR), 'NULL')                                   AS PATIENT_DR,
    QUESSSUSERDEFWINDOWDR                                                 AS USER_DEF_WINDOW_DR,
    QUESUSERDR                                                            AS USER_DR,
    NULLIF(TRIM(QUESOEORDEXECDR), 'NULL')                                 AS OE_ORD_EXEC_DR,
    NULLIF(TRIM(QUESMRCLINICALPATHWAYSDR), 'NULL')                        AS MR_CLINICAL_PATHWAYS_DR,
    NULLIF(TRIM(QUESSTATUSDR), 'NULL')                                    AS STATUS_DR,
    NULLIF(TRIM(QUESTEXTRESULTDR), 'NULL')                                AS TEXT_RESULT_DR,
    NULLIF(TRIM(QUESCONSULTDR), 'NULL')                                   AS CONSULT_DR,
    NULLIF(TRIM(QUESOPERROOMDR), 'NULL')                                  AS OPER_ROOM_DR,
    NULLIF(TRIM(QUESFHRESIDENTDR), 'NULL')                                AS FH_RESIDENT_DR,
    NULLIF(TRIM(QUESPATHWAYITEMDR), 'NULL')                               AS PATHWAY_ITEM_DR,
    NULLIF(TRIM(QUESPAWAITINGLISTDR), 'NULL')                             AS WAITING_LIST_DR,
    NULLIF(TRIM(QUESCOPIEDEPDR), 'NULL')                                  AS COPIED_EP_DR,
    NULLIF(TRIM(QUESCOPIEDUSERDR), 'NULL')                                AS COPIED_USER_DR,
    NULLIF(TRIM(QUESREASONFORCORRECTIONDR), 'NULL')                       AS REASON_FOR_CORRECTION_DR,
    NULLIF(TRIM(QUESERRORREASONDR), 'NULL')                               AS ERROR_REASON_DR,
    NULLIF(TRIM(QUESNRCAREPLANISSUESDR), 'NULL')                          AS NR_CARE_PLAN_ISSUES_DR,
    NULLIF(TRIM(QUESRBAPPOINTMENTDR), 'NULL')                             AS RB_APPOINTMENT_DR,
    NULLIF(TRIM(QUESANADR), 'NULL')                                       AS ANA_DR,
    NULLIF(TRIM(QUESANAOPERATIONDR), 'NULL')                              AS ANA_OPERATION_DR,
    NULLIF(TRIM(QUESCOPIEDSOURCEDR), 'NULL')                              AS COPIED_SOURCE_DR,
    NULLIF(TRIM(QUESTRANSACTIONDR), 'NULL')                               AS TRANSACTION_DR,
    NULLIF(TRIM(QUESOBSENTRYDR), 'NULL')                                  AS OBS_ENTRY_DR,
    NULLIF(TRIM(QUESPAPREGNANCYDR), 'NULL')                               AS PREGNANCY_DR,
    NULLIF(TRIM(QUESPREPOSTEXAMOEORDITEMDR), 'NULL')                      AS PRE_POST_EXAM_OE_ORD_ITEM_DR,
    NULLIF(TRIM(QUESORPREANAESTHETICCONSULTDR), 'NULL')                   AS OR_PRE_ANAESTHETIC_CONSULT_DR,
    NULLIF(TRIM(QUESRBAPPTOUTCOMEDR), 'NULL')                             AS RB_APPT_OUTCOME_DR,
    NULLIF(TRIM(QUESRBAPPTSLOTDR), 'NULL')                                AS RB_APPT_SLOT_DR,
    NULLIF(TRIM(QUESSECONDUSERDR), 'NULL')                                AS SECOND_USER_DR,
    NULLIF(TRIM(QUESPAADVERSEEVENTDR), 'NULL')                            AS ADVERSE_EVENT_DR,

    -- Date/time columns
    QUESDATE                                                              AS QUES_DATE,
    QUESTIME                                                              AS QUES_TIME,
    QUESCREATEDATE                                                        AS CREATED_DATE,
    QUESCREATETIME                                                        AS CREATED_TIME,
    QUESCREATEUSERDR                                                      AS CREATED_USER_DR,

    -- Score
    QUESSCORE                                                             AS SCORE,

    -- VADC-specific fields
    NULLIF(TRIM(QVADCOUTCODE), 'NULL')                                    AS VADC_OUT_CODE,
    NULLIF(TRIM(QVADCABI), 'NULL')                                        AS VADC_ABI,
    NULLIF(TRIM(QVADCLGB), 'NULL')                                        AS VADC_LGB,
    NULLIF(TRIM(QVADCMALTRT), 'NULL')                                     AS VADC_MAL_TRT,
    NULLIF(TRIM(QVADCMALPERP), 'NULL')                                    AS VADC_MAL_PERP,
    NULLIF(TRIM(QVADCMHDIAG), 'NULL')                                     AS VADC_MH_DIAG,
    NULLIF(TRIM(QVADCBIRTHSEX), 'NULL')                                   AS VADC_BIRTH_SEX,
    NULLIF(TRIM(QVADCGENDREAS), 'NULL')                                   AS VADC_GENDER_REAS,
    NULLIF(TRIM(QVADCFORTYP), 'NULL')                                     AS VADC_FOR_TYP,
    NULLIF(TRIM(QVADCMASCOT), 'NULL')                                     AS VADC_MASCOT,
    NULLIF(TRIM(QVADCPRESDRUGOC), 'NULL')                                 AS VADC_PRES_DRUG_OC,
    NULLIF(TRIM(QVADCDELSET), 'NULL')                                     AS VADC_DEL_SET,
    NULLIF(TRIM(QVADCSIGGOAL), 'NULL')                                    AS VADC_SIG_GOAL,
    NULLIF(TRIM(QVADCTIER), 'NULL')                                       AS VADC_TIER,
    NULLIF(TRIM(QVADCCRSLEN), 'NULL')                                     AS VADC_CRS_LEN,
    NULLIF(TRIM(QVADCFIRSTREG), 'NULL')                                   AS VADC_FIRST_REG,
    NULLIF(TRIM(QVADCPERCOMP), 'NULL')                                    AS VADC_PER_COMP,
    NULLIF(TRIM(QVADCASSESSCOMP), 'NULL')                                 AS VADC_ASSESS_COMP,
    NULLIF(TRIM(QVADCTARGPOP), 'NULL')                                    AS VADC_TARG_POP,
    NULLIF(TRIM(QVADCMARAM), 'NULL')                                      AS VADC_MARAM,
    NULLIF(TRIM(QVADCFAMVIOLENCE), 'NULL')                                AS VADC_FAM_VIOLENCE,
    NULLIF(TRIM(QVADCMALPERP1), 'NULL')                                   AS VADC_MAL_PERP_1,
    NULLIF(TRIM(QVADCMHDIAG1), 'NULL')                                    AS VADC_MH_DIAG_1,

    -- Copied/correction audit trail
    NULLIF(TRIM(QUESCOPIEDDATE), 'NULL')                                  AS COPIED_DATE,
    NULLIF(TRIM(QUESCOPIEDTIME), 'NULL')                                  AS COPIED_TIME,
    NULLIF(TRIM(QUESCOPIEDCOMMENTS), 'NULL')                              AS COPIED_COMMENTS

FROM {{ ref('HIST_TRAKCARE_QAUXXADVADC') }}
WHERE dbt_valid_to = TO_DATE('9999-12-31')