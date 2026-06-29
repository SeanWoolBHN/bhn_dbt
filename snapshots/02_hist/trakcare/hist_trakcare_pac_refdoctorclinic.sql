{% snapshot HIST_TRAKCARE_PAC_REFDOCTORCLINIC %}

{{
    config(
        schema='TRAKCARE',
        unique_key='CLN_KEY',
        strategy='check',
        check_cols=[
            'CLN_PARREF', 'CLN_ROWID', 'CLN_CHILDSUB', 'CLN_CODE',
            'CLN_ADDRESS1', 'CLN_ADDRESS2', 'CLN_CITY_DR', 'CLN_ZIP_DR',
            'CLN_PHONE', 'CLN_PROVIDERNO', 'CLN_BUSPHONE', 'CLN_MOBPHONE',
            'CLN_FAX', 'CLN_EMAIL', 'CLN_PREFERREDCONTACT', 'CLN_VEMD',
            'CLN_DATEFROM', 'CLN_DATETO', 'CLN_CLINIC_DR', 'CLN_ALIAS',
            'CLN_LOCATION', 'CLN_SYSTEM', 'CLN_DEFAULTSEND',
            'CLN_CREATEDDATE', 'CLN_CREATEDTIME', 'CLN_CREATEDUSER_DR',
            'CLN_UPDATEDDATE', 'CLN_UPDATEDTIME', 'CLN_UPDATEDUSER_DR',
            'CLN_CONFIDENTIALFAX', 'CLN_TEXT1', 'CLN_TEXT2'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}

WITH source AS (
    SELECT
        CLN_PARREF,
        CLN_ROWID,
        CLN_CHILDSUB,
        CLN_CODE,
        CLN_ADDRESS1,
        CLN_ADDRESS2,
        CLN_CITY_DR,
        CLN_ZIP_DR,
        CLN_PHONE,
        CLN_PROVIDERNO,
        CLN_BUSPHONE,
        CLN_MOBPHONE,
        CLN_FAX,
        CLN_EMAIL,
        CLN_PREFERREDCONTACT,
        CLN_VEMD,
        CLN_DATEFROM,
        CLN_DATETO,
        CLN_CLINIC_DR,
        CLN_ALIAS,
        CLN_LOCATION,
        CLN_SYSTEM,
        CLN_DEFAULTSEND,
        CLN_CREATEDDATE,
        CLN_CREATEDTIME,
        CLN_CREATEDUSER_DR,
        CLN_UPDATEDDATE,
        CLN_UPDATEDTIME,
        CLN_UPDATEDUSER_DR,
        CLN_CONFIDENTIALFAX,
        CLN_TEXT1,
        CLN_TEXT2,
        ROW_NUMBER() OVER (
            PARTITION BY
                COALESCE(CLN_PARREF, 'unknown'),
                COALESCE(CLN_CHILDSUB, 'unknown')
            ORDER BY CLN_CREATEDDATE
        ) AS row_num
    FROM {{ source('raw_trakcare', 'PAC_REFDOCTORCLINIC') }}
)

SELECT
    MD5(
        COALESCE(CLN_PARREF, 'unknown')    || '-' ||
        COALESCE(CLN_CHILDSUB, 'unknown')  || '-' ||
        COALESCE(CLN_ROWID, 'unknown')     || '-' ||
        CAST(row_num AS VARCHAR)
    )                                       AS CLN_KEY,
    CLN_PARREF, CLN_ROWID, CLN_CHILDSUB, CLN_CODE, CLN_ADDRESS1,
    CLN_ADDRESS2, CLN_CITY_DR, CLN_ZIP_DR, CLN_PHONE, CLN_PROVIDERNO,
    CLN_BUSPHONE, CLN_MOBPHONE, CLN_FAX, CLN_EMAIL, CLN_PREFERREDCONTACT,
    CLN_VEMD, CLN_DATEFROM, CLN_DATETO, CLN_CLINIC_DR, CLN_ALIAS,
    CLN_LOCATION, CLN_SYSTEM, CLN_DEFAULTSEND, CLN_CREATEDDATE,
    CLN_CREATEDTIME, CLN_CREATEDUSER_DR, CLN_UPDATEDDATE, CLN_UPDATEDTIME,
    CLN_UPDATEDUSER_DR, CLN_CONFIDENTIALFAX, CLN_TEXT1, CLN_TEXT2

FROM source

{% endsnapshot %}