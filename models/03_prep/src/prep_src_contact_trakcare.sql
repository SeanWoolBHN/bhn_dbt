-- Replace the existing order_status CTE:
WITH order_status AS (
    -- SSIS: SELECT TOP 1 OSTAT_Desc FROM OE_OrdStatus 
    --       LEFT JOIN OEC_OrderStatus ON OSTAT_RowId = ST_Status_DR
    --       WHERE ST_ParRef = ENQ_OEOrdItem_DR ORDER BY ST_ChildSub DESC
    SELECT
        OS.PAR_REF,
        OEC.DESCRIPTION                                   AS ORDER_STATUS_DESC,
        ROW_NUMBER() OVER (
            PARTITION BY OS.PAR_REF
            ORDER BY TRY_TO_NUMBER(OS.CHILD_SUB::VARCHAR, 18, 0) DESC NULLS LAST
        )                                                 AS RN
    FROM {{ ref('prep_stg_trakcare_oe_ordstatus') }}      AS OS
    LEFT JOIN {{ ref('prep_stg_trakcare_oec_orderstatus') }} AS OEC
        ON OS.STATUS_DR = OEC.ROW_ID
),

price_lookup AS (
    -- Deduplicate ARC_ITEMPRICEITALY — multiple rows per PAR_REF
    -- (one per insurer/location combination via CHILD_SUB)
    -- Pick lowest CHILD_SUB as the base price row
    SELECT
        PAR_REF,
        PRICE,
        ROW_NUMBER() OVER (
            PARTITION BY PAR_REF
            ORDER BY TRY_TO_NUMBER(CHILD_SUB::VARCHAR, 18, 0) ASC NULLS LAST
        )                                                 AS RN
    FROM {{ ref('prep_stg_trakcare_arc_itempriceitaly') }}
)

