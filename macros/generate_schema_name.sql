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

    {{ log("DEBUG generate_schema_name -> node: " ~ node.name ~ " | custom_schema_name: " ~ custom_schema_name ~ " | target.name: " ~ target.name ~ " | resource_type: " ~ node.resource_type ~ " | default_schema: " ~ default_schema, info=True) }}

    {%- if node.resource_type == 'snapshot' -%}
        {#- Snapshots: always unified, never prefixed, regardless of target -#}
        {%- if custom_schema_name is none -%}
            {{ log("DEBUG -> taking SNAPSHOT branch, custom_schema_name is None, returning default_schema: " ~ default_schema, info=True) }}
            {{ default_schema }}
        {%- else -%}
            {{ log("DEBUG -> taking SNAPSHOT branch, returning custom_schema_name: " ~ custom_schema_name, info=True) }}
            {{ custom_schema_name | trim }}
        {%- endif -%}

    {%- else -%}
        {#- Models/seeds/etc: per-developer split in dev, clean in PROD/TEST -#}
        {%- if custom_schema_name is none -%}
            {{ log("DEBUG -> taking MODEL branch, custom_schema_name is None, returning default_schema: " ~ default_schema, info=True) }}
            {{ default_schema }}
        {%- elif target.name == 'PROD' -%}
            {{ log("DEBUG -> taking MODEL branch, PROD target, returning custom_schema_name: " ~ custom_schema_name, info=True) }}
            {{ custom_schema_name | trim }}
        {%- elif target.name == 'TEST' -%}
            {{ log("DEBUG -> taking MODEL branch, TEST target, returning custom_schema_name: " ~ custom_schema_name, info=True) }}
            {{ custom_schema_name | trim }}
        {%- else -%}
            {{ log("DEBUG -> taking MODEL branch, dev target, returning prefixed: " ~ (default_schema | upper) ~ "_" ~ (custom_schema_name | trim), info=True) }}
            {{ default_schema | upper }}_{{ custom_schema_name | trim }}
        {%- endif -%}
    {%- endif -%}
{%- endmacro %}