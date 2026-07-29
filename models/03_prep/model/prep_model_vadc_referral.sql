SELECT 
    {{ dbt_utils.star(ref('prep_src_vadc_referral_trakcare')) }}
FROM {{ ref('prep_src_vadc_referral_trakcare') }}