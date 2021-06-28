import os
import json

from flask import Flask, request

from google.cloud import bigquery
from google.cloud.exceptions import NotFound
from google.oauth2 import service_account

credentials_json = '/app/groovy-vector-317916-0359dff710ee.json'
os.environ['GOOGLE_APPLICATION_CREDENTIALS'] = credentials_json
client = bigquery.Client()

credentials = service_account.Credentials.from_service_account_file(
'/app/groovy-vector-317916-0359dff710ee.json')

project_id = 'groovy-vector-317916'
client = bigquery.Client(credentials= credentials,project=project_id)

app = Flask(__name__)
@app.route("/")
def get_request():
    query_job = client.query("""
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
            passenger_count """)

    results = query_job.result()
    records = [dict(row) for row in query_job]
    json_obj = json.dumps(str(records)) 
    return json_obj


if __name__ == "__main__":
    app.run(debug=True, host="0.0.0.0", port=int(os.environ.get("PORT", 8080)))


