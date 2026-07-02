{#-
	This generates the target database name based on the target dbt is running against
	eg. dbt run --target dev will create objects under DEV_<DATABASE_NAME>_DB
-#}

{% macro generate_database_name(custom_database_name=none, node=none) -%}
    {%- set default_database = target.database -%}
    {%- if custom_database_name is none -%}

        {{ default_database }}

    {%- else -%}

			{{ target.name | upper }}_{{ custom_database_name }}

    {%- endif -%}
{%- endmacro %}
