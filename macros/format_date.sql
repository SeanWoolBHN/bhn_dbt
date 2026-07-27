{% macro format_date(input_date) %}
    COALESCE(
        TRY_TO_DATE({{ input_date }}, 'DD/MM/YYYY'),
        TRY_TO_DATE({{ input_date }}, 'MM/DD/YYYY'),
        TRY_TO_DATE({{ input_date }}, 'YYYY-MM-DD'),
        TRY_TO_DATE({{ input_date }}, 'DD-MON-YY'),
        TRY_TO_DATE({{ input_date }}, 'DD-MON-YYYY'),
        TRY_TO_DATE({{ input_date }}, 'YYYY/MM/DD'),
        TRY_TO_DATE({{ input_date }}, 'DD.MM.YYYY'),
        TRY_TO_DATE({{ input_date }})
    )
{% endmacro %}