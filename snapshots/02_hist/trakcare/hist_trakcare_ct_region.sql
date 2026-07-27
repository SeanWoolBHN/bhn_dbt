{% snapshot HIST_TRAKCARE_CT_REGION %}

{{
    config(
        unique_key='CTRG_ROWID',
        strategy='check',
        check_cols=[
            'CTRG_CODE', 'CTRG_DESC', 'CTRG_RCFLAG', 'CTRG_COUNTRY_DR',
            'CTRG_OWNER', 'CTRG_CODETABLETAGS', 'CTRG_CREATEDDATE',
            'CTRG_CREATEDTIME', 'CTRG_CREATEDUSER_DR', 'CTRG_UPDATEDDATE',
            'CTRG_UPDATEDTIME', 'CTRG_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'CT_REGION') }}

{% endsnapshot %}