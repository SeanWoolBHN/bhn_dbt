{% snapshot HIST_TRAKCARE_PAC_CONTVENUE %}
{{
    config(
        unique_key='CONTVENUE_ROWID',
        strategy='check',
        check_cols=[
            'CONTVENUE_CODE', 'CONTVENUE_DESC', 'CONTVENUE_OWNER',
            'CONTVENUE_DATETO', 'CONTVENUE_DATEFROM', 'CONTVENUE_CREATEDDATE',
            'CONTVENUE_CREATEDTIME', 'CONTVENUE_UPDATEDDATE', 'CONTVENUE_UPDATEDTIME',
            'CONTVENUE_CODETABLETAGS', 'CONTVENUE_CREATEDUSER_DR',
            'CONTVENUE_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'PAC_CONTVENUE') }}
{% endsnapshot %}