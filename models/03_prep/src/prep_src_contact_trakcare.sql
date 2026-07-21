SELECT
    -- ── Natural keys ────────────────────────────────────────────────
    ENQ.CONTACT_ID                                        AS CONTACT_ID,--
    PAT.PATIENT_NO                                        AS UR,--
    ADM.ADM_NO                                            AS EPISODE_ID,--

    -- OEOrdItem_Ref — bridge key linking contact to appointment
    ENQ.OE_ORD_ITEM_DR                                    AS OEORDI_REF,

    -- ── Program stream ──────────────────────────────────────────────
    PROG.CODE                                             AS PROGRAM_STREAM_CODE,
    PROG.DESCRIPTION                                      AS PROGRAM_STREAM_DESC,

    -- ── Location ────────────────────────────────────────────────────
    LOC.DESCRIPTION                                       AS LOCATION,
    HOSP.DESCRIPTION                                      AS HOSPITAL,

    -- ── Order item and subcategory ──────────────────────────────────
    IM.DESCRIPTION                                        AS ORD_ITEM,
    IM.CODE                                               AS ORD_ITEM_CODE,
    -- OrdSubCat — when ContactType = 'I' use ARCIM→ARCIC path,
    -- otherwise use ENQ.ITEM_CAT_DR direct
    CASE
        WHEN ENQ.CONTACT_TYPE = 'I'
            THEN IC_VIA_IM.DESCRIPTION
        ELSE IC_DIRECT.DESCRIPTION
    END                                                   AS ORD_SUB_CAT,
    IC.CODE                                               AS ORD_SUB_CAT_CODE,

    -- ── Care provider — CP coalesce ─────────────────────────────────
    COALESCE(
        CP_CONTACT.DESCRIPTION,
        USR.NAME
    )                                                     AS CARE_PROVIDER,

    -- ── Contact date ────────────────────────────────────────────────
    ENQ.CONTACT_DATE                                      AS CONTACT_DATE,
    ENQ.CONTACT_TIME                                      AS CONTACT_TIME,
    TRY_TO_TIMESTAMP(
        CAST(ENQ.CONTACT_DATE AS VARCHAR) || ' ' || CAST(ENQ.CONTACT_TIME AS VARCHAR)
    )                                                     AS CONTACT_DATE_TIME,

    -- ── Hours — raw minutes + pre-converted ─────────────────────────
    ENQ.DURATION                                          AS DIRECT_MINUTES,
    ENQ.INDIRECT_TIME                                     AS INDIRECT_MINUTES,
    ENQ.TRAVEL_TIME                                       AS TRAVEL_MINUTES,

    -- ── Contact type ────────────────────────────────────────────────
    ENQ.CONTACT_TYPE                                      AS CONTACT_TYPE,
    CASE
        WHEN ENQ.CONTACT_TYPE = 'A'
            THEN 'Non Registered / Org client'
        ELSE 'client'
    END                                                   AS CONTACT_TYPE_DESC,

    -- ── Contact method and status ───────────────────────────────────
    ENQ.CONT_METHOD_DR                                    AS CONTACT_METHOD_DR_RAW,
    ENQ.CONT_DELIV_MODE_DR                                AS DELIVERY_MODE_DR_RAW,
    ENQ.REQUEST_STATUS_DR                                 AS REQUEST_STATUS_DR_RAW,

    -- ── Contact name (anonymous/org contacts) ───────────────────────
    ENQ.CONTACT_NAME                                      AS ENQ_CONTACT_NAME,

    ENQ.INTERPRETING_TIME                                 AS INTERPRETER,
    ENQ.DISTANCE_TRAVELLED                                AS KM,

    -- ── Interpreter ─────────────────────────────────────────────────
    ENQ.INTERPRETER_REQUIRED                              AS INTERPRETER_REQUIRED,

    -- ── Payor and plan ──────────────────────────────────────────────
    'PAYOR_PENDING'                                       AS PAYOR,
    'PLAN_PENDING'                                        AS PLAN,

    -- ── Financial ───────────────────────────────────────────────────
    ENQ.FEE                                               AS COST,
    OI.COST                                               AS UNIT_PRICE,

    -- ── Interventions ───────────────────────────────────────────────
    ENQ.CONTACT_INTERVENTIONS                             AS CONTACT_INTERVENTIONS,
    IM2.DESCRIPTION                                       AS INTERVENTIONS,

    -- ── Group event fields ──────────────────────────────────────────
    ENQ.RB_EVENT_DR                                       AS RB_EVENT_DR,
    EV.NUMBER                                             AS EV_NUMBER,
    EV.NAME                                               AS EV_NAME,
    EVT.DESCRIPTION                                       AS EVT_DESC,
    SUB.DESCRIPTION                                       AS EVST_SUB_DESC,
    EV.VENUE                                              AS EV_VENUE,
    EV.DURATION                                           AS EV_DURATION,
    EV.MAX_NO_OF_PARTICIPANTS                             AS EV_MAX_NUMBER_OF_PARTICIPANTS,
    EV.PREPARATION_TIME                                   AS EV_PREPARATION_TIME,

    -- ── Additional fields ───────────────────────────────────────────
    ENQ.URGENT_CONTACT                                    AS URGENT_CONTACT,
    ENQ.INPATIENT_FLAG                                    AS INPATIENT_FLAG,
    ENQ.VOLUNTEER_SER                                     AS VOLUNTEER_SER,
    ENQ.TEXT_1                                            AS STO,
    ENQ.TEXT_2                                            AS CLIENT_COUNT,
    ENQ.TEXT_3                                            AS TEXT_3,
    ENQ.TEXT_4                                            AS TEXT_4,   
    ENQ.YES_NO_1                                          AS YES_NO_1,
    ENQ.YES_NO_2                                          AS YES_NO_2,
    ENQ.UPDATED_DATE                                      AS DATE_ENTERED,

    -- ── Reporting quarter ───────────────────────────────────────────
    CASE
        WHEN MONTH(ENQ.CONTACT_DATE) >= 7
            THEN YEAR(ENQ.CONTACT_DATE)::VARCHAR
                 || '-' || (YEAR(ENQ.CONTACT_DATE) + 1)::VARCHAR
                 || ' Q'
                 || CASE
                        WHEN MONTH(ENQ.CONTACT_DATE) IN (7,8,9)    THEN '1'
                        WHEN MONTH(ENQ.CONTACT_DATE) IN (10,11,12) THEN '2'
                        WHEN MONTH(ENQ.CONTACT_DATE) IN (1,2,3)    THEN '3'
                        ELSE '4'
                    END
        ELSE (YEAR(ENQ.CONTACT_DATE) - 1)::VARCHAR
             || '-' || YEAR(ENQ.CONTACT_DATE)::VARCHAR
             || ' Q'
             || CASE
                    WHEN MONTH(ENQ.CONTACT_DATE) IN (7,8,9)    THEN '1'
                    WHEN MONTH(ENQ.CONTACT_DATE) IN (10,11,12) THEN '2'
                    WHEN MONTH(ENQ.CONTACT_DATE) IN (1,2,3)    THEN '3'
                    ELSE '4'
                END
    END                                                   AS REPORTING_QTR

