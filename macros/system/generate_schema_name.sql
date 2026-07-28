{#-
    Schema naming rules:
    - Snapshots always resolve to a single, unified schema regardless of
      who is running dbt or what target they're on. This keeps HIST
      consistent across all developers and environments.
    - Models (and everything else) get the per-developer prefix in
      non-PROD/TEST targets, to avoid devs clashing with each other.
-#}
{% macro generate_schema_name(custom_schema_name, node) -%}
    {%- set default_schema = target.schema -%}

    {% if node.config.materialized == "snapshot" %}
        {#- Snapshots: always unified, never prefixed, regardless of target -#}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- else -%}
            {{ custom_schema_name | trim }}
        {%- endif -%}

    {%- else -%}
        {#- Models/seeds/etc: per-developer split in dev, clean in PROD/TEST -#}
        {%- if custom_schema_name is none -%}
            {{ default_schema }}
        {%- elif target.name == 'PROD' -%}
            {{ custom_schema_name | trim }}
        {%- elif target.name == 'DEV_DEP' -%}
            {{ custom_schema_name | trim }}
        {%- else -%}
            {{ default_schema | upper }}_{{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}
{%- endmacro %}