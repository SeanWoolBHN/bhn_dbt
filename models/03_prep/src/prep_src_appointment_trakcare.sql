WITH booked_by AS (
    SELECT ROW_ID, NAME
    FROM {{ ref('prep_stg_trakcare_ss_user') }}
)

SELECT

    APPT.ROW_ID                                           AS APPOINTMENT_ID,
    PAT.PATIENT_NO                                        AS UR,
    ADM.ADM_NO                                            AS EPISODE_ID,
    APPT.ADM_DR                                           AS EPISODE_DR_RAW,
    APPT.OE_ORI_DR                                        AS OEORDI_REF,

    -- ── Appointment type ────────────────────────────────────────────
    IM.DESCRIPTION                                        AS APPOINTMENT_TYPE,
    SER.DESCRIPTION                                       AS SER_DESC,

    -- ── Status ──────────────────────────────────────────────────────
    APPT.STATUS                                           AS APPOINTMENT_STATUS_REF,
    CASE
        WHEN APPT.STATUS = 'A' THEN 'Arrived'
        WHEN APPT.STATUS = 'S' THEN 'Arrived Not Seen'
        WHEN APPT.STATUS = 'P' THEN 'Booked'
        WHEN APPT.STATUS = 'X' THEN 'Cancelled'
        WHEN APPT.STATUS = 'D' THEN 'Departed'
        WHEN APPT.STATUS = 'N' THEN 'Not Attended'
        WHEN APPT.STATUS = 'T' THEN 'Transferred'
        ELSE APPT.STATUS
    END                                                   AS APPOINTMENT_STATUS,

    -- ── Home visit flag ─────────────────────────────────────────────
    CASE
        WHEN IM.DESCRIPTION ILIKE '%home%'
            THEN 'Home Visit'
        ELSE 'Onsite Appointment'
    END                                                   AS HOME,

    -- ── Appointment dates and times ─────────────────────────────────
    APPT.BOOKED_DATE                                      AS BOOKED_DATE,
    APPT.BOOKED_TIME                                      AS BOOKED_TIME,
    TO_TIMESTAMP(
        APPT.BOOKED_DATE::VARCHAR || ' ' || APPT.BOOKED_TIME::VARCHAR
    )                                                     AS BOOKED_DATE_TIME,
    APPT.COMPLETION_DATE                                  AS APPT_DATE,
    APPT.COMPLETION_TIME                                  AS COMPLETION_TIME,
    TO_TIMESTAMP(
        APPT.COMPLETION_DATE::VARCHAR || ' ' || APPT.COMPLETION_TIME::VARCHAR
    )                                                     AS APPT_DATE_TIME,
    APPT.ARRIVAL_DATE                                     AS ARRIVAL_DATE,
    APPT.ARRIVAL_TIME                                     AS ARRIVAL_TIME,
    TO_TIMESTAMP(
        APPT.COMPLETION_DATE::VARCHAR || ' ' || APPT.ARRIVAL_TIME::VARCHAR
    )                                                     AS ARRIVAL_DATE_TIME,
    APPT.END_DATE                                         AS END_DATE,
    APPT.END_TIME                                         AS END_TIME,
    APPT.DURATION                                         AS DURATION_MINUTES,

    -- ── Care provider / resource / team ─────────────────────────────
    RES.DESCRIPTION                                       AS CARE_PROVIDER_RESOURCE,
    RES.ROW_ID                                            AS CARE_PROVIDER_RESOURCE_ID,
    LOC.DESCRIPTION                                       AS TEAM,
    CP.DESCRIPTION                                        AS CARE_PROVIDER,
    APPT.LOC_DR                                           AS LOCATION_DR_RAW,

    -- ── Consultation category ───────────────────────────────────────
    CASE
        WHEN APPT.CONSULT_CATEG_DR = 54 THEN 'Telephone'
        WHEN APPT.CONSULT_CATEG_DR = 55 THEN 'Telehealth'
        ELSE ''
    END                                                   AS CONSULTATION_CATEGORY,

    -- ── Booked by ───────────────────────────────────────────────────
    BB.NAME                                               AS BOOKED_BY,

    -- ── Item category ───────────────────────────────────────────────
    IC.DESCRIPTION                                        AS ITEM_CAT,

    -- ── Service category ────────────────────────────────────────────
    SER.DESCRIPTION                                       AS SERVICE_CATEGORY,

    -- ── Cancellation ────────────────────────────────────────────────
    RFC.DESCRIPTION                                       AS CANCEL_REASON,
    RFC.CODE                                              AS CANCEL_REASON_CODE,
    RFC.INITIATOR                                         AS CANCEL_INITIATOR,
    APPT.CANCEL_DATE                                      AS CANCEL_DATE,
    APPT.CANCEL_TIME                                      AS CANCEL_TIME,
    TO_TIMESTAMP(
        APPT.CANCEL_DATE::VARCHAR || ' ' || APPT.CANCEL_TIME::VARCHAR
    )                                                     AS CANCELLED_DATE_TIME,

    -- ── Did not attend ──────────────────────────────────────────────
    RNS.DESCRIPTION                                       AS DNA_REASON,
    RNS.CODE                                              AS DNA_REASON_CODE,

    -- ── Transport ───────────────────────────────────────────────────
    APTR.DESCRIPTION                                      AS TRANSPORT_TYPE,
    APTR.CODE                                             AS TRANSPORT_CODE,
    APPT.TRANSPORT_REQUIRED                               AS TRANSPORT_REQUIRED,
    APPT.TRANSPORT_COMMENTS                               AS TRANSPORT_COMMENTS,
    APPT.TRANS_DATE                                       AS TRANS_DATE,
    TO_TIMESTAMP(
        APPT.TRANS_DATE::VARCHAR || ' ' || APPT.TRANS_TIME::VARCHAR
    )                                                     AS TRANS_DATE_TIME,
    TU.NAME                                               AS TRANSPORT_USER,

    -- ── Group event ─────────────────────────────────────────────────
    APPT.RB_EVENT_DR                                      AS APPT_RBEVENT_DR,
    EV.NUMBER                                             AS EV_NUMBER,
    EV.NAME                                               AS EVENT_NAME,
    EV.STATUS                                             AS EVENT_STATUS,
    EV.DURATION                                           AS EVENT_DURATION_MINUTES,
    EV.MAX_NO_OF_PARTICIPANTS                             AS EVENT_MAX_PARTICIPANTS,
    EV.VENUE                                              AS EVENT_VENUE,
    EV.PREPARATION_TIME                                   AS EV_PREPARATION_TIME,
    EVT.DESCRIPTION                                       AS EVENT_TYPE,
    EVT.CODE                                              AS EVENT_TYPE_CODE,
    SUB.DESCRIPTION                                       AS EVENT_SUBTYPE,
    SUB.CODE                                              AS EVENT_SUBTYPE_CODE,

    -- ── Interpreter ─────────────────────────────────────────────────
    APPT.INTERPRETER_REQUIRED                             AS INTERPRETER_REQUIRED,
    APPT.INTERPRETER_CONFIRMED                            AS INTERPRETER_CONFIRMED,
    APPT.CUSTOM_TEXT_1                                    AS INTERPRETER_BOOKING_REF,
    APPT.CUSTOM_TEXT_2                                    AS CUSTOM_TEXT_2,
    APPT.CUSTOM_TEXT_3                                    AS CUSTOM_TEXT_3,
    APPT.DOCTOR_LETTER_NOTES                              AS INTERPRETER_NOTES,
    LANG.DESCRIPTION                                      AS LANGUAGES,

    -- ── Misc flags ──────────────────────────────────────────────────
    APPT.PATIENT_NOT_ATTENDING                            AS PATIENT_NOT_ATTENDING,
    APPT.FIRST_APPT_FLAG                                  AS FIRST_APPOINTMENT_FLAG,
    APPT.REMARKS                                          AS REMARKS,

    -- ── Program stream — OE_OrdItem2 not yet in Snowflake ───────────
    NULL::VARCHAR                                         AS PROGRAM_STREAM_CODE,
    NULL::VARCHAR                                         AS PROGRAM_STREAM,

    -- ── Financial year quarter ──────────────────────────────────────
    CASE
        WHEN MONTH(APPT.COMPLETION_DATE) >= 7
            THEN YEAR(APPT.COMPLETION_DATE)::VARCHAR
                 || '-' || (YEAR(APPT.COMPLETION_DATE) + 1)::VARCHAR
                 || ' Q'
                 || CASE
                        WHEN MONTH(APPT.COMPLETION_DATE) IN (7,8,9)    THEN '1'
                        WHEN MONTH(APPT.COMPLETION_DATE) IN (10,11,12) THEN '2'
                        WHEN MONTH(APPT.COMPLETION_DATE) IN (1,2,3)    THEN '3'
                        ELSE '4'
                    END
        ELSE (YEAR(APPT.COMPLETION_DATE) - 1)::VARCHAR
             || '-' || YEAR(APPT.COMPLETION_DATE)::VARCHAR
             || ' Q'
             || CASE
                    WHEN MONTH(APPT.COMPLETION_DATE) IN (7,8,9)    THEN '1'
                    WHEN MONTH(APPT.COMPLETION_DATE) IN (10,11,12) THEN '2'
                    WHEN MONTH(APPT.COMPLETION_DATE) IN (1,2,3)    THEN '3'
                    ELSE '4'
                END
    END                                                   AS APPOINTMENT_REF_QTR

