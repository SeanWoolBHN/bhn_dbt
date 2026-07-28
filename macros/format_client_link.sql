{% macro format_client_link(column_name) %}
    REGEXP_REPLACE(
        UPPER({{ column_name }}),
        '[\\s\\-/\\\\,\\)\\(\\*:;_#~!%\\^"]',
        ''
    )
{% endmacro %}