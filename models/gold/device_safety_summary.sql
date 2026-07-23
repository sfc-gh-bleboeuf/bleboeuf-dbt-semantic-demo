-- Gold: Device lot safety rollup
select
    dr.DEVICE_MODEL,
    dr.LOT_ID,
    dr.MANUFACTURE_DATE,
    dr.FACILITY_CODE,
    dr.STATUS,

    count(ae.AE_ID)                                    as TOTAL_AE_COUNT,
    count(case when ae.SEVERITY = 'HIGH'   then 1 end) as HIGH_SEVERITY_COUNT,
    count(case when ae.SEVERITY = 'MEDIUM' then 1 end) as MEDIUM_SEVERITY_COUNT,
    count(case when ae.SEVERITY = 'LOW'    then 1 end) as LOW_SEVERITY_COUNT,
    count(case when ae.SUBMITTED_TO_FDA    then 1 end) as FDA_SUBMISSIONS,
    count(distinct ae.COUNTRY)                         as COUNTRIES_AFFECTED,
    max(ae.EVENT_DATE)                                 as MOST_RECENT_AE_DATE,
    current_timestamp()                                as LAST_REFRESHED_AT

from {{ source('device', 'device_registry') }} dr
left join {{ source('device', 'adverse_events') }} ae
    on dr.LOT_ID = ae.DEVICE_LOT_ID
group by
    dr.DEVICE_MODEL, dr.LOT_ID, dr.MANUFACTURE_DATE,
    dr.FACILITY_CODE, dr.STATUS
