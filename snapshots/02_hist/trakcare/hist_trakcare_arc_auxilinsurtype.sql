{% snapshot HIST_TRAKCARE_ARC_AUXILINSURTYPE %}

{{
    config(
        schema='TRAKCARE',
        unique_key='AUXIT_ROWID',
        strategy='check',
        check_cols=[
            'AUXIT_CODE', 'AUXIT_DESC', 'AUXIT_CODE1', 'AUXIT_CODE2',
            'AUXIT_OWNER', 'AUXIT_DATETO', 'AUXIT_CATEGORY',
            'AUXIT_DATEFROM', 'AUXIT_PRIORITY', 'AUXIT_INSTYPE_DR',
            'AUXIT_PLANGROUP1', 'AUXIT_PLANGROUP2', 'AUXIT_PLANGROUP3',
            'AUXIT_PLANGROUP4', 'AUXIT_PLANGROUP5', 'AUXIT_PLANGROUP6',
            'AUXIT_CREATEDDATE', 'AUXIT_CREATEDTIME', 'AUXIT_UPDATEDDATE',
            'AUXIT_UPDATEDTIME', 'AUXIT_NATIONALCODE', 'AUXIT_SUBREGION_DR',
            'AUXIT_CODETABLETAGS', 'AUXIT_CODETRANSLATED',
            'AUXIT_CREATEDUSER_DR', 'AUXIT_DESCTRANSLATED',
            'AUXIT_UPDATEDUSER_DR', 'AUXIT_GENSEPARATEBATCH',
            'AUXIT_EXCLFROMBATCHINVOICE', 'AUXIT_QUALIFICATIONSTATUSDR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_trakcare', 'ARC_AUXILINSURTYPE') }}

{% endsnapshot %}