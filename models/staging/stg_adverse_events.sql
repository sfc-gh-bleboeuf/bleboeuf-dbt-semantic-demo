-- Staging model: flatten and clean clinical adverse events
select
    AE_ID,
    PATIENT_ID,
    DEVICE_LOT_ID,
    EVENT_DATE,
    SEVERITY,
    DESCRIPTION          as AE_DESCRIPTION,
    SUBMITTED_TO_FDA,
    INVESTIGATOR_ID,
    RESOLVED,
    case
        when SEVERITY = 'HIGH'   then 3
        when SEVERITY = 'MEDIUM' then 2
        when SEVERITY = 'LOW'    then 1
        else 0
    end                  as SEVERITY_RANK
from {{ source('clinical', 'adverse_events') }}
