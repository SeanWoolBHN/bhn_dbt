{% snapshot HIST_TRAKCARE_RB_EVENT %}
{{
    config(
        unique_key='EV_ROWID',
        strategy='check',
        check_cols=[
            'EV_NUMBER', 'EV_STATUS', 'EV_NAME', 'EV_TYPE_DR',
            'EV_CLIENTTYPE', 'EV_METHODOFCONDUCT_DR', 'EV_ADMINISTRATOR_DR',
            'EV_DURATION', 'EV_VENUE', 'EV_MAXNUMBEROFPARTICIPANTS',
            'EV_CHARGE', 'EV_PREPARATIONTIME', 'EV_PREDICTEDTRAVELTIME',
            'EV_PREDICTEDREVIEWTIME', 'EV_RBRESOURCE_DR', 'EV_VENUEADDRESS1',
            'EV_VENUEADDRESS2', 'EV_VENUEPHONE', 'EV_VENUEFAX',
            'EV_CONSULTCATEGORY_DR', 'EV_CLIENTSOURCE_DR',
            'EV_CLIENTSOURCEDESC', 'EV_ATTENDEEFEMALENO', 'EV_ATTENDEEMALENO',
            'EV_EVENTSUBTYPE_DR', 'EV_CLIENTSOURCEORG_DR', 'EV_INSTYPE_DR',
            'EV_AUXINSTYPE_DR', 'EV_DATECREATED', 'EV_LOCATION_DR',
            'EV_HOSPITAL_DR', 'EV_ITEMCAT_DR', 'EV_CONTVENUE_DR',
            'EV_DATEFROM', 'EV_DATETO', 'EV_YESNO1', 'EV_YESNO2',
            'EV_YESNO3', 'EV_YESNO4', 'EV_NFMICATEGDEPART_DR'
        ],
        invalidate_hard_deletes=True,
        dbt_valid_to_current="to_date('9999-12-31')"
    )
}}
SELECT * FROM {{ source('raw_trakcare', 'RB_EVENT') }}
{% endsnapshot %}