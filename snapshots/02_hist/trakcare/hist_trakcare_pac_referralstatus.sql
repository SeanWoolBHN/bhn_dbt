{% snapshot HIST_TRAKCARE_PAC_REFERRALSTATUS %}
{{ config(unique_key='RST_ROWID', strategy='check',
    check_cols=['RST_CODE','RST_DESC','RST_OWNER','RST_DATETO','RST_DATEFROM',
        'RST_ICANNAME','RST_CREATEDDATE','RST_CREATEDTIME','RST_UPDATEDDATE',
        'RST_UPDATEDTIME','RST_VISITSTATUS','RST_ICONPRIORITY','RST_NATIONALCODE',
        'RST_CODETABLETAGS','RST_CREATEDUSER_DR','RST_UPDATEDUSER_DR'],
    invalidate_hard_deletes=True, dbt_valid_to_current="to_date('9999-12-31')") }}
SELECT * FROM {{ source('raw_trakcare', 'PAC_REFERRALSTATUS') }}
{% endsnapshot %}