SELECT 
    {{ dbt_utils.star(ref('prep_src_appointment_trakcare')) }}
FROM {{ ref('prep_src_appointment_trakcare') }}