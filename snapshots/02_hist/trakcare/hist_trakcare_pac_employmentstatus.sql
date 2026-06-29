{% snapshot HIST_TRAKCARE_PAC_EMPLOYMENTSTATUS %}

{{
    config(
        schema='TRAKCARE',
        unique_key='EMPLST_ROWID',
        strategy='check',
        check_cols=[
            'EMPLST_CODE', 'EMPLST_DESC', 'EMPLST_DATEFROM', 'EMPLST_DATETO',
            'EMPLST_NATIONCODE', 'EMPLST_OWNER', 'EMPLST_CODETABLETAGS',
            'EMPLST_CREATEDDATE', 'EMPLST_CREATEDTIME', 'EMPLST_CREATEDUSER_DR',
            'EMPLST_UPDATEDDATE', 'EMPLST_UPDATEDTIME', 'EMPLST_UPDATEDUSER_DR',
            'EMPLST_CODETRANSLATED', 'EMPLST_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'PAC_EMPLOYMENTSTATUS') }}

{% endsnapshot %}