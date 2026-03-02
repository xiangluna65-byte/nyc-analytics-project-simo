WITH source AS (
    SELECT *
    FROM {{ source("raw", "dob_permit_issuance") }}
    WHERE borough IS NOT NULL
),

cleaned AS (
    SELECT
        borough,
        work_type,
        permit_type,

        -- Create ID
        CAST(FARM_FINGERPRINT(CONCAT(
            CAST(job_start_date AS STRING), 
            COALESCE(zip_code, 'NA'), 
            COALESCE(permit_type, 'NA')
        )) AS STRING) AS permit_id,
        
       -- Location - clean zip code
       CASE
           WHEN UPPER(TRIM(CAST(zip_code AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(zip_code AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(zip_code AS STRING)) = 5 THEN CAST(zip_code AS STRING)
           WHEN LENGTH(CAST(zip_code AS STRING)) = 9 THEN CAST(zip_code AS STRING)
           WHEN LENGTH(CAST(zip_code AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(zip_code AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(zip_code AS STRING)
           ELSE NULL
       END AS zip_code,

       -- Job Start Date
       CAST(job_start_date AS TIMESTAMP) AS job_start_date,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
)

SELECT *
FROM cleaned