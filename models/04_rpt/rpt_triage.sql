WITH info_referral_episodes AS (
    -- Episodes that are Information and Referral teams in current period
    SELECT
        EPISODE_ID,
        SERVICE,
        EPISODE_DT,
        EPISODE_REF_QTR,
        EPISODE_CP,
        INITIATED_BY,
        REF_CREATED_BY,
        REF_TYPE,
        REF_SOURCE,
        INT_REF_TEAM,
        EPISODE_TEAM
    FROM {{ ref('prep_model_episode') }}
    WHERE TRY_TO_NUMBER(LEFT(EPISODE_REF_QTR, 4)) >= CASE
              WHEN MONTH(CURRENT_DATE()) <= 6
                  THEN YEAR(CURRENT_DATE()) - 2
              ELSE YEAR(CURRENT_DATE()) - 1
          END
      AND EPISODE_TEAM = 'Information and Referral'
      AND SERVICE = 'Information and Referral'
),

base AS (
    SELECT
        CO.EPISODE_ID,
        EP.SERVICE,
        EP.EPISODE_DT,
        EP.EPISODE_REF_QTR,
        EP.EPISODE_CP,
        EP.INITIATED_BY,
        EP.REF_CREATED_BY,
        EP.REF_TYPE,
        EP.REF_SOURCE,
        EP.INT_REF_TEAM,
        CASE
            WHEN EP.EPISODE_TEAM ILIKE 'Case Man CSIA%'
                THEN 'Case Management - housing'
            WHEN EP.EPISODE_TEAM ILIKE 'Casework couns - family%'
                THEN 'Case work counselling family'
            WHEN EP.EPISODE_TEAM ILIKE 'Casework couns - general%'
                THEN 'Case work counselling general'
            WHEN EP.EPISODE_TEAM ILIKE 'Cht%'
                THEN CO.HOSPITAL || ' ' || CO.ORD_SUB_CAT
            ELSE EP.EPISODE_TEAM
        END                                               AS EPISODE_TEAMS,
        EP.EPISODE_TEAM,
        CASE
            WHEN EP.REF_TYPE = 'External Referral'
                THEN EP.REF_TYPE
            WHEN EP.REF_TYPE = 'Internal Referral'
              AND EP.REF_SOURCE = 'Internal from this agency'
                THEN 'Internal from this agency: no description provided'
            ELSE 'Internal: ' || EP.REF_SOURCE
        END                                               AS MOD_REF_SOURCE,
        'SH' || CO.CONTACT_ID::VARCHAR                    AS IROW_ID,
        CO.CONTACT_ID                                     AS ROW_ID,
        CO.CONTACT_DATE                                   AS CONTACT_DT,
        CO.CONTACT_TIME,
        CO.CONTACT_DATE_TIME,
        CO.REPORTING_QTR,
        CO.UR,

        CO.EPISODE_ID                                     AS EPISODE,
        CO.REQUEST_STATUS,
        CO.CP,
        CO.LOCATION,
        CO.HOSPITAL,
        CO.DATE_ENTERED,
        CO.DIRECT_MINUTES / 60                            AS DIRECT_HRS,
        CO.INDIRECT_MINUTES / 60                          AS INDIRECT_HRS,
        CO.TRAVEL_MINUTES / 60                            AS TRAVEL_HRS,
        CO.INTERPRETER,
        CO.KM,
        CO.PAYOR,
        CO.PLAN,
        CO.PROGRAM_STREAM_CODE,
        CO.PROGRAM_STREAM_DESC,
        CO.COST,
        CO.UNIT_PRICE,
        CO.CONTACT_METHOD,
        CO.STO,
        CO.CLIENT_COUNT,
        CO.TEXT_3                                         AS ENQ_TEXT_3,
        CO.TEXT_4                                         AS ENQ_TEXT_4,
        CO.OEORDI_REF,
        CO.ORD_ITEM,
        CO.CONTACT_TYPE,
        CO.ORD_SUB_CAT,
        CO.ORDER_STATUS,
        CO.OEORDI_REF                                     AS ENQ_OEORDITEM_DR,
        CO.CONTACT_INTERVENTIONS                          AS ENQ_CONTACT_INTERVENTIONS,
        CO.INTERVENTIONS,
        CO.ACTION_DETAILS                                 AS ENQ_ACTION_DETAILS,
        CO.DELIVERY_MODE,
        CO.VENUE,
        CO.WORKER_TYPE,
        CO.PRESENTING_ISSUE,
        CO.RELATIONSHIP_TO_SELF                           AS RELATIONSHIP_2_SELF,
        CO.OUTCOME,
        CO.LOCAL_GOAL,
        CO.INTERPRETER_TYPE                               AS INTERP_DESC,
        CO.ANON_CLIENT_TYPE,
        CO.ANON_CLIENT_ORG,
        CO.CONTACT_SEX,
        CO.ENQ_CONTACT_NAME,
        CO.ENQ_CONTACT_NUMBER,
        CO.RB_EVENT_DR                                    AS ENQ_RBEVENT_DR,
        CO.EV_NUMBER,
        CO.EV_NAME,
        CO.EVT_DESC,
        CO.EVST_SUB_DESC                                  AS GOVERNMENT_SUBCATEGORY_DESC,
        CO.EV_DURATION,
        CO.EV_VENUE,
        CO.EV_MAX_NUMBER_OF_PARTICIPANTS,
        CO.EV_PREPARATION_TIME,
        CO.AUXIT_CODE,
        CASE
            WHEN CO.CONTACT_TYPE != 'I' AND CO.ORD_ITEM IS NULL
                THEN 'Anon/Casual Contact'
            ELSE CO.ORD_ITEM
        END                                               AS ORDERS,

        -- Program derivation per SSIS
        CASE
            WHEN CO.CONTACT_DATE >= '2023-12-11' THEN
                CASE
                    WHEN CO.PROGRAM_STREAM_DESC = 'Community Health Program' THEN
                        CASE
                            WHEN CO.PAYOR = 'Community Health Program'
                                THEN 'Community Health Program'
                            WHEN CO.PAYOR = 'NDIA'
                                THEN CO.PAYOR
                            WHEN CO.PAYOR IS NULL
                                THEN 'Community Health Program'
                            ELSE CO.PLAN
                        END
                    ELSE 'Error'
                END
            WHEN CO.PROGRAM_STREAM_DESC ILIKE '%Family Violence%'
                THEN 'Family Violence'
            WHEN CO.PROGRAM_STREAM_DESC ILIKE '%CMHW%%'
                THEN 'Community Mental Wellbeing'
            ELSE REPLACE(CO.PROGRAM_STREAM_DESC, 'SEMPHN ', '')
        END                                               AS PROGRAM

    FROM {{ ref('prep_model_contact') }}                  AS CO

    LEFT JOIN {{ ref('prep_model_episode') }}             AS EP
        ON CO.EPISODE_ID = EP.EPISODE_ID::VARCHAR

    LEFT JOIN info_referral_episodes                      AS IR
        ON CO.EPISODE_ID = IR.EPISODE_ID

    WHERE TRY_TO_NUMBER(LEFT(CO.REPORTING_QTR, 4)) >= CASE
              WHEN MONTH(CURRENT_DATE()) <= 6
                  THEN YEAR(CURRENT_DATE()) - 2
              ELSE YEAR(CURRENT_DATE()) - 1
          END
      AND CO.HOSPITAL = 'Information and Referral'
      AND CO.ORD_SUB_CAT = 'Intake worker'
)

