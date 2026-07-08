{% snapshot HIST_TRAKCARE_RBC_SERVICES %}
{{
    config(
        schema='TRAKCARE',
        unique_key='SER_ROWID',
        strategy='check',
        check_cols=[
            'SER_ARCIM_DR', 'SER_ARCOS_DR', 'SER_NOOFSLOTS', 'SER_CTCP_DR',
            'SER_EQUIP_DR', 'SER_DESC', 'SER_CTLOC_DR', 'SER_MINUTES',
            'SER_SERVGROUP_DR', 'SER_ACTIVE', 'SER_SUBCATEGORYDR',
            'SER_DATEFROM', 'SER_DATETO', 'SER_1STAPPT',
            'SER_PROJECTEDWEEKSWAIT', 'SER_AVERAGEWEEKSPYEAR',
            'SER_FIRSTAVAILABLE', 'SER_EXTRACONTACTPATIENTSPERC', 'SER_PFB',
            'SER_CALCPROJECTEDWAIT', 'SER_NEWWAYS', 'SER_DRESSTIME',
            'SER_CREATEDDATE', 'SER_CREATEDTIME', 'SER_CREATEDUSER_DR',
            'SER_UPDATEDDATE', 'SER_UPDATEDTIME', 'SER_UPDATEDUSER_DR',
            'SER_DESCTRANSLATED', 'SER_ROWIDTRANSLATED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'RBC_SERVICES') }}
{% endsnapshot %}