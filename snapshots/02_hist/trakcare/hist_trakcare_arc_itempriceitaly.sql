{% snapshot HIST_TRAKCARE_ARC_ITEMPRICEITALY %}
{{
    config(
        unique_key='ITP_ROWID',
        strategy='check',
        check_cols=[
            'ITP_RANK', 'ITP_DAYTO', 'ITP_PRICE', 'ITP_DATETO', 'ITP_PARREF',
            'ITP_UOM_DR', 'ITP_DAYFROM', 'ITP_BASEUNIT', 'ITP_CHILDSUB',
            'ITP_DATEFROM', 'ITP_PAYORAMT', 'ITP_TARIFF_DR', 'ITP_URGENTFEE',
            'ITP_ACCOUTCODE', 'ITP_BEDTYPE_DR', 'ITP_COUNTRY_DR', 'ITP_EXCLUDEVAT',
            'ITP_HOSPITALDR', 'ITP_INSTYPE_DR', 'ITP_PAYORSHARE', 'ITP_CAREPROV_DR',
            'ITP_CREATEDDATE', 'ITP_CREATEDTIME', 'ITP_CURRENCY_DR', 'ITP_EPISBILL_DR',
            'ITP_EPISODETYPE', 'ITP_LOCATION_DR', 'ITP_ROOMTYPE_DR', 'ITP_UPDATEDDATE',
            'ITP_UPDATEDTIME', 'ITP_OPERCATEG_DR', 'ITP_CODETABLETAGS',
            'ITP_PAYORGROUP_DR', 'ITP_POSTOFFICE_DR', 'ITP_SPECIALITY_DR',
            'ITP_URGENTFEERATE', 'ITP_CREATEDUSER_DR', 'ITP_EPISSUBTYPE_DR',
            'ITP_UPDATEDUSER_DR', 'ITP_EXTERNALCAREPROV', 'ITP_NATIONALITYGROUP_DR',
            'ITP_MAINORDERTARIFFPRICE'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'ARC_ITEMPRICEITALY') }}
{% endsnapshot %}