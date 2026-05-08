-- ============================================================
-- 03_feature_separation.sql
-- Identify which features show the largest gap between
-- malignant and benign cases — absolute and relative difference
-- ============================================================

USE breast_cancer_analysis;

-- ============================================================
-- Compute malignant/benign mean for each feature
-- then rank by absolute gap and relative ratio
-- ============================================================
WITH class_means AS (
    SELECT
        diagnosis,
        AVG(radius_mean)             AS radius_mean,
        AVG(texture_mean)            AS texture_mean,
        AVG(perimeter_mean)          AS perimeter_mean,
        AVG(area_mean)               AS area_mean,
        AVG(smoothness_mean)         AS smoothness_mean,
        AVG(compactness_mean)        AS compactness_mean,
        AVG(concavity_mean)          AS concavity_mean,
        AVG(concave_points_mean)     AS concave_points_mean,
        AVG(symmetry_mean)           AS symmetry_mean,
        AVG(fractal_dimension_mean)  AS fractal_dimension_mean,
        AVG(radius_worst)            AS radius_worst,
        AVG(texture_worst)           AS texture_worst,
        AVG(perimeter_worst)         AS perimeter_worst,
        AVG(area_worst)              AS area_worst,
        AVG(smoothness_worst)        AS smoothness_worst,
        AVG(compactness_worst)       AS compactness_worst,
        AVG(concavity_worst)         AS concavity_worst,
        AVG(concave_points_worst)    AS concave_points_worst,
        AVG(symmetry_worst)          AS symmetry_worst,
        AVG(fractal_dimension_worst) AS fractal_dimension_worst
    FROM tumor_data
    GROUP BY diagnosis
),
malignant AS (SELECT * FROM class_means WHERE diagnosis = 'M'),
benign    AS (SELECT * FROM class_means WHERE diagnosis = 'B')

SELECT
    feature,
    ROUND(m_mean, 4)                            AS malignant_mean,
    ROUND(b_mean, 4)                            AS benign_mean,
    ROUND(m_mean - b_mean, 4)                   AS absolute_gap,
    ROUND(m_mean / NULLIF(b_mean, 0), 4)        AS malignant_to_benign_ratio
FROM (
    SELECT 'radius_mean'             AS feature, m.radius_mean             AS m_mean, b.radius_mean             AS b_mean FROM malignant m, benign b
    UNION ALL
    SELECT 'texture_mean',                        m.texture_mean,                       b.texture_mean             FROM malignant m, benign b
    UNION ALL
    SELECT 'perimeter_mean',                      m.perimeter_mean,                     b.perimeter_mean           FROM malignant m, benign b
    UNION ALL
    SELECT 'area_mean',                           m.area_mean,                          b.area_mean                FROM malignant m, benign b
    UNION ALL
    SELECT 'smoothness_mean',                     m.smoothness_mean,                    b.smoothness_mean          FROM malignant m, benign b
    UNION ALL
    SELECT 'compactness_mean',                    m.compactness_mean,                   b.compactness_mean         FROM malignant m, benign b
    UNION ALL
    SELECT 'concavity_mean',                      m.concavity_mean,                     b.concavity_mean           FROM malignant m, benign b
    UNION ALL
    SELECT 'concave_points_mean',                 m.concave_points_mean,                b.concave_points_mean      FROM malignant m, benign b
    UNION ALL
    SELECT 'symmetry_mean',                       m.symmetry_mean,                      b.symmetry_mean            FROM malignant m, benign b
    UNION ALL
    SELECT 'fractal_dimension_mean',              m.fractal_dimension_mean,             b.fractal_dimension_mean   FROM malignant m, benign b
    UNION ALL
    SELECT 'radius_worst',                        m.radius_worst,                       b.radius_worst             FROM malignant m, benign b
    UNION ALL
    SELECT 'texture_worst',                       m.texture_worst,                      b.texture_worst            FROM malignant m, benign b
    UNION ALL
    SELECT 'perimeter_worst',                     m.perimeter_worst,                    b.perimeter_worst          FROM malignant m, benign b
    UNION ALL
    SELECT 'area_worst',                          m.area_worst,                         b.area_worst               FROM malignant m, benign b
    UNION ALL
    SELECT 'smoothness_worst',                    m.smoothness_worst,                   b.smoothness_worst         FROM malignant m, benign b
    UNION ALL
    SELECT 'compactness_worst',                   m.compactness_worst,                  b.compactness_worst        FROM malignant m, benign b
    UNION ALL
    SELECT 'concavity_worst',                     m.concavity_worst,                    b.concavity_worst          FROM malignant m, benign b
    UNION ALL
    SELECT 'concave_points_worst',                m.concave_points_worst,               b.concave_points_worst     FROM malignant m, benign b
    UNION ALL
    SELECT 'symmetry_worst',                      m.symmetry_worst,                     b.symmetry_worst           FROM malignant m, benign b
    UNION ALL
    SELECT 'fractal_dimension_worst',             m.fractal_dimension_worst,            b.fractal_dimension_worst  FROM malignant m, benign b
) feature_gaps
ORDER BY malignant_to_benign_ratio DESC;

-- ============================================================
-- Mean vs worst comparison: do worst-case features separate better?
-- Compare ratio for mean vs worst for the same measurement
-- ============================================================
WITH class_means AS (
    SELECT
        diagnosis,
        AVG(radius_mean)          AS radius_mean,   AVG(radius_worst)          AS radius_worst,
        AVG(concavity_mean)       AS concavity_mean, AVG(concavity_worst)       AS concavity_worst,
        AVG(concave_points_mean)  AS cp_mean,        AVG(concave_points_worst)  AS cp_worst,
        AVG(area_mean)            AS area_mean,      AVG(area_worst)            AS area_worst
    FROM tumor_data
    GROUP BY diagnosis
),
m AS (SELECT * FROM class_means WHERE diagnosis = 'M'),
b AS (SELECT * FROM class_means WHERE diagnosis = 'B')

SELECT
    measurement,
    ROUND(mean_ratio, 3)  AS mean_feature_ratio,
    ROUND(worst_ratio, 3) AS worst_feature_ratio,
    ROUND(worst_ratio - mean_ratio, 3) AS worst_advantage
FROM (
    SELECT 'radius'         AS measurement, m.radius_mean / b.radius_mean                AS mean_ratio, m.radius_worst / b.radius_worst                AS worst_ratio FROM m, b
    UNION ALL
    SELECT 'concavity',                     m.concavity_mean / b.concavity_mean,                        m.concavity_worst / b.concavity_worst           FROM m, b
    UNION ALL
    SELECT 'concave_points',                m.cp_mean / b.cp_mean,                                      m.cp_worst / b.cp_worst                         FROM m, b
    UNION ALL
    SELECT 'area',                          m.area_mean / b.area_mean,                                  m.area_worst / b.area_worst                     FROM m, b
) comparison
ORDER BY worst_advantage DESC;
