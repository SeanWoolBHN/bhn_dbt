{% snapshot HIST_TRAKCARE_CT_RELIGION %}

{{
    config(
        unique_key='CTRLG_ROWID',
        strategy='check',
        check_cols=[
            'CTRLG_CODE', 'CTRLG_DESC', 'CTRLG_DATEFROM', 'CTRLG_DATETO',
            'CTRLG_OWNER', 'CTRLG_CODETABLETAGS', 'CTRLG_CREATEDDATE',
            'CTRLG_CREATEDTIME', 'CTRLG_CREATEDUSER_DR', 'CTRLG_UPDATEDDATE',
            'CTRLG_UPDATEDTIME', 'CTRLG_UPDATEDUSER_DR',
            'CTRLG_CODETRANSLATED', 'CTRLG_DESCTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_trakcare', 'CT_RELIGION') }}

{% endsnapshot %}