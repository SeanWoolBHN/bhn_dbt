{% snapshot HIST_TRAKCARE_PAC_SOURCEOFATTENDANCE %}
{{
    config(
        unique_key='ATTEND_ROWID',
        strategy='check',
        check_cols=[
            'ATTEND_CODE', 'ATTEND_DESC', 'ATTEND_DATEFROM', 'ATTEND_DATETO',
            'ATTEND_STATISTICINDICATOR', 'ATTEND_NATIONALCODE',
            'ATTEND_EPISODETYPE', 'ATTEND_REFTYPE', 'ATTEND_MANDATORYREFDOCTOR',
            'ATTEND_MANDATORYREFHOSPITAL', 'ATTEND_BOOKPASTGD',
            'ATTEND_BOOKPASTGDTYPE', 'ATTEND_OWNER', 'ATTEND_CODETABLETAGS',
            'ATTEND_CREATEDDATE', 'ATTEND_CREATEDTIME', 'ATTEND_CREATEDUSER_DR',
            'ATTEND_UPDATEDDATE', 'ATTEND_UPDATEDTIME', 'ATTEND_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'PAC_SOURCEOFATTENDANCE') }}
{% endsnapshot %}