{% snapshot HIST_MANUAL_FUND_SOURCE_TARGETS %}

{{
    config(
        schema='REFERENCE_DATA',
        unique_key='FUND_SOURCE_TARGET_KEY',
        strategy='check',
        check_cols=[
            'ID', 'TYPE', 'ABREV', 'UNITS', 'PROGRAM', 'DATA_SET_',
            'VADC_FUND', 'SHORT_DESC', 'ALT_PROGRAM', 'COST_CENTER',
            'FUND_SOURCE', 'LOOKUPVALUE', 'SUB_PROGRAM', 'SHORTFUNDDESC',
            'MONTHLYTARGETS', 'YEARLY_TARGETS', 'LEGACY_ORGANISATION',
            'PROGRAM_STREAM_DESC'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    MD5(
        COALESCE(ID::VARCHAR, 'null')               || '|' ||
        COALESCE(TYPE, 'null')                      || '|' ||
        COALESCE(ABREV, 'null')                     || '|' ||
        COALESCE(PROGRAM, 'null')                   || '|' ||
        COALESCE(DATA_SET_, 'null')                 || '|' ||
        COALESCE(FUND_SOURCE, 'null')               || '|' ||
        COALESCE(SUB_PROGRAM, 'null')               || '|' ||
        COALESCE(LEGACY_ORGANISATION, 'null')       || '|' ||
        COALESCE(PROGRAM_STREAM_DESC, 'null')       || '|' ||
        COALESCE(MONTHLYTARGETS::VARCHAR, 'null')   || '|' ||
        COALESCE(YEARLY_TARGETS::VARCHAR, 'null')
    )                                               AS FUND_SOURCE_TARGET_KEY,
    *

FROM {{ source('raw_manual', 'FUNDSOURCETARGETS') }}

{% endsnapshot %}