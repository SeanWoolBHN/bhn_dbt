{% snapshot HIST_TRAKCARE_OE_ORDER %}
{{ config(unique_key='OEORD_ROWID', strategy='check',
    check_cols=['OEORD_DATE','OEORD_TIME','OEORD_ADM_DR','OEORD_ROWID1',
        'OEORD_ARCOP_DR','OEORD_OEOTC_DR','OEORD_DOCTOR_DR',
        'OEORD_SUNDRYDEBTOR_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'OE_ORDER') }}
{% endsnapshot %}