{% snapshot HIST_TRAKCARE_RT_MASTER %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='RTMAS_ROWID',
        strategy='check',
        check_cols=[
            'RTMAS_MRNO',
            'RTMAS_PATNO_DR',
            'RTMAS_EXPDAYS',
            'RTMAS_HOMELOC_DR',
            'RTMAS_STATUS',
            'RTMAS_LOOKUP',
            'RTMAS_TYPE',
            'RTMAS_MRTYPE_DR',
            'RTMAS_DATECREATE',
            'RTMAS_TIMECREATE',
            'RTMAS_USERCREATE_DR',
            'RTMAS_ACTIVE',
            'RTMAS_CREATELOC_DR',
            'RTMAS_HOSPITAL_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'RT_MASTER') }}

{% endsnapshot %}