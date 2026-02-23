-- Location dimension shared by both restaurant applications and 311 service reqs

WITH all_locations AS (
   -- Get locations from 311 requests
   SELECT DISTINCT borough, incident_zip
   FROM {{ ref('stg_nyc_311_dot') }}
   WHERE borough IS NOT NULL

   UNION DISTINCT

   -- Get locations from restaurant applications
   SELECT DISTINCT borough, incident_zip
   FROM {{ ref('stg_nyc_open_restaurant_apps') }}
   WHERE borough IS NOT NULL
),

location_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key(['borough', 'incident_zip']) }} AS location_key,
       borough,
       incident_zip
   FROM all_locations
)

SELECT * FROM location_dimension