SELECT
    ENQ.CONTACT_ID                                        AS CONTACT_ID,

    -- ── UR — via ENQ_PAPER_DR → PA_PERSON → PA_PATMAS ───────────────
    PAT.PATIENT_NO::VARCHAR                               AS UR,

    -- ── Episode — via OE_ORDITEM → OE_ORDER → PA_ADM ────────────────
    ADM.ADM_NO::VARCHAR                                   AS EPISODE_ID,

    -- ── Contact dates ───────────────────────────────────────────────
    ENQ.CONTACT_DATE                                      AS CONTACT_DATE,
    ENQ.CONTACT_TIME                                      AS CONTACT_TIME,
    TRY_TO_TIMESTAMP(
        ENQ.CONTACT_DATE::VARCHAR || ' ' || ENQ.CONTACT_TIME::VARCHAR
    )                                                     AS CONTACT_DATE_TIME,

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
    END                                                   AS REPORTING_QTR,

    -- ── Request status — now wired ───────────────────────────────────
    REQST.DESCRIPTION                                     AS REQUEST_STATUS,

    -- ── CP — contact CP fallback to SS_USER via OE_ORDITEM ──────────
    COALESCE(
        NULLIF(CP_CONTACT.DESCRIPTION, ''),
        NULLIF(USR.NAME, ''),
        'Unknown'
    )                                                     AS CP,

    -- ── Location / hospital ─────────────────────────────────────────
    LOC.DESCRIPTION                                       AS LOCATION,
    HOSP.DESCRIPTION                                      AS HOSPITAL,

    -- ── Dates ───────────────────────────────────────────────────────
    ENQ.UPDATED_DATE                                      AS DATE_ENTERED,

    -- ── Hours ───────────────────────────────────────────────────────
    ENQ.DURATION                                          AS DIRECT_MINUTES,
    ENQ.INDIRECT_TIME                                     AS INDIRECT_MINUTES,
    ENQ.TRAVEL_TIME                                       AS TRAVEL_MINUTES,
    ENQ.INTERPRETING_TIME                                 AS INTERPRETER,
    ENQ.DISTANCE_TRAVELLED                                AS KM,

    -- ── Payor / plan — now wired ────────────────────────────────────
    INST.DESCRIPTION                                      AS PAYOR,
    AUX.DESCRIPTION                                       AS PLAN,
    AUX.CODE                                              AS AUXIT_CODE,

    -- ── Program stream ──────────────────────────────────────────────
    PROG.CODE                                             AS PROGRAM_STREAM_CODE,
    PROG.DESCRIPTION                                      AS PROGRAM_STREAM_DESC,

    -- ── Financial ───────────────────────────────────────────────────
    ENQ.FEE                                               AS COST,
    ITP.PRICE                                             AS UNIT_PRICE,

    -- ── Contact method — now wired ───────────────────────────────────
    CMETH.DESCRIPTION                                     AS CONTACT_METHOD,

    -- ── Text fields ─────────────────────────────────────────────────
    ENQ.TEXT_1                                            AS STO,
    ENQ.TEXT_2                                            AS CLIENT_COUNT,
    ENQ.TEXT_3                                            AS TEXT_3,
    ENQ.TEXT_4                                            AS TEXT_4,

    -- ── Order item reference ─────────────────────────────────────────
    ENQ.OE_ORD_ITEM_DR                                    AS OEORDI_REF,

    -- ── Ord item ────────────────────────────────────────────────────
    IM.DESCRIPTION                                        AS ORD_ITEM,

    -- ── Contact type ────────────────────────────────────────────────
    ENQ.CONTACT_TYPE                                      AS CONTACT_TYPE,
    CASE
        WHEN ENQ.CONTACT_TYPE = 'A'
            THEN 'Non Registered / Org client'
        ELSE 'client'
    END                                                   AS CONTACT_TYPE_DESC,

    -- ── Ord sub cat ─────────────────────────────────────────────────
    CASE
        WHEN ENQ.CONTACT_TYPE = 'I'
            THEN IC_VIA_IM.DESCRIPTION
        ELSE IC_DIRECT.DESCRIPTION
    END                                                   AS ORD_SUB_CAT,

    -- ── Order status — from OE_ORDSTATUS ────────────────────────────
    ORDS.ORDER_STATUS_DESC                                AS ORDER_STATUS,

    -- ── Interventions ───────────────────────────────────────────────
    ENQ.CONTACT_INTERVENTIONS                             AS CONTACT_INTERVENTIONS,
    IM2.DESCRIPTION                                       AS INTERVENTIONS,

    -- ── Action details ──────────────────────────────────────────────
    ENQ.ACTION_DETAILS                                    AS ACTION_DETAILS,

    -- ── Contact reference lookups — now wired ────────────────────────
    DM.DESCRIPTION                                        AS DELIVERY_MODE,
    CV.DESCRIPTION                                        AS VENUE,
    WT.DESCRIPTION                                        AS WORKER_TYPE,
    PIS.DESCRIPTION                                       AS PRESENTING_ISSUE,
    RTS.DESCRIPTION                                       AS RELATIONSHIP_TO_SELF,
    OC.DESCRIPTION                                        AS OUTCOME,
    LG.DESCRIPTION                                        AS LOCAL_GOAL,
    INTT.DESCRIPTION                                      AS INTERPRETER_TYPE,
    RETY.DESCRIPTION                                      AS ANON_CLIENT_TYPE,
    NG.DESCRIPTION                                        AS ANON_CLIENT_ORG,
    G.DESC                                                AS CONTACT_SEX,

    -- ── Contact name ────────────────────────────────────────────────
    ENQ.CONTACT_NAME                                      AS ENQ_CONTACT_NAME,
    ENQ.CONTACT_NO                                        AS ENQ_CONTACT_NUMBER,

    -- ── Interpreter ─────────────────────────────────────────────────
    ENQ.INTERPRETER_REQUIRED                              AS INTERPRETER_REQUIRED,

    -- ── Misc ────────────────────────────────────────────────────────
    ENQ.URGENT_CONTACT                                    AS URGENT_CONTACT,
    ENQ.INPATIENT_FLAG                                    AS INPATIENT_FLAG,
    ENQ.VOLUNTEER_SER                                     AS VOLUNTEER_SER,
    ENQ.YES_NO_1                                          AS YES_NO_1,
    ENQ.YES_NO_2                                          AS YES_NO_2,

    -- ── Group event fields ──────────────────────────────────────────
    ENQ.RB_EVENT_DR                                       AS RB_EVENT_DR,
    EV.NUMBER                                             AS EV_NUMBER,
    EV.NAME                                               AS EV_NAME,
    EVT.DESCRIPTION                                       AS EVT_DESC,
    SUB.DESCRIPTION                                       AS EVST_SUB_DESC,
    EV.VENUE                                              AS EV_VENUE,
    EV.DURATION                                           AS EV_DURATION,
    EV.MAX_NO_OF_PARTICIPANTS                             AS EV_MAX_NUMBER_OF_PARTICIPANTS,
    EV.PREPARATION_TIME                                   AS EV_PREPARATION_TIME

