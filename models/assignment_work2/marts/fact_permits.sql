-- Fact table for permit issuance
-- Grain: one row per permit

WITH permits AS (
    SELECT *
    FROM {{ ref('stg_permit_issuance') }}
),

dim_date AS (
    SELECT 
        date_key, 
        full_date
    FROM {{ ref('dim_date') }}
),

dim_location AS (
    SELECT 
        location_key, 
        borough, 
        zip_code
    FROM {{ ref('dim_location') }}
),

final AS (
    SELECT
        -- Natural key
        p.permit_id,

        -- Permit attributes
        p.work_type,
        p.permit_type,

        -- Foreign keys
        d.date_key,
        l.location_key

    FROM permits p

    -- Date join
    LEFT JOIN dim_date d
        ON CAST(p.job_start_date AS DATE) = d.full_date

    -- Location join
    LEFT JOIN dim_location l
        ON p.borough = l.borough
        AND p.zip_code = l.zip_code
)

SELECT * FROM final