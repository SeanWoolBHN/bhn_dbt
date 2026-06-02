-- models/staging/stg_better_impact_profile.sql

WITH source AS (
    SELECT * FROM {{ source('raw_better_impact', 'PROFILE_EXPORT') }}
),

cleaned AS (
    SELECT
        -- Primary Key
        CAST(DATABASEUSERID AS VARCHAR)                                         AS database_user_id,

        -- Name Fields
        TRIM(NULLIF(FIRSTNAME, ''))                                             AS first_name,
        TRIM(NULLIF(LASTNAME, ''))                                              AS last_name,
        TRIM(NULLIF(LEGALFIRSTNAME, ''))                                        AS legal_first_name,
        TRIM(NULLIF(MIDDLENAME, ''))                                            AS middle_name,
        TRIM(NULLIF(SALUTATION, ''))                                            AS salutation,
        TRIM(NULLIF(SUFFIX, ''))                                                AS suffix,

        -- Contact
        LPAD(CAST(POSTALCODE AS VARCHAR), 4, '0')                               AS postal_code,
        TRIM(LOWER(NULLIF(EMAILADDRESS, '')))                                   AS email_address,
        TRIM(LOWER(NULLIF(USERNAME, '')))                                       AS username,

        -- Demographics
        -- Parse MM/DD/YY from source then reformat to DD/MM/YYYY
        TO_VARCHAR(
            TRY_TO_DATE(BIRTHDAY, 'MM/DD/YY'), 'DD/MM/YY'
        )                                                                       AS date_of_birth,
        AGE                                                                     AS age,

        -- Client Status
        TRIM(NULLIF(CLIENTSTATUS, ''))                                          AS client_status,
        TO_VARCHAR(
            TRY_TO_DATE(DATEOFLASTCLIENTSTATUSCHANGE, 'MM/DD/YY'), 'DD/MM/YY'
        )                                                                       AS date_of_last_status_change,
        TO_VARCHAR(
            TRY_TO_DATE(CLIENTDATEJOINED, 'MM/DD/YY'), 'DD/MM/YY'
        )                                                                       AS client_date_joined,
        YEARSSINCECLIENTDATEJOINED                                              AS years_since_joined,

        -- Custom Fields
        TRIM(NULLIF("CF - Aged Care Facility match information  - Aged care facility (list)", ''))                                                                              AS cf_aged_care_facility,
        TRIM(NULLIF("CF - Aged Care Funding Details - If relevant select name of Home Care Package Provider or Residential Aged Care Facility where the client resides", ''))   AS cf_aged_care_funding_details,
        TRIM(NULLIF("CF - About Your Client - Gender", ''))                                                                                                                     AS cf_gender,
        TRIM(NULLIF("CF - About Your Client - Country of origin", ''))                                                                                                          AS cf_country_of_origin,
        TRIM(NULLIF("CF - About Your Client - Preferred language", ''))                                                                                                         AS cf_preferred_language,
        TRIM(NULLIF("CF - About Your Client - Work background", ''))                                                                                                            AS cf_work_background,
        TRIM(NULLIF("CF - Special needs groups (this information is requested by the Dept. of Health) - Does the recipient identify as being from a special needs group?", '')) AS cf_special_needs_group,
        TRIM(NULLIF("CF - Special needs groups (this information is requested by the Dept. of Health) - If more than one special need applies please list here", ''))           AS cf_special_needs_details,
        TRIM(NULLIF("CF - Match details - Date of match", ''))                                                                                                                  AS cf_match_date,
        TRIM(NULLIF("CF - Match details - Name of visitor", ''))                                                                                                                AS cf_match_visitor_name,
        TRIM(NULLIF("CF - Match details - Potential volunteer", ''))                                                                                                            AS cf_potential_volunteer,

        -- Metadata
        CURRENT_TIMESTAMP()                                                     AS _stg_loaded_at

    FROM source
)

SELECT * FROM cleaned