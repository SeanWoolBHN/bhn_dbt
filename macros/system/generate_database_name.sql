{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}
    {%- if custom_database_name is none -%}
        {{ default_database }}
    {%- else -%}
        {%- set env_prefix = target.name | upper -%}
        {%- if env_prefix == 'DEFAULT' -%}
            DEV_{{ custom_database_name }}
        {%- else -%}
            {{ env_prefix }}_{{ custom_database_name }}
        {%- endif -%}
    {%- endif -%}
{%- endmacro %}