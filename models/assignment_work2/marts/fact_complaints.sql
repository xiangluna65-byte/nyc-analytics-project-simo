SELECT
    unique_key AS complaint_id,
    complaint_type,
    {{ dbt_utils.generate_surrogate_key(['CAST(created_date AS DATE)']) }} AS date_key,
    {{ dbt_utils.generate_surrogate_key(['borough', 'zip_code']) }} AS location_key,
    1 AS complaint_count
FROM {{ ref('stg_311service_requests') }}