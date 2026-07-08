{% snapshot HIST_TRAKCARE_PAC_REFERRALTYPE %}

{{
    config(
        schema='TRAKCARE',
        unique_key='REFT_ROWID',
        strategy='check',
        check_cols=[
            'REFT_CODE', 'REFT_DESC', 'REFT_NATIONALCODE',
            'REFT_REFERRALLENGTH', 'REFT_REFERRALPERIOD',
            'REFT_REFSTDATEAPPTDATE', 'REFT_OWNER', 'REFT_CODETABLETAGS',
            'REFT_SUBREGION_DR', 'REFT_DATEFROM', 'REFT_DATETO',
            'REFT_CREATEDDATE', 'REFT_CREATEDTIME', 'REFT_CREATEDUSER_DR',
            'REFT_UPDATEDDATE', 'REFT_UPDATEDTIME', 'REFT_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_trakcare', 'PAC_REFERRALTYPE') }}

{% endsnapshot %}