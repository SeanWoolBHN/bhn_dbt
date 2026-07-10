{% snapshot HIST_TRAKCARE_CT_NFMI_CATEGDEPART %}
{{
    config(
        schema='TRAKCARE',
        unique_key='DEP_ROWID',
        strategy='check',
        check_cols=[
            'DEP_CODE', 'DEP_DESC', 'DEP_DATETO', 'DEP_PARREF',
            'DEP_CHILDSUB', 'DEP_DATEFROM', 'DEP_PRIORITY',
            'DEP_CREATEDDATE', 'DEP_CREATEDTIME', 'DEP_UPDATEDDATE',
            'DEP_UPDATEDTIME', 'DEP_CODETABLETAGS', 'DEP_CREATEDUSER_DR',
            'DEP_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'CT_NFMI_CATEGDEPART') }}
{% endsnapshot %}