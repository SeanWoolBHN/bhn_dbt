{% snapshot HIST_TRAKCARE_RBC_REASONFORCANCEL %}
{{
    config(
        schema='TRAKCARE',
        unique_key='RFC_ROWID',
        strategy='check',
        check_cols=[
            'RFC_CODE', 'RFC_DESC', 'RFC_INITIATOR', 'RFC_DATEFROM',
            'RFC_DATETO', 'RFC_DEFAULT', 'RFC_ADMCANCELREASON_DR',
            'RFC_REASONTOCHANGEOPWLTOREMOVED_DR', 'RFC_OPWLSTATUSTOREINSTATE_DR',
            'RFC_RESETTTGCLOCK', 'RFC_NATIONALCODE', 'RFC_OWNER',
            'RFC_CODETABLETAGS', 'RFC_REMOVECONTACTREMINDERDATES',
            'RFC_CREATEDDATE', 'RFC_CREATEDTIME', 'RFC_CREATEDUSER_DR',
            'RFC_UPDATEDDATE', 'RFC_UPDATEDTIME', 'RFC_UPDATEDUSER_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'RBC_REASONFORCANCEL') }}
{% endsnapshot %}