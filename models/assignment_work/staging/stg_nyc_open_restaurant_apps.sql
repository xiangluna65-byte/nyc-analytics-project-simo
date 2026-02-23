-- Clean and standardize open restaurant application data
-- One row per restaurant application

WITH source AS (
   SELECT * 
   FROM {{ source('raw', 'source_nyc_open_restaurant_apps') }}
), -- Easier to reference the raw source table

cleaned AS (
   SELECT

       -- Keep all columns except ones we are transforming below
       * EXCEPT (
           objectid,
           zip,
           approved_for_sidewalk_seating,
           approved_for_roadway_seating,
           qualify_alcohol,
           sidewalk_dimensions_length,
           sidewalk_dimensions_width,
           sidewalk_dimensions_area,
           roadway_dimensions_length,
           roadway_dimensions_width,
           roadway_dimensions_area,
           latitude,
           longitude,
           time_of_submission,
           bulding_number
       ),

       -- Identifiers
       CAST(objectid AS STRING) AS application_id,

       -- Business info
       bulding_number AS building_number,
       CAST(zip AS STRING) AS zip_code,

       -- Boolean fields
       CASE WHEN LOWER(approved_for_sidewalk_seating) = 'yes' THEN TRUE ELSE FALSE END AS approved_for_sidewalk_seating,
       CASE WHEN LOWER(approved_for_roadway_seating) = 'yes' THEN TRUE ELSE FALSE END AS approved_for_roadway_seating,
       CASE WHEN LOWER(qualify_alcohol) = 'yes' THEN TRUE ELSE FALSE END AS qualify_alcohol,

       -- Dimensions
       SAFE_CAST(sidewalk_dimensions_length AS FLOAT64) AS sidewalk_dimensions_length,
       SAFE_CAST(sidewalk_dimensions_width AS FLOAT64) AS sidewalk_dimensions_width,
       SAFE_CAST(sidewalk_dimensions_area AS FLOAT64) AS sidewalk_dimensions_area,
       SAFE_CAST(roadway_dimensions_length AS FLOAT64) AS roadway_dimensions_length,
       SAFE_CAST(roadway_dimensions_width AS FLOAT64) AS roadway_dimensions_width,
       SAFE_CAST(roadway_dimensions_area AS FLOAT64) AS roadway_dimensions_area,

       -- Geo
       SAFE_CAST(latitude AS FLOAT64) AS latitude,
       SAFE_CAST(longitude AS FLOAT64) AS longitude,

       -- Timestamp
       SAFE.PARSE_TIMESTAMP(
           '%m/%d/%Y %I:%M:%S %p',
           time_of_submission
       ) AS time_of_submission,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   -- Filters
   WHERE objectid IS NOT NULL
   AND time_of_submission IS NOT NULL

)

SELECT * FROM cleaned
-- All should be part of this table: stg_nyc_open_restaurant_apps