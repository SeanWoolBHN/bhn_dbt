SELECT 
    {{ dbt_utils.star(ref('prep_src_contact_trakcare')) }}
FROM {{ ref('prep_src_contact_trakcare') }}