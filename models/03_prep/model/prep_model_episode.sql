SELECT 
    {{ dbt_utils.star(ref('prep_src_episode_trakcare')) }}
FROM {{ ref('prep_src_episode_trakcare') }}