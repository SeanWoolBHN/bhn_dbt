{% macro format_name(column_name) %}
    INITCAP(
        TRIM(
            REGEXP_REPLACE(
                REGEXP_REPLACE(
                    REGEXP_REPLACE(
                        REGEXP_REPLACE(
                            REGEXP_REPLACE(
                                REGEXP_REPLACE(
                                {{ column_name }},
                                '([^A-Za-z \(\)\\-\'])+', '')
                            , ',', '')
                        , '/', '')
                    , '\\\\', '')
                , '\\|', '')
            , '\\s{2,}', ' ')
        )
    )
{% endmacro %}