SELECT
    *,
    CASE
        WHEN PROGRAM_STREAM_DESC = 'Community Health Program'
            THEN PROGRAM_STREAM_DESC
        ELSE PROGRAM
    END                                                   AS PROGRAM_FUND,
    CASE
        WHEN PROGRAM_STREAM_CODE ILIKE '%FV%'       THEN PROGRAM
        WHEN PROGRAM_STREAM_CODE = 'CHPDCHP'        THEN 'Comm Health'
        WHEN PROGRAM_STREAM_CODE ILIKE '%HACC%'     THEN 'HACC'
        WHEN PROGRAM_STREAM_CODE ILIKE '%CMH%'      THEN 'Mental Health'
        WHEN PROGRAM_STREAM_CODE ILIKE '%CFP%'      THEN PROGRAM
        WHEN PROGRAM_STREAM_CODE ILIKE '%QEC%'      THEN 'QEC'
        WHEN PROGRAM_STREAM_CODE = 'WS'             THEN 'Work Safe'
        WHEN PROGRAM_STREAM_CODE ILIKE 'UP%'        THEN 'Upstart'
        ELSE PROGRAM_STREAM_CODE
    END                                                   AS SHORT_DESC,
    CASE
        WHEN PROGRAM ILIKE '%Family Violence%'
            THEN 'Family Violence'
        WHEN PROGRAM ILIKE '%Accessible Psych%'
            THEN 'API'
        WHEN PROGRAM ILIKE '%Community Health Program%'
            THEN 'Comm Health'
        WHEN PROGRAM ILIKE '%Mental Health Integrated Complex%'
            THEN 'MHIC'
        ELSE PROGRAM
    END                                                   AS SHORT_SERVICE_DESC

FROM base