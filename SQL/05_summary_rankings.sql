-- ============================================================
-- 05_summary_rankings.sql
-- Final ranked summary: which features carry the strongest
-- diagnostic signal based on separation ratio and variance
-- ============================================================

USE breast_cancer_analysis;

-- ============================================================
-- Coefficient of variation (CV) by diagnosis for key features
-- CV = std / mean — measures relative spread within each class
-- Low CV within a class + high ratio between classes = strong signal
-- ============================================================
SELECT
    diagnosis,
    ROUND(STDDEV(radius_worst)         / NULLIF(AVG(radius_worst), 0), 4)         AS cv_radius_worst,
    ROUND(STDDEV(perimeter_worst)      / NULLIF(AVG(perimeter_worst), 0), 4)      AS cv_perimeter_worst,
    ROUND(STDDEV(area_worst)           / NULLIF(AVG(area_worst), 0), 4)           AS cv_area_worst,
    ROUND(STDDEV(concavity_worst)      / NULLIF(AVG(concavity_worst), 0), 4)      AS cv_concavity_worst,
    ROUND(STDDEV(concave_points_worst) / NULLIF(AVG(concave_points_worst), 0), 4) AS cv_concave_points_worst,
    ROUND(STDDEV(symmetry_worst)       / NULLIF(AVG(symmetry_worst), 0), 4)       AS cv_symmetry_worst,
    ROUND(STDDEV(fractal_dimension_worst) / NULLIF(AVG(fractal_dimension_worst), 0), 4) AS cv_fractal_dimension_worst
FROM tumor_data
GROUP BY diagnosis;

-- ============================================================
-- Final ranked feature table
-- Combines separation ratio + whether worst outperforms mean
-- Use this output as the basis for the README findings section
-- ============================================================
WITH stats AS (
    SELECT
        diagnosis,
        AVG(radius_mean)             AS r_radius_mean,
        AVG(concave_points_mean)     AS r_cp_mean,
        AVG(concavity_mean)          AS r_concavity_mean,
        AVG(area_mean)               AS r_area_mean,
        AVG(perimeter_mean)          AS r_perimeter_mean,
        AVG(fractal_dimension_mean)  AS r_fd_mean,
        AVG(radius_worst)            AS r_radius_worst,
        AVG(concave_points_worst)    AS r_cp_worst,
        AVG(concavity_worst)         AS r_concavity_worst,
        AVG(area_worst)              AS r_area_worst,
        AVG(perimeter_worst)         AS r_perimeter_worst,
        AVG(fractal_dimension_worst) AS r_fd_worst
    FROM tumor_data
    GROUP BY diagnosis
),
m AS (SELECT * FROM stats WHERE diagnosis = 'M'),
b AS (SELECT * FROM stats WHERE diagnosis = 'B')

SELECT feature, ROUND(ratio, 3) AS malignant_to_benign_ratio, feature_type
FROM (
    SELECT 'radius_mean'             AS feature, m.r_radius_mean / b.r_radius_mean         AS ratio, 'mean'  AS feature_type FROM m, b
    UNION ALL
    SELECT 'concave_points_mean',               m.r_cp_mean / b.r_cp_mean,                          'mean'  FROM m, b
    UNION ALL
    SELECT 'concavity_mean',                    m.r_concavity_mean / b.r_concavity_mean,             'mean'  FROM m, b
    UNION ALL
    SELECT 'area_mean',                         m.r_area_mean / b.r_area_mean,                       'mean'  FROM m, b
    UNION ALL
    SELECT 'perimeter_mean',                    m.r_perimeter_mean / b.r_perimeter_mean,             'mean'  FROM m, b
    UNION ALL
    SELECT 'fractal_dimension_mean',            m.r_fd_mean / b.r_fd_mean,                           'mean'  FROM m, b
    UNION ALL
    SELECT 'radius_worst',                      m.r_radius_worst / b.r_radius_worst,                 'worst' FROM m, b
    UNION ALL
    SELECT 'concave_points_worst',              m.r_cp_worst / b.r_cp_worst,                         'worst' FROM m, b
    UNION ALL
    SELECT 'concavity_worst',                   m.r_concavity_worst / b.r_concavity_worst,           'worst' FROM m, b
    UNION ALL
    SELECT 'area_worst',                        m.r_area_worst / b.r_area_worst,                     'worst' FROM m, b
    UNION ALL
    SELECT 'perimeter_worst',                   m.r_perimeter_worst / b.r_perimeter_worst,           'worst' FROM m, b
    UNION ALL
    SELECT 'fractal_dimension_worst',           m.r_fd_worst / b.r_fd_worst,                         'worst' FROM m, b
) ranked
ORDER BY ratio DESC;

-- ============================================================
-- Borderline cases: records where malignant/benign overlap most
-- These are diagnostically ambiguous — interesting clinically
-- ============================================================
WITH class_means AS (
    SELECT
        diagnosis,
        AVG(concave_points_worst) AS mean_cp_worst
    FROM tumor_data
    GROUP BY diagnosis
),
m AS (SELECT mean_cp_worst FROM class_means WHERE diagnosis = 'M'),
b AS (SELECT mean_cp_worst FROM class_means WHERE diagnosis = 'B')

SELECT
    t.id,
    t.diagnosis,
    ROUND(t.concave_points_worst, 4)        AS concave_points_worst,
    ROUND(ABS(t.concave_points_worst - m.mean_cp_worst), 4) AS dist_from_malignant_mean,
    ROUND(ABS(t.concave_points_worst - b.mean_cp_worst), 4) AS dist_from_benign_mean
FROM tumor_data t, m, b
WHERE ABS(t.concave_points_worst - m.mean_cp_worst) < 0.05
   OR ABS(t.concave_points_worst - b.mean_cp_worst) < 0.05
ORDER BY dist_from_malignant_mean ASC
LIMIT 25;