FROM {{ ref('prep_stg_trakcare_pa_enquirycontact') }}     AS ENQ

-- Person → Patient
LEFT JOIN {{ ref('prep_stg_trakcare_pa_person') }}        AS PER
    ON ENQ.PERSON_DR = CAST(PER.PERSON_ID AS NUMBER(18,0))

LEFT JOIN {{ ref('prep_stg_trakcare_pa_patmas') }}        AS PAT
    ON CAST(PER.PATIENT_DR AS NUMBER(18,0)) = CAST(PAT.PATIENT_ID AS NUMBER(18,0))

-- OE_ORDITEM
LEFT JOIN {{ ref('prep_stg_trakcare_oe_orditem') }}       AS OI
    ON ENQ.OE_ORD_ITEM_DR = OI.ROW_ID

-- Episode via OE_ORDER — per client request
LEFT JOIN {{ ref('prep_stg_trakcare_oe_order') }}         AS ORD
    ON CAST(OI.OE_ORD_PAR_REF AS VARCHAR) = CAST(ORD.ROW_ID_1 AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_pa_adm') }}           AS ADM
    ON CAST(ORD.ADM_DR AS VARCHAR) = CAST(ADM.ADM_ID AS VARCHAR)

-- Care provider
LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}      AS CP_CONTACT
    ON CAST(ENQ.CT_CP_DR AS VARCHAR) = CAST(CP_CONTACT.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_careprov') }}      AS CP_EPISODE
    ON CAST(ADM.HCP_DR AS VARCHAR) = CAST(CP_EPISODE.ROW_ID AS VARCHAR)

-- SS_USER fallback for CP
LEFT JOIN {{ ref('prep_stg_trakcare_ss_user') }}          AS USR
    ON OI.USER_UPDATE = USR.ROW_ID

-- Location / hospital
LEFT JOIN {{ ref('prep_stg_trakcare_ct_loc') }}           AS LOC
    ON CAST(ENQ.LOCATION_DR AS VARCHAR) = CAST(LOC.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_ct_hospital') }}      AS HOSP
    ON CAST(ENQ.HOSPITAL_DR AS VARCHAR) = CAST(HOSP.ROW_ID AS VARCHAR)

-- Payor — ARC_INSURANCETYPE per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_arc_insurancetype') }} AS INST
    ON CAST(ENQ.INS_TYPE_DR AS VARCHAR) = CAST(INST.ROW_ID AS VARCHAR)

-- Plan — ARC_AUXILINSURTYPE per SSIS
LEFT JOIN {{ ref('prep_stg_trakcare_arc_auxilinsurtype') }} AS AUX
    ON CAST(ENQ.AUX_INS_TYPE_DR AS VARCHAR) = CAST(AUX.ROW_ID AS VARCHAR)

-- Program stream
LEFT JOIN {{ ref('prep_stg_trakcare_ct_nfmi_categdepart') }} AS PROG
    ON CAST(ENQ.GOVERN_DEPART_DR AS VARCHAR) = CAST(PROG.ROW_ID AS VARCHAR)

-- Item master / item category
LEFT JOIN {{ ref('prep_stg_trakcare_arc_itmmast') }}      AS IM
    ON CAST(OI.ITM_MAST_DR AS VARCHAR) = CAST(IM.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC_VIA_IM
    ON IM.ITEM_CAT_DR = IC_VIA_IM.ROW_ID

LEFT JOIN {{ ref('prep_stg_trakcare_arc_itemcat') }}      AS IC_DIRECT
    ON CAST(ENQ.ITEM_CAT_DR AS VARCHAR) = CAST(IC_DIRECT.ROW_ID AS VARCHAR)

-- Unit price — ARC_ITEMPRICEITALY
LEFT JOIN price_lookup                                    AS ITP
    ON CAST(OI.ITM_MAST_DR AS VARCHAR) = CAST(ITP.PAR_REF AS VARCHAR)
    AND ITP.RN = 1

-- Request status — now wired
LEFT JOIN {{ ref('prep_stg_trakcare_pac_requeststatus') }} AS REQST
    ON CAST(ENQ.REQUEST_STATUS_DR AS VARCHAR) = CAST(REQST.ROW_ID AS VARCHAR)

-- Order status — from OE_ORDSTATUS CTE
LEFT JOIN order_status                                    AS ORDS
    ON CAST(ENQ.OE_ORD_ITEM_DR AS VARCHAR) = CAST(ORDS.PAR_REF AS VARCHAR)
    AND ORDS.RN = 1

-- Contact method
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contmethod') }}   AS CMETH
    ON CAST(ENQ.CONT_METHOD_DR AS VARCHAR) = CAST(CMETH.ROW_ID AS VARCHAR)

-- Delivery mode
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contdelivmode') }} AS DM
    ON CAST(ENQ.CONT_DELIV_MODE_DR AS VARCHAR) = CAST(DM.ROW_ID AS VARCHAR)

-- Venue
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contvenue') }}    AS CV
    ON CAST(ENQ.CONT_VENUE_DR AS VARCHAR) = CAST(CV.ROW_ID AS VARCHAR)

-- Worker type
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contworkertype') }} AS WT
    ON CAST(ENQ.CONT_WORKER_TYPE_DR AS VARCHAR) = CAST(WT.ROW_ID AS VARCHAR)

-- Presenting issue
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contpresentingissue') }} AS PIS
    ON CAST(ENQ.CONT_CLIENT_PRES_STAT_DR AS VARCHAR) = CAST(PIS.ROW_ID AS VARCHAR)

-- Relationship to self
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contservicerec2') }} AS RTS
    ON CAST(ENQ.CONT_SERVICE_REC2_DR AS VARCHAR) = CAST(RTS.ROW_ID AS VARCHAR)

-- Outcome
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contoutcome') }}  AS OC
    ON CAST(ENQ.CONT_OUTCOME_DR AS VARCHAR) = CAST(OC.ROW_ID AS VARCHAR)

-- Local goal
LEFT JOIN {{ ref('prep_stg_trakcare_pac_contlocalgoal') }} AS LG
    ON CAST(ENQ.CONT_LOCAL_GOAL_DR AS VARCHAR) = CAST(LG.ROW_ID AS VARCHAR)

-- Interpreter type
LEFT JOIN {{ ref('prep_stg_trakcare_pac_continterpretertype') }} AS INTT
    ON CAST(ENQ.CONT_INTERPRETER_TYPE_DR AS VARCHAR) = CAST(INTT.ROW_ID AS VARCHAR)

-- Anonymous client type
LEFT JOIN {{ ref('prep_stg_trakcare_pac_requesttype') }}  AS RETY
    ON CAST(ENQ.REQUEST_TYPE_DR AS VARCHAR) = CAST(RETY.ROW_ID AS VARCHAR)

-- Anonymous client org
LEFT JOIN {{ ref('prep_stg_trakcare_pac_nongovorg') }}    AS NG
    ON CAST(ENQ.NON_GOV_ORG_DR AS VARCHAR) = CAST(NG.ROW_ID AS VARCHAR)

-- Contact sex
LEFT JOIN {{ ref('prep_stg_trakcare_ct_sex') }}           AS G
    ON CAST(ENQ.SEX_DR AS VARCHAR) = CAST(G.ROW_ID AS VARCHAR)

-- Interventions
LEFT JOIN {{ ref('prep_stg_trakcare_arc_itmmast') }}      AS IM2
    ON LEFT(ENQ.CONTACT_INTERVENTIONS, LEN(ENQ.CONTACT_INTERVENTIONS) - 1)
       = IM2.ROW_ID::VARCHAR

-- Group event
LEFT JOIN {{ ref('prep_stg_trakcare_rb_event') }}         AS EV
    ON CAST(ENQ.RB_EVENT_DR AS VARCHAR) = CAST(EV.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventtype') }}    AS EVT
    ON CAST(EV.TYPE_DR AS VARCHAR) = CAST(EVT.ROW_ID AS VARCHAR)

LEFT JOIN {{ ref('prep_stg_trakcare_rbc_eventsubtype') }} AS SUB
    ON CAST(EV.EVENT_SUB_TYPE_DR AS VARCHAR) = CAST(SUB.ROW_ID AS VARCHAR)

WHERE ENQ.CONTACT_ID IS NOT NULL