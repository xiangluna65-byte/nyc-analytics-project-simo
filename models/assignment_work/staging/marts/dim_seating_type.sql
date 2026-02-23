-- Clean and standardize open restaurant application data
-- One row per restaurant application

{{ config(materialized='table') }}

WITH source AS (

   SELECT *
   FROM {{ source('raw','source_nyc_open_restaurant_apps') }}

),

cleaned AS (

   SELECT

      -- =========================
      -- Identifiers
      -- =========================
      CAST(objectid AS STRING) AS objectid,
      globalid,

      -- =========================
      -- Business Info
      -- =========================
      restaurant_name,
      legal_business_name,
      doing_business_as_dba,

      bulding_number AS building_number,
      street,
      borough,

      CAST(zip AS STRING) AS zip_code,
      business_address,
      food_service_establishment,

      -- =========================
      -- ✅ Seating dimension raw values (KEEP THESE!)
      -- These are required for dim_seating_type
      -- =========================
      seating_interest_sidewalk,

      approved_for_sidewalk_seating,
      approved_for_roadway_seating,

      qualify_alcohol,

      -- =========================
      -- Boolean Normalization
      -- (We convert them but also keep raw above)
      -- =========================
      CASE WHEN LOWER(approved_for_sidewalk_seating) = 'yes' THEN TRUE ELSE FALSE END 
         AS approved_for_sidewalk,

      CASE WHEN LOWER(approved_for_roadway_seating) = 'yes' THEN TRUE ELSE FALSE END 
         AS approved_for_roadway,

      CASE WHEN LOWER(qualify_alcohol) = 'yes' THEN TRUE ELSE FALSE END 
         AS qualify_alcohol_flag,

      -- =========================
      -- Dimensions
      -- =========================
      SAFE_CAST(sidewalk_dimensions_length AS FLOAT64) AS sidewalk_dimensions_length,
      SAFE_CAST(sidewalk_dimensions_width AS FLOAT64) AS sidewalk_dimensions_width,
      SAFE_CAST(sidewalk_dimensions_area AS FLOAT64) AS sidewalk_dimensions_area,

      SAFE_CAST(roadway_dimensions_length AS FLOAT64) AS roadway_dimensions_length,
      SAFE_CAST(roadway_dimensions_width AS FLOAT64) AS roadway_dimensions_width,
      SAFE_CAST(roadway_dimensions_area AS FLOAT64) AS roadway_dimensions_area,

      -- =========================
      -- Geo
      -- =========================
      SAFE_CAST(latitude AS FLOAT64) AS latitude,
      SAFE_CAST(longitude AS FLOAT64) AS longitude,

      -- =========================
      -- Administrative
      -- =========================
      community_board,
      council_district,
      census_tract,
      bin,
      bbl,
      nta,

      sla_serial_number,
      sla_license_type,
      landmark_district_or_building,
      landmarkdistrict_terms,
      healthcompliance_terms,

      -- =========================
      -- Timestamp
      -- =========================
      SAFE.PARSE_TIMESTAMP(
         '%m/%d/%Y %I:%M:%S %p',
         time_of_submission
      ) AS time_of_submission,

      CURRENT_TIMESTAMP() AS _stg_loaded_at

   FROM source

   WHERE objectid IS NOT NULL

   QUALIFY ROW_NUMBER() OVER (
      PARTITION BY objectid
      ORDER BY time_of_submission DESC
   ) = 1

)

SELECT *
FROM cleaned