{% snapshot HIST_E_TOOLS_PROVIDER_STATEMENT %}

{{
    config(
        schema='E_TOOLS',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'NO_', 'SERVICE', 'FIRST_NAME', 'LAST_NAME', 'SUPPLEMENTS',
            'PKG_MGMT_COST', 'CARE_MGMT_COST', 'DISCHARGE_DATE',
            'CARE_RECIPIENT_ID', 'GOVERNMENT_SUBSIDY', 'TOTAL_AVAILABLE_FUNDS',
            'ALLOCATED_TO_CONTINGENCY', 'CONTINGENCY_BROUGHT_FORWARD',
            'CONTINGENCY_CARRIED_FORWARD', 'PROVIDER_SUBSIDISED_ITF_FEE',
            'CONSUMER_AND_ADDITIONAL_CONTRIBUTION',
            'UNALLOCATED_UNSPENT_FUNDS_BROUGHT_FORWARD',
            'UNALLOCATED_UNSPENT_FUNDS_CARRIED_FORWARD',
            'ONE_OFF_EMERGENCY_SERVICES_PURCHASES_FROM_CONTINGENCY',
            'ONE_OFF_EMERGENCY_SERVICES_PURCHASES_FROM_UNALLOCATED',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *
FROM {{ source('raw_e_tools', 'PROVIDER_STATEMENT') }}

{% endsnapshot %}