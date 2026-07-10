{% snapshot HIST_TRAKCARE_RBC_EVENTSUBTYPE %}

{{
    config(
        schema='TRAKCARE',
        unique_key='SUB_ROWID',
        strategy='check',
        check_cols=[
            'SUB_PARREF', 'SUB_CHILDSUB', 'SUB_CODE', 'SUB_DESC',
            'SUB_DATEFROM', 'SUB_DATETO', 'SUB_CODETABLETAGS',
            'SUB_CREATEDDATE', 'SUB_CREATEDTIME', 'SUB_CREATEDUSER_DR',
            'SUB_UPDATEDDATE', 'SUB_UPDATEDTIME', 'SUB_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_trakcare', 'RBC_EVENTSUBTYPE') }}

{% endsnapshot %}