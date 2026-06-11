{% snapshot HIST_TITANIUM_APPOINTMENT_DETAIL_REPORT %}

{{
    config(
        target_database='DEV_02_HIST_DB',
        target_schema='TITANIUM',
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
    _AIRBYTE_RAW_ID,
    _AIRBYTE_EXTRACTED_AT,
    _AIRBYTE_META,
    _AIRBYTE_GENERATION_ID,
    DR_,
    ROOM,
    EMAIL,
    PHONE,
    CLINIC,
    SERVICE,
    CATEGORY,
    DURATION,
    LASTNAME,
    CREATEDBY,
    FIRSTNAME,
    TEXTBOX81,
    AGENCYNAME,
    APPTSTATUS,
    CANCELREASON,
    LASTEDITDATE,
    LASTEDITEDBY,
    PROVIDERCODE,
    APPOINTMENTDATE,
    APPOINTMENTTIME,
    INDIGENOUSSTATUS,
    _AB_SOURCE_FILE_URL,
    _AB_SOURCE_FILE_LAST_MODIFIED,
    CURRENT_TIMESTAMP() AS _stg_loaded_at

FROM {{ source('raw_titanium', 'APPOINTMENT_DETAIL_REPORT') }}

{% endsnapshot %}