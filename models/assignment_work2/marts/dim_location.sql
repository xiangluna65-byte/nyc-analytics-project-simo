WITH all_locations AS (
   SELECT DISTINCT 
        borough, 
        zip_code
   FROM {{ ref('stg_311service_requests') }}
   WHERE borough IS NOT NULL

   UNION DISTINCT

   SELECT DISTINCT 
          borough, 
          zip_code
   FROM {{ ref('stg_permit_issuance') }}
   WHERE borough IS NOT NULL
),

location_dimension AS (
   SELECT
       {{ dbt_utils.generate_surrogate_key(['borough', 'zip_code']) }} AS location_key,
       borough,
       zip_code
   FROM all_locations
)

SELECT * FROM location_dimension