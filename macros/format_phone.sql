{% macro format_phone(phone_no) %}
    CASE
        -- Strip to digits first for all comparisons
        WHEN REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '') = '' THEN NULL

        -- Mobile: 9 digits starting with 4 -> add leading 0
        WHEN LENGTH(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')) = 9
            AND LEFT(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', ''), 1) = '4'
            THEN '0' || REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')

        -- Sydney/NSW landline: 8 digits starting with 9 -> add 02
        WHEN LENGTH(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')) = 8
            AND LEFT(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', ''), 1) = '9'
            THEN '02' || REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')

        -- Melbourne/VIC landline: 8 digits starting with 8 -> add 03
        WHEN LENGTH(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')) = 8
            AND LEFT(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', ''), 1) = '8'
            THEN '03' || REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')

        -- Already has correct length (10 digits) -> pass through
        WHEN LENGTH(REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')) = 10
            THEN REGEXP_REPLACE({{ phone_no }}, '[^0-9]', '')

        -- Unrecognisable -> NULL
        ELSE NULL
    END
{% endmacro %}