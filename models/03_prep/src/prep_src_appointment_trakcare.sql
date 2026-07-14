SELECT
    -- ── Surrogate keys (placeholders) ──────────────────────────────
    --'APPOINTMENT_KEY'                                   AS APPOINTMENT_KEY,
    --'CLIENT_KEY'                                        AS CLIENT_KEY,
    --'EPISODE_KEY'                                       AS EPISODE_KEY,
    --'ORGANISATION_KEY'                                  AS ORGANISATION_KEY,
    --'LOCATION_KEY'                                      AS LOCATION_KEY,
    --'CARE_PROVIDER_KEY'                                 AS CARE_PROVIDER_KEY,
    --'PROGRAM_KEY'                                       AS PROGRAM_KEY,

    -- ── Natural keys ────────────────────────────────────────────────
    APPT.ROW_ID                                         AS APPOINTMENT_ID, --ApptRowID
    PAT.PATIENT_NO                                      AS UR,--UR
    APPT.ADM_DR                                         AS EPISODE_DR_RAW,
    APPT.OE_ORI_DR                                      AS OEORDI_REF, --OEOrdItem_Ref


    -- ── Appointment dates and times ─────────────────────────────────
    APPT.BOOKED_DATE                                    AS BOOKED_DATE,
    APPT.BOOKED_TIME                                    AS BOOKED_TIME,
    APPT.COMPLETION_DATE                                AS APPOINTMENT_DATE, --ApptDate
    APPT.COMPLETION_TIME                                AS APPOINTMENT_TIME,
    APPT.ARRIVAL_DATE                                   AS ARRIVAL_DATE,
    APPT.ARRIVAL_TIME                                   AS ARRIVAL_TIME,
    APPT.END_DATE                                       AS END_DATE,
    APPT.END_TIME                                       AS END_TIME,
    APPT.CANCEL_DATE                                    AS CANCEL_DATE,
    APPT.CANCEL_TIME                                    AS CANCEL_TIME,
    APPT.DURATION                                       AS DURATION_MINUTES,

    -- ── Appointment status ──────────────────────────────────────────
    APPT.STATUS                                         AS APPOINTMENT_STATUS,

    -- ── Care provider ───────────────────────────────────────────────
    APPT.CARE_PROVIDER                                  AS APPOINTMENT_CP,
    CONCAT_WS(' ',
        NULLIF(TRIM(CP.FIRST_NAME), ''),
        NULLIF(TRIM(CP.LAST_NAME),  '')
    )                                                   AS APPOINTMENT_CP_RESOLVED,
    CP.CODE                                             AS APPOINTMENT_CP_CODE,
    RES.CODE                                            AS RESOURCE_CODE,
    RES.DESCRIPTION                                     AS RESOURCE_DESC,

    -- ── Location ────────────────────────────────────────────────────
    APPT.LOC_DR                                         AS LOCATION_DR_RAW,

    -- ── Service category ────────────────────────────────────────────
    SER.DESCRIPTION                                     AS SERVICE_CATEGORY,

    -- ── Cancellation reason ─────────────────────────────────────────
    RFC.DESCRIPTION                                     AS CANCEL_REASON,
    RFC.CODE                                            AS CANCEL_REASON_CODE,
    RFC.INITIATOR                                       AS CANCEL_INITIATOR,

    -- ── Did not attend reason ───────────────────────────────────────
    RNS.DESCRIPTION                                     AS DNA_REASON,
    RNS.CODE                                            AS DNA_REASON_CODE,

    -- ── Transport ───────────────────────────────────────────────────
    APTR.DESCRIPTION                                    AS TRANSPORT_TYPE,
    APTR.CODE                                           AS TRANSPORT_CODE,
    APPT.TRANSPORT_REQUIRED                             AS TRANSPORT_REQUIRED,
    APPT.TRANSPORT_COMMENTS                             AS TRANSPORT_COMMENTS,

    -- ── Group event details ─────────────────────────────────────────
    EV.NAME                                             AS EVENT_NAME,
    EV.STATUS                                           AS EVENT_STATUS,
    EV.DURATION                                         AS EVENT_DURATION_MINUTES,
    EV.MAX_NO_OF_PARTICIPANTS                           AS EVENT_MAX_PARTICIPANTS,
    EV.VENUE                                            AS EVENT_VENUE,
    EVT.DESCRIPTION                                     AS EVENT_TYPE,
    EVT.CODE                                            AS EVENT_TYPE_CODE,
    SUB.DESCRIPTION                                     AS EVENT_SUBTYPE,
    SUB.CODE                                            AS EVENT_SUBTYPE_CODE,

    -- ── Interpreter ─────────────────────────────────────────────────
    APPT.INTERPRETER_REQUIRED                           AS INTERPRETER_REQUIRED,
    APPT.INTERPRETER_CONFIRMED                          AS INTERPRETER_CONFIRMED,

    -- ── Misc appointment flags ──────────────────────────────────────
    APPT.PATIENT_NOT_ATTENDING                          AS PATIENT_NOT_ATTENDING,
    APPT.FIRST_APPT_FLAG                                AS FIRST_APPOINTMENT_FLAG,
    APPT.REMARKS                                        AS REMARKS,

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
    END                                                 AS APPOINTMENT_REF_QTR,

    -- ── Source system ───────────────────────────────────────────────
    'TRAKCARE'                                          AS SOURCE_SYSTEM

FROM {{ ref('prep_stg_trakcare_rb_appointment') }}      AS APPT

LEFT JOIN {{ ref('prep_stg_trakcare_pa_patmas') }}      AS PAT
    ON APPT.PATIENT_DR = PAT.PATIENT_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rb_resource') }}    AS RES
    ON APPT.AT_DR = RES.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}    AS CP
    ON RES.CT_PCP_DR = CP.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_reasonforcancel') }} AS RFC
    ON APPT.REASON_FOR_CANCEL_DR = RFC.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_reasonfornotshow') }} AS RNS
    ON APPT.REASON_NOT_SHOW = RNS.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_services') }}   AS SER
    ON APPT.RBC_SERV_DR = SER.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_appointtransport') }} AS APTR
    ON APPT.TRANSPORT_DR = APTR.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rb_event') }}       AS EV
    ON APPT.RB_EVENT_DR = EV.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventtype') }}  AS EVT
    ON EV.TYPE_DR = EVT.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventsubtype') }} AS SUB
    ON EV.EVENT_SUB_TYPE_DR = SUB.ROW_ID

WHERE APPT.ROW_ID IS NOT NULL