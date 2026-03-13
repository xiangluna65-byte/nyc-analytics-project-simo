-- Fact table for 311 complaints
-- Grain: one row per complaint

WITH complaints AS (
    SELECT *
    FROM {{ ref('stg_311service_requests') }}
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
        c.unique_key AS complaint_id,

        -- Complaint attributes
        c.complaint_type,

        -- Foreign keys
        d.date_key,
        l.location_key,

        -- Measure
        1 AS complaint_count

    FROM complaints c

    -- Date join
    LEFT JOIN dim_date d
        ON CAST(c.created_date AS DATE) = d.full_date

    -- Location join
    LEFT JOIN dim_location l
        ON c.borough = l.borough
        AND c.zip_code = l.zip_code
)

SELECT * FROM final