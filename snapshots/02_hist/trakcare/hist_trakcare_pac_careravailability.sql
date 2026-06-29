{% snapshot HIST_TRAKCARE_PAC_CARERAVAILABILITY %}

{{
    config(
        schema='TRAKCARE',
        unique_key='CARAVL_ROWID',
        strategy='check',
        check_cols=[
            'CARAVL_CODE', 'CARAVL_DESC', 'CARAVL_DATEFROM', 'CARAVL_DATETO',
            'CARAVL_DEFAULT', 'CARAVL_NATIONALCODE', 'CARAVL_DISCHARGETYPE',
            'CARAVL_CARETYP', 'CARAVL_OWNER', 'CARAVL_CODETABLETAGS',
            'CARAVL_CREATEDDATE', 'CARAVL_CREATEDTIME', 'CARAVL_CREATEDUSER_DR',
            'CARAVL_UPDATEDDATE', 'CARAVL_UPDATEDTIME', 'CARAVL_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'PAC_CARERAVAILABILITY') }}

{% endsnapshot %}