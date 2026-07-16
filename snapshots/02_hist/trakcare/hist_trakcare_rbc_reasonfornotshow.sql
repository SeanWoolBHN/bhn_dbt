{% snapshot HIST_TRAKCARE_RBC_REASONFORNOTSHOW %}
{{
    config(
        unique_key='RNS_ROWID',
        strategy='check',
        check_cols=[
            'RNS_CODE', 'RNS_DESC', 'RNS_DATEFROM', 'RNS_DATETO',
            'RNS_DEFAULTDNAREASON', 'RNS_REASONTOCHANGEOPWLTOREMOVED_DR',
            'RNS_OPWLSTATUSTOREINSTATE_DR', 'RNS_INCLINNUMDNA',
            'RNS_RESETTTGCLOCK', 'RNS_NATIONALCODE', 'RNS_OWNER',
            'RNS_CODETABLETAGS', 'RNS_REMOVECONTACTREMINDERDATES',
            'RNS_CREATEDDATE', 'RNS_CREATEDTIME', 'RNS_CREATEDUSER_DR',
            'RNS_UPDATEDDATE', 'RNS_UPDATEDTIME', 'RNS_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'RBC_REASONFORNOTSHOW') }}
{% endsnapshot %}