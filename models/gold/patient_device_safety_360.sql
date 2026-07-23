-- Gold: 360-degree patient-device-safety view
-- Primary model for the dbt Semantic Layer
select
    p.PATIENT_ID,
    p.ENROLLING_SITE,
    p.DIAGNOSIS,
    p.ENROLLMENT_DATE,

    t.TRIAL_ID,
    t.TRIAL_NAME,
    t.PHASE                                as TRIAL_PHASE,
    t.STATUS                               as TRIAL_STATUS,
    t.INDICATION,
    t.PRIMARY_ENDPOINT,

    ae.AE_ID,
    ae.EVENT_DATE,
    ae.SEVERITY,
    ae.AE_DESCRIPTION,
    ae.SUBMITTED_TO_FDA,
    ae.RESOLVED,
    ae.SEVERITY_RANK,

    dr.DEVICE_MODEL,
    dr.MANUFACTURE_DATE                    as DEVICE_MANUFACTURE_DATE,
    dr.FACILITY_CODE                       as MFG_FACILITY,
    dr.STATUS                              as LOT_STATUS,

    case
        when ae.SEVERITY = 'HIGH'  and not ae.RESOLVED       then 'OPEN_HIGH'
        when ae.SEVERITY = 'HIGH'  and ae.RESOLVED            then 'CLOSED_HIGH'
        when dr.STATUS in ('RECALL', 'QUARANTINE')            then 'AFFECTED_LOT'
        else 'STANDARD'
    end                                    as SAFETY_RISK_FLAG,

    datediff('day', ae.EVENT_DATE, current_date()) as DAYS_SINCE_EVENT,
    current_timestamp()                    as LAST_REFRESHED_AT

from {{ source('clinical', 'patients') }} p
join {{ ref('stg_adverse_events') }} ae
    on p.PATIENT_ID = ae.PATIENT_ID
join {{ source('clinical', 'clinical_trials') }} t
    on p.TRIAL_ID = t.TRIAL_ID
join {{ source('device', 'device_registry') }} dr
    on ae.DEVICE_LOT_ID = dr.LOT_ID
