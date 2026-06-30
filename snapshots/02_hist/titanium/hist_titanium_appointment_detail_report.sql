{% snapshot HIST_TITANIUM_APPOINTMENT_DETAIL_REPORT %}

{{
    config(
        schema = 'TITANIUM',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'DR_',
            'ROOM',
            'EMAIL',
            'PHONE',
            'CLINIC',
            'SERVICE',
            'CATEGORY',
            'DURATION',
            'LASTNAME',
            'CREATEDBY',
            'FIRSTNAME',
            'TEXTBOX81',
            'AGENCYNAME',
            'APPTSTATUS',
            'CANCELREASON',
            'LASTEDITDATE',
            'LASTEDITEDBY',
            'PROVIDERCODE',
            'APPOINTMENTDATE',
            'APPOINTMENTTIME',
            'INDIGENOUSSTATUS',
            '_AB_SOURCE_FILE_URL',
            '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
*
FROM {{ source('raw_titanium', 'APPOINTMENT_DETAIL_REPORT') }}

{% endsnapshot %}