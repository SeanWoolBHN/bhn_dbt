{% snapshot HIST_TRAKCARE_PAC_NATIONALCODES %}
{{
    config(
        schema='TRAKCARE',
        unique_key='NATC_ROWID',
        strategy='check',
        check_cols=[
            'NATC_DATEFROM', 'NATC_DATETO', 'NATC_TABLE_DR', 'NATC_TABLENAME',
            'NATC_TABLEFIELD_DR', 'NATC_FIELDNAME', 'NATC_ACTUALVALUE',
            'NATC_MAPPEDVALUE', 'NATC_REPORTINGTYPE_DR', 'NATC_NODISPLAYONWEB',
            'NATC_OWNER', 'NATC_CODETABLETAGS', 'NATC_CREATEDDATE',
            'NATC_CREATEDTIME', 'NATC_CREATEDUSER_DR', 'NATC_UPDATEDDATE',
            'NATC_UPDATEDTIME', 'NATC_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'PAC_NATIONALCODES') }}
{% endsnapshot %}