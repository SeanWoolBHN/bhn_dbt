{% snapshot HIST_TRAKCARE_CT_ZIP %}

{{
    config(
        schema='TRAKCARE',
        unique_key='CTZIP_ROWID',
        strategy='check',
        check_cols=[
            'CTZIP_CODE',
            'CTZIP_DESC'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_trakcare', 'CT_ZIP') }}

{% endsnapshot %}