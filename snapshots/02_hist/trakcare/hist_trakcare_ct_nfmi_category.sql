{% snapshot HIST_TRAKCARE_CT_NFMI_CATEGORY %}
{{
    config(
        unique_key='NFMI_ROWID',
        strategy='check',
        check_cols=[
            'NFMI_CODE', 'NFMI_DESC', 'NFMI_OWNER', 'NFMI_DATETO',
            'NFMI_DATEFROM', 'NFMI_CREATEDDATE', 'NFMI_CREATEDTIME',
            'NFMI_LINKNFMI_DR', 'NFMI_UPDATEDDATE', 'NFMI_UPDATEDTIME',
            'NFMI_INSBATCHONLY', 'NFMI_CODETABLETAGS', 'NFMI_CREATEDUSER_DR',
            'NFMI_GOVSUBCATEG_DR', 'NFMI_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'CT_NFMI_CATEGORY') }}
{% endsnapshot %}