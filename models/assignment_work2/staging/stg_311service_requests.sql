WITH source AS (
    SELECT *
    FROM {{ source("raw", "dob_311service_requests") }}
    WHERE borough IS NOT NULL
),

cleaned AS (
    SELECT
        unique_key,
        complaint_type,
        borough,
       
        CAST(created_date AS TIMESTAMP) AS created_date,

        -- Location - clean zip code
       CASE
           WHEN UPPER(TRIM(CAST(incident_zip AS STRING))) IN ('N/A', 'NA') THEN NULL
           WHEN UPPER(TRIM(CAST(incident_zip AS STRING))) = 'ANONYMOUS' THEN 'Anonymous'
           WHEN LENGTH(CAST(incident_zip AS STRING)) = 5 THEN CAST(incident_zip AS STRING)
           WHEN LENGTH(CAST(incident_zip AS STRING)) = 9 THEN CAST(incident_zip AS STRING)
           WHEN LENGTH(CAST(incident_zip AS STRING)) = 10
               AND REGEXP_CONTAINS(CAST(incident_zip AS STRING), r'^\d{5}-\d{4}')
           THEN CAST(incident_zip AS STRING)
           ELSE NULL
       END AS zip_code,

       -- Metadata
       CURRENT_TIMESTAMP() AS _stg_loaded_at

    FROM source
)

SELECT *
FROM cleaned