FROM {{ ref('prep_stg_trakcare_pa_enquirycontact') }}     AS ENQ

LEFT JOIN {{ ref('prep_stg_trakcare_pa_person') }}        AS PER
    ON ENQ.PERSON_DR = CAST(PER.PERSON_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pa_patmas') }}        AS PAT
    ON CAST(PER.PATIENT_DR AS NUMBER(18,0)) = CAST(PAT.PATIENT_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_oe_orditem') }}       AS OI
    ON CAST(ENQ.OE_ORD_ITEM_DR AS VARCHAR) = CAST(OI.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_pa_adm') }}           AS ADM
    ON CAST(OI.OE_ORD_PAR_REF AS VARCHAR) = CAST(ADM.ADM_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_loc') }}           AS LOC
    ON CAST(ENQ.LOCATION_DR AS VARCHAR) = CAST(LOC.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_hospital') }}      AS HOSP
    ON CAST(ENQ.HOSPITAL_DR AS VARCHAR) = CAST(HOSP.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}      AS CP_CONTACT
    ON CAST(ENQ.CT_CP_DR AS VARCHAR) = CAST(CP_CONTACT.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}      AS CP_EPISODE
    ON CAST(ADM.HCP_DR AS VARCHAR) = CAST(CP_EPISODE.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itmmast') }}      AS IM
    ON CAST(OI.ITM_MAST_DR AS VARCHAR) = CAST(IM.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC
    ON CAST(OI.CATEG_DR AS VARCHAR) = CAST(IC.ROW_ID AS VARCHAR)

-- SS_USER fallback for CP via OE_ORDITEM.USER_UPDATE
LEFT JOIN {{ ref('prep_stg_trakcare_ss_user') }}          AS USR
    ON (OI.USER_UPDATE) = USR.ROW_ID

-- Item category via item master (ContactType = 'I' path)
LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC_VIA_IM
    ON IM.ITEM_CAT_DR = IC_VIA_IM.ROW_ID

-- Item category direct from ENQ (ContactType != 'I' path)
LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC_DIRECT
    ON CAST(ENQ.ITEM_CAT_DR AS VARCHAR) = CAST(IC_DIRECT.ROW_ID AS VARCHAR)

-- Program stream from CT_NFMI_CATEGDEPART via ENQ_GOVERNDEPART_DR
LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS PROG
    ON CAST(ENQ.GOVERN_DEPART_DR AS VARCHAR) = CAST(PROG.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_rb_event') }}         AS EV
    ON CAST(ENQ.RB_EVENT_DR AS VARCHAR) = CAST(EV.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventtype') }}    AS EVT
    ON CAST(EV.TYPE_DR AS VARCHAR) = CAST(EVT.ROW_ID AS VARCHAR)

-- Interventions item master
LEFT JOIN {{ ref('prep_stg_trakcare_arc_itmmast') }}      AS IM2
    ON LEFT(ENQ.CONTACT_INTERVENTIONS, LEN(ENQ.CONTACT_INTERVENTIONS) - 1)
       = IM2.ROW_ID::VARCHAR

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventsubtype') }} AS SUB
    ON CAST(EV.EVENT_SUB_TYPE_DR AS VARCHAR) = CAST(SUB.ROW_ID AS VARCHAR)

WHERE ENQ.CONTACT_ID IS NOT NULL