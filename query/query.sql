WITH params 
AS 
(
  SELECT ST_GeogPoint(-74.0474287, 40.6895436) AS center,
  3.5 AS maxdist_km, 
  525600 maxtimedriving_min
), 
distance_from_center 
AS 
(
  SELECT
    maxtimedriving_min,
    ST_GeogPoint(dropoff_longitude, dropoff_latitude) AS loc,
    ST_Distance(ST_GeogPoint(dropoff_longitude, dropoff_latitude), params.center) AS    dist_meters,
    passenger_count, 
    TIMESTAMP_DIFF(dropoff_datetime,pickup_datetime, MINUTE) as totalTimeInMinutes
  FROM
    `bigquery-public-data.new_york_taxi_trips.tlc_yellow_trips_2016`,
    params
  WHERE passenger_count between 1 and 6 and 
  (dropoff_longitude between -90 and 90 and dropoff_latitude between -90 and 90) and ST_DWithin(ST_GeogPoint(dropoff_longitude, dropoff_latitude), params.center, params.maxdist_km*1000)
)
SELECT  passenger_count,
        count(1) as numberOfTrips,
        sum(totalTimeInMinutes) as totalTimeInMinutes, 
        round((sum(totalTimeInMinutes)/maxtimedriving_min),2) as numberOfCabsRequired
from    distance_from_center 
group by 
        passenger_count, 
        maxtimedriving_min
order by 
        passenger_count