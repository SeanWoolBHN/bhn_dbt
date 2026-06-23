{% snapshot HIST_TRAKCARE_PAC_SOURCEOFINCOME %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='SRCINC_ROWID',
        strategy='check',
        check_cols=[
            'SRCINC_CODE', 'SRCINC_DESC', 'SRCINC_DATEFROM', 'SRCINC_DATETO',
            'SRCINC_NATIONCODE', 'SRCINC_NATIONCODEDESC', 'SRCINC_OWNER',
            'SRCINC_CODETABLETAGS', 'SRCINC_CREATEDDATE', 'SRCINC_CREATEDTIME',
            'SRCINC_CREATEDUSER_DR', 'SRCINC_UPDATEDDATE', 'SRCINC_UPDATEDTIME',
            'SRCINC_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'PAC_SOURCEOFINCOME') }}

{% endsnapshot %}