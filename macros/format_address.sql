{% macro format_address(column_name) %}
    CASE
        WHEN UPPER(TRIM({{ column_name }})) LIKE 'PO BOX%'
          OR UPPER(TRIM({{ column_name }})) LIKE 'P.O. BOX%'
          OR UPPER(TRIM({{ column_name }})) LIKE 'GPO BOX%'
            THEN INITCAP(TRIM({{ column_name }}))

        ELSE
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            REGEXP_REPLACE(
            INITCAP(TRIM({{ column_name }}))
            , '\\s{2,}', ' ')
            , '\\s*/\\s*', '/')
            , 'C/-', '')
            , '\\.\\s', ' ')
            , '\\.$', '')
            , '\\bStreet\\b', 'St')
            , '\\bRoad\\b', 'Rd')
            , '\\bAvenue\\b', 'Ave')
            , '\\bCrescent\\b', 'Cres')
            , '\\bBoulevard\\b', 'Blvd')
            , '\\bDrive\\b', 'Dr')
            , '\\bCourt\\b', 'Ct')
            , '\\bPlace\\b', 'Pl')
            , '\\bTerrace\\b', 'Tce')
            , '\\bParade\\b', 'Pde')
            , '\\bCircuit\\b', 'Cct')
            , '\\bClose\\b', 'Cl')
            , '\\bGrove\\b', 'Gr')
            , '\\bLane\\b', 'La')
    END
{% endmacro %}