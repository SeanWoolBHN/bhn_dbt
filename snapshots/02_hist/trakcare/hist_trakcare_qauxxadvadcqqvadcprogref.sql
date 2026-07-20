{% snapshot HIST_TRAKCARE_QAUXXADVADCQQVADCPROGREF %}
{{
    config(
        unique_key='VADC_PROG_REF_KEY',
        strategy='check',
        check_cols=[
            'ID', 'CHILDSUB', 'QUESPARREFDR', 'QVADCPROGREFQ1',
            'QVADCPROGREFQ2', 'QVADCPROGREFQ3', 'QVADCPROGREFQ4',
            'QVADCPROGREFQ5'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    MD5(
        COALESCE(ID, 'null') || '|' ||
        COALESCE(CHILDSUB::VARCHAR, 'null')
    )                                                   AS VADC_PROG_REF_KEY,
    *
FROM {{ source('raw_trakcare', 'QAUXXADVADCQQVADCPROGREF') }}

{% endsnapshot %}