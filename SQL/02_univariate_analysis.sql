-- ============================================================
-- 02_univariate_analysis.sql
-- Summary statistics for all 30 features broken out by diagnosis
-- Mean, std dev, min, max, and percentiles per class
-- ============================================================

USE breast_cancer_analysis;

-- ============================================================
-- Summary stats for mean features by diagnosis
-- ============================================================
SELECT
    diagnosis,
    ROUND(AVG(radius_mean), 4)              AS avg_radius_mean,
    ROUND(STDDEV(radius_mean), 4)           AS std_radius_mean,
    ROUND(AVG(texture_mean), 4)             AS avg_texture_mean,
    ROUND(STDDEV(texture_mean), 4)          AS std_texture_mean,
    ROUND(AVG(perimeter_mean), 4)           AS avg_perimeter_mean,
    ROUND(STDDEV(perimeter_mean), 4)        AS std_perimeter_mean,
    ROUND(AVG(area_mean), 4)                AS avg_area_mean,
    ROUND(STDDEV(area_mean), 4)             AS std_area_mean,
    ROUND(AVG(smoothness_mean), 4)          AS avg_smoothness_mean,
    ROUND(STDDEV(smoothness_mean), 4)       AS std_smoothness_mean,
    ROUND(AVG(compactness_mean), 4)         AS avg_compactness_mean,
    ROUND(STDDEV(compactness_mean), 4)      AS std_compactness_mean,
    ROUND(AVG(concavity_mean), 4)           AS avg_concavity_mean,
    ROUND(STDDEV(concavity_mean), 4)        AS std_concavity_mean,
    ROUND(AVG(concave_points_mean), 4)      AS avg_concave_points_mean,
    ROUND(STDDEV(concave_points_mean), 4)   AS std_concave_points_mean,
    ROUND(AVG(symmetry_mean), 4)            AS avg_symmetry_mean,
    ROUND(STDDEV(symmetry_mean), 4)         AS std_symmetry_mean,
    ROUND(AVG(fractal_dimension_mean), 4)   AS avg_fractal_dimension_mean,
    ROUND(STDDEV(fractal_dimension_mean), 4) AS std_fractal_dimension_mean
FROM tumor_data
GROUP BY diagnosis;

-- ============================================================
-- Summary stats for worst features by diagnosis
-- Worst-case measurements tend to be stronger diagnostic signals
-- ============================================================
SELECT
    diagnosis,
    ROUND(AVG(radius_worst), 4)             AS avg_radius_worst,
    ROUND(STDDEV(radius_worst), 4)          AS std_radius_worst,
    ROUND(AVG(perimeter_worst), 4)          AS avg_perimeter_worst,
    ROUND(STDDEV(perimeter_worst), 4)       AS std_perimeter_worst,
    ROUND(AVG(area_worst), 4)               AS avg_area_worst,
    ROUND(STDDEV(area_worst), 4)            AS std_area_worst,
    ROUND(AVG(concavity_worst), 4)          AS avg_concavity_worst,
    ROUND(STDDEV(concavity_worst), 4)       AS std_concavity_worst,
    ROUND(AVG(concave_points_worst), 4)     AS avg_concave_points_worst,
    ROUND(STDDEV(concave_points_worst), 4)  AS std_concave_points_worst,
    ROUND(AVG(fractal_dimension_worst), 4)  AS avg_fractal_dimension_worst,
    ROUND(STDDEV(fractal_dimension_worst), 4) AS std_fractal_dimension_worst
FROM tumor_data
GROUP BY diagnosis;

-- ============================================================
-- Percentile breakdown for radius_mean by diagnosis
-- Shows how distributions overlap (or don't)
-- ============================================================
SELECT
    diagnosis,
    ROUND(MIN(radius_mean), 3)                                          AS p0_min,
    ROUND(MAX(CASE WHEN pct <= 0.25 THEN radius_mean END), 3)          AS p25,
    ROUND(MAX(CASE WHEN pct <= 0.50 THEN radius_mean END), 3)          AS p50_median,
    ROUND(MAX(CASE WHEN pct <= 0.75 THEN radius_mean END), 3)          AS p75,
    ROUND(MAX(radius_mean), 3)                                          AS p100_max
FROM (
    SELECT
        diagnosis,
        radius_mean,
        PERCENT_RANK() OVER (PARTITION BY diagnosis ORDER BY radius_mean) AS pct
    FROM tumor_data
) ranked
GROUP BY diagnosis;

-- ============================================================
-- Same percentile breakdown for concave_points_worst
-- Expected to show strong separation
-- ============================================================
SELECT
    diagnosis,
    ROUND(MIN(concave_points_worst), 4)                                     AS p0_min,
    ROUND(MAX(CASE WHEN pct <= 0.25 THEN concave_points_worst END), 4)     AS p25,
    ROUND(MAX(CASE WHEN pct <= 0.50 THEN concave_points_worst END), 4)     AS p50_median,
    ROUND(MAX(CASE WHEN pct <= 0.75 THEN concave_points_worst END), 4)     AS p75,
    ROUND(MAX(concave_points_worst), 4)                                     AS p100_max
FROM (
    SELECT
        diagnosis,
        concave_points_worst,
        PERCENT_RANK() OVER (PARTITION BY diagnosis ORDER BY concave_points_worst) AS pct
    FROM tumor_data
) ranked
GROUP BY diagnosis;