FROM {{ ref('prep_stg_trakcare_rb_appointment') }}        AS APPT

-- Patient
LEFT JOIN {{ ref('prep_stg_trakcare_pa_patmas') }}        AS PAT
    ON APPT.PATIENT_DR = PAT.PATIENT_ID

-- Episode
LEFT JOIN {{ ref('prep_stg_trakcare_pa_adm') }}           AS ADM
    ON APPT.ADM_DR = ADM.ADM_ID

-- Resource / CP / team
LEFT JOIN {{ ref('prep_stg_trakcare_rb_resource') }}      AS RES
    ON APPT.AT_DR = RES.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_loc') }}           AS LOC
    ON RES.CT_LOC_DR = LOC.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}      AS CP
    ON CAST(RES.CT_PCP_DR AS VARCHAR) = CAST(CP.ROW_ID AS VARCHAR)

-- Services → item master → item category
LEFT JOIN {{ ref('prep_stg_trakcare_rbc_services') }}     AS SER
    ON APPT.RBC_SERV_DR = SER.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itmmast') }}      AS IM
    ON CAST(SER.ARCIM_DR AS VARCHAR) = CAST(IM.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC
    ON CAST(IM.ITEM_CAT_DR AS NUMBER(18,0)) = IC.ROW_ID

-- Booked by
LEFT JOIN booked_by                                       AS BB
    ON APPT.BOOKED_BY_DR = BB.ROW_ID

-- Cancellation reason
LEFT JOIN {{ ref('prep_stg_trakcare_rbc_reasonforcancel') }} AS RFC
    ON APPT.REASON_FOR_CANCEL_DR = RFC.ROW_ID

-- Did not attend reason
LEFT JOIN {{ ref('prep_stg_trakcare_rbc_reasonfornotshow') }} AS RNS
    ON APPT.REASON_NOT_SHOW = RNS.ROW_ID

-- Transport
LEFT JOIN {{ ref('prep_stg_trakcare_rbc_appointtransport') }} AS APTR
    ON APPT.TRANSPORT_DR = APTR.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ss_user') }}          AS TU
    ON APPT.TRANS_USER_DR = TU.ROW_ID

-- Preferred language
LEFT JOIN {{ ref('prep_stg_trakcare_pac_preferred_language') }} AS LANG
    ON APPT.LANGUAGE_DR = LANG.ROW_ID

-- Group event
LEFT JOIN {{ ref('prep_stg_trakcare_rb_event') }}         AS EV
    ON APPT.RB_EVENT_DR = EV.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventtype') }}    AS EVT
    ON EV.TYPE_DR = EVT.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventsubtype') }} AS SUB
    ON EV.EVENT_SUB_TYPE_DR = SUB.ROW_ID

WHERE APPT.ROW_ID IS NOT NULL