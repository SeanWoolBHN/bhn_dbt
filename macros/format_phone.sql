{% macro format_phone(phone_no) %}
    CASE
        WHEN LENGTH(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')) = 9
            AND LEFT(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', ''), 1) = '4'
            THEN '0' || REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')
        WHEN LENGTH(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')) = 8
            AND LEFT(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', ''), 1) = '9'
            THEN '02' || REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')
        ELSE REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')
    END
{% endmacro %}