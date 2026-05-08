-- ============================================================
-- 04_outlier_analysis.sql
-- Use window functions to flag outliers, examine spread,
-- and compare variance between malignant and benign cases
-- ============================================================

USE breast_cancer_analysis;

-- ============================================================
-- Flag outliers using IQR method per diagnosis class
-- Outlier = value outside (Q1 - 1.5*IQR, Q3 + 1.5*IQR)
-- ============================================================
WITH percentiles AS (
    SELECT
        diagnosis,
        concave_points_worst,
        PERCENT_RANK() OVER (PARTITION BY diagnosis ORDER BY concave_points_worst) AS pct_rank
    FROM tumor_data
),
iqr_bounds AS (
    SELECT
        diagnosis,
        MAX(CASE WHEN pct_rank <= 0.25 THEN concave_points_worst END) AS q1,
        MAX(CASE WHEN pct_rank <= 0.75 THEN concave_points_worst END) AS q3
    FROM percentiles
    GROUP BY diagnosis
),
bounds AS (
    SELECT
        diagnosis,
        q1,
        q3,
        q3 - q1                        AS iqr,
        q1 - 1.5 * (q3 - q1)          AS lower_bound,
        q3 + 1.5 * (q3 - q1)          AS upper_bound
    FROM iqr_bounds
)
SELECT
    t.id,
    t.diagnosis,
    ROUND(t.concave_points_worst, 4)   AS concave_points_worst,
    ROUND(b.lower_bound, 4)            AS lower_bound,
    ROUND(b.upper_bound, 4)            AS upper_bound,
    CASE
        WHEN t.concave_points_worst < b.lower_bound THEN 'Low outlier'
        WHEN t.concave_points_worst > b.upper_bound THEN 'High outlier'
        ELSE 'Normal'
    END                                AS outlier_flag
FROM tumor_data t
JOIN bounds b ON t.diagnosis = b.diagnosis
WHERE t.concave_points_worst < b.lower_bound
   OR t.concave_points_worst > b.upper_bound
ORDER BY t.diagnosis, t.concave_points_worst DESC;

-- ============================================================
-- Count outliers by diagnosis
-- Are malignant cases more variable?
-- ============================================================
WITH percentiles AS (
    SELECT
        diagnosis,
        concave_points_worst,
        PERCENT_RANK() OVER (PARTITION BY diagnosis ORDER BY concave_points_worst) AS pct_rank
    FROM tumor_data
),
iqr_bounds AS (
    SELECT
        diagnosis,
        MAX(CASE WHEN pct_rank <= 0.25 THEN concave_points_worst END) AS q1,
        MAX(CASE WHEN pct_rank <= 0.75 THEN concave_points_worst END) AS q3
    FROM percentiles
    GROUP BY diagnosis
),
bounds AS (
    SELECT diagnosis, q1, q3,
           q1 - 1.5*(q3-q1) AS lower_bound,
           q3 + 1.5*(q3-q1) AS upper_bound
    FROM iqr_bounds
)
SELECT
    t.diagnosis,
    COUNT(*)                                    AS total_records,
    SUM(CASE WHEN t.concave_points_worst < b.lower_bound
              OR t.concave_points_worst > b.upper_bound THEN 1 ELSE 0 END) AS outlier_count,
    ROUND(SUM(CASE WHEN t.concave_points_worst < b.lower_bound
                    OR t.concave_points_worst > b.upper_bound THEN 1 ELSE 0 END)
          * 100.0 / COUNT(*), 1)                AS outlier_pct
FROM tumor_data t
JOIN bounds b ON t.diagnosis = b.diagnosis
GROUP BY t.diagnosis;

-- ============================================================
-- Variance comparison across key features by diagnosis
-- Higher variance in malignant = more morphological irregularity
-- ============================================================
SELECT
    diagnosis,
    ROUND(VARIANCE(radius_worst), 4)            AS var_radius_worst,
    ROUND(VARIANCE(area_worst), 4)              AS var_area_worst,
    ROUND(VARIANCE(concavity_worst), 4)         AS var_concavity_worst,
    ROUND(VARIANCE(concave_points_worst), 4)    AS var_concave_points_worst,
    ROUND(VARIANCE(fractal_dimension_worst), 4) AS var_fractal_dimension_worst,
    ROUND(VARIANCE(symmetry_worst), 4)          AS var_symmetry_worst
FROM tumor_data
GROUP BY diagnosis;

-- ============================================================
-- Row-level z-score for radius_mean within each diagnosis class
-- Flag cases that are extreme relative to their own class
-- ============================================================
SELECT
    id,
    diagnosis,
    ROUND(radius_mean, 3)                        AS radius_mean,
    ROUND(AVG(radius_mean) OVER (PARTITION BY diagnosis), 3)    AS class_mean,
    ROUND(STDDEV(radius_mean) OVER (PARTITION BY diagnosis), 3) AS class_std,
    ROUND(
        (radius_mean - AVG(radius_mean) OVER (PARTITION BY diagnosis))
        / NULLIF(STDDEV(radius_mean) OVER (PARTITION BY diagnosis), 0),
        3
    )                                            AS z_score
FROM tumor_data
ORDER BY ABS(
    (radius_mean - AVG(radius_mean) OVER (PARTITION BY diagnosis))
    / NULLIF(STDDEV(radius_mean) OVER (PARTITION BY diagnosis), 0)
) DESC
LIMIT 20;
