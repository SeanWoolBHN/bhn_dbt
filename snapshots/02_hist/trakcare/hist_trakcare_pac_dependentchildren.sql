{% snapshot HIST_TRAKCARE_PAC_DEPENDENTCHILDREN %}

{{
    config(
        schema='TRAKCARE',
        unique_key='DEPCHL_ROWID',
        strategy='check',
        check_cols=[
            'DEPCHL_CODE', 'DEPCHL_DESC', 'DEPCHL_DATEFROM', 'DEPCHL_DATETO',
            'DEPCHL_OWNER', 'DEPCHL_CODETABLETAGS', 'DEPCHL_CREATEDDATE',
            'DEPCHL_CREATEDTIME', 'DEPCHL_CREATEDUSER_DR', 'DEPCHL_UPDATEDDATE',
            'DEPCHL_UPDATEDTIME', 'DEPCHL_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'PAC_DEPENDENTCHILDREN') }}

{% endsnapshot %}