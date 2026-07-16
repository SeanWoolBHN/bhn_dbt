{% snapshot HIST_REFERENCE_DATA_LOCATION_MAPPING %}

{{
    config(
        unique_key='LOCATION_MAPPING_KEY',
        strategy='check',
        check_cols=[
            'NATC_ACTUALVALUE', 'CTLOC_DESC', 'NATC_MAPPEDVALUE',
            'NATC_REPORTINGTYPE_DR', 'REPTYPE_DESC', 'CAMPUS',
            'LEGACYORGANISATIONID'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

WITH source AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            ORDER BY
                NATC_ACTUALVALUE,
                NATC_REPORTINGTYPE_DR,
                NATC_MAPPEDVALUE,
                CTLOC_DESC
        ) AS row_num
    FROM {{ source('raw_reference_data', 'LOCATION_MAPPING') }}
)

SELECT
    MD5(
        COALESCE(NATC_ACTUALVALUE, 'null')      || '|' ||
        COALESCE(CTLOC_DESC, 'null')             || '|' ||
        COALESCE(NATC_MAPPEDVALUE::VARCHAR, 'null') || '|' ||
        COALESCE(NATC_REPORTINGTYPE_DR::VARCHAR, 'null') || '|' ||
        COALESCE(REPTYPE_DESC, 'null')           || '|' ||
        COALESCE(CAMPUS, 'null')                 || '|' ||
        COALESCE(LEGACYORGANISATIONID::VARCHAR, 'null') || '|' ||
        row_num::VARCHAR
    )                                            AS LOCATION_MAPPING_KEY,
    NATC_ACTUALVALUE,
    CTLOC_DESC,
    NATC_MAPPEDVALUE,
    NATC_REPORTINGTYPE_DR,
    REPTYPE_DESC,
    CAMPUS,
    LEGACYORGANISATIONID
FROM source

{% endsnapshot %}