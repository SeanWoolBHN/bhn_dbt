{% snapshot HIST_TRAKCARE_QAUXXADOUTQQVADCOUTDOC %}
{{
    config(
        schema='TRAKCARE',
        unique_key='VADC_OUT_DOC_KEY',
        strategy='check',
        check_cols=[
            'ID', 'CHILDSUB', 'QUESPARREFDR', 'QVADCOUTDOCQ1',
            'QVADCOUTDOCQ2', 'QVADCOUTDOCQ3', 'QVADCOUTDOCQ4',
            'QVADCOUTDOCQ5', 'QVADCOUTDOCQ6', 'QVADCOUTDOCQ7'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    MD5(
        COALESCE(ID, 'null') || '|' ||
        COALESCE(CHILDSUB::VARCHAR, 'null')
    )                                                   AS VADC_OUT_DOC_KEY,
    *
FROM {{ source('raw_trakcare', 'QAUXXADOUTQQVADCOUTDOC') }}

{% endsnapshot %}