SELECT
    permit_id,
    work_type,
    permit_type,
    {{ dbt_utils.generate_surrogate_key(['CAST(job_start_date AS DATE)']) }} AS date_key,
    {{ dbt_utils.generate_surrogate_key(['borough', 'zip_code']) }} AS location_key,
FROM {{ ref('stg_permit_issuance') }}