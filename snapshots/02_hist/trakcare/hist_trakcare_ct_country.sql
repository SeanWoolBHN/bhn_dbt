{% snapshot HIST_TRAKCARE_CT_COUNTRY %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TRAKCARE',
        unique_key='CTCOU_ROWID',
        strategy='check',
        check_cols=[
            'CTCOU_CODE',
            'CTCOU_DESC',
            'CTCOU_ACTIVE',
            'CTCOU_DATEACTIVEFROM',
            'CTCOU_DATEACTIVETO',
            'CTCOU_OWNER',
            'CTCOU_CODETABLETAGS',
            'CTCOU_CREATEDDATE',
            'CTCOU_CREATEDTIME',
            'CTCOU_CREATEDUSER_DR',
            'CTCOU_UPDATEDDATE',
            'CTCOU_UPDATEDTIME',
            'CTCOU_UPDATEDUSER_DR',
            'CTCOU_NATIONALCODE',
            'CTCOU_ISO3166CODE',
            'CTCOU_ISO3166ALPHA2CODE',
            'CTCOU_ISO3166ALPHA3CODE',
            'CTCOU_CODETRANSLATED',
            'CTCOU_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    CTCOU_ROWID,
    CTCOU_CODE,
    CTCOU_DESC,
    CTCOU_ACTIVE,
    CTCOU_DATEACTIVEFROM,
    CTCOU_DATEACTIVETO,
    CTCOU_OWNER,
    CTCOU_CODETABLETAGS,
    CTCOU_CREATEDDATE,
    CTCOU_CREATEDTIME,
    CTCOU_CREATEDUSER_DR,
    CTCOU_UPDATEDDATE,
    CTCOU_UPDATEDTIME,
    CTCOU_UPDATEDUSER_DR,
    CTCOU_NATIONALCODE,
    CTCOU_ISO3166CODE,
    CTCOU_ISO3166ALPHA2CODE,
    CTCOU_ISO3166ALPHA3CODE,
    CTCOU_CODETRANSLATED,
    CTCOU_DESCTRANSLATED,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_trakcare', 'CT_COUNTRY') }}

{% endsnapshot %}