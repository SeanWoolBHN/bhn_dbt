{% snapshot HIST_CONNX_EMPLOYEE_DATA %}

{{
    config(
        schema = 'CONNX',
        unique_key='_AIRBYTE_RAW_ID',
        strategy='check',
        check_cols=[
            'SURNAME', 'DATE_HIRED', 'DEPARTMENT', 'FIRST_NAME',
            'EMPLOYEE_NO', 'MIDDLE_NAME', 'RDO_APPROVED', 'WORK_PATTERN',
            'CONTRACT_HOURS', 'PREFERRED_NAME', 'EMPLOYMENT_TYPE',
            'CURRENT_POSITION', 'TERMINATION_DATE', 'PROBATION_END_DATE',
            'TIL_LEAVE_APPROVED', 'WORK_EMAIL_ADDRESS', 'FIXED_TERM_END_DATE',
            'RDO_BALANCE_ACCRUED', 'REPORTS_TO_POSITION_',
            'ANNUAL_LEAVE_APPROVED', 'FIXED_TERM_START_DATE',
            'PERSONAL_LEAVE_APPROVED', 'POSITION_ALLOCATED_HOURS',
            'REPORTS_TO_MANAGER_NAME_', 'TIL_LEAVE_BALANCE_ACCRUED',
            'ANNUAL_LEAVE_BALANCE_ACCRUED', 'PERSONAL_LEAVE_BALANCE_ACCRUED',
            'TERMINATION_REASON_FOR_LEAVING',
            'USED_DEFINED_PURCHASED_LEAVE_ACCRUED',
            'USER_DEFINED_PURCHASED_LEAVE_APPROVED',
            '_AB_SOURCE_FILE_URL', '_AB_SOURCE_FILE_LAST_MODIFIED'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

SELECT
    *

FROM {{ source('raw_connx', 'EMPLOYEE_DATA') }}

{% endsnapshot %}