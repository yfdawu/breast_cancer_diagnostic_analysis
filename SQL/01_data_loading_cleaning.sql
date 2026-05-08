-- ============================================================
-- 01_data_loading_cleaning.sql
-- Load raw data, inspect structure, check for nulls,
-- verify class distribution
-- ============================================================

-- Create database
CREATE DATABASE IF NOT EXISTS breast_cancer_analysis;
USE breast_cancer_analysis;

-- Create table matching UCI dataset column structure
CREATE TABLE IF NOT EXISTS tumor_data (
    id                        INT,
    diagnosis                 VARCHAR(1),        -- M = Malignant, B = Benign

    -- Mean features
    radius_mean               FLOAT,
    texture_mean              FLOAT,
    perimeter_mean            FLOAT,
    area_mean                 FLOAT,
    smoothness_mean           FLOAT,
    compactness_mean          FLOAT,
    concavity_mean            FLOAT,
    concave_points_mean       FLOAT,
    symmetry_mean             FLOAT,
    fractal_dimension_mean    FLOAT,

    -- Standard error features
    radius_se                 FLOAT,
    texture_se                FLOAT,
    perimeter_se              FLOAT,
    area_se                   FLOAT,
    smoothness_se             FLOAT,
    compactness_se            FLOAT,
    concavity_se              FLOAT,
    concave_points_se         FLOAT,
    symmetry_se               FLOAT,
    fractal_dimension_se      FLOAT,

    -- Worst (largest) features
    radius_worst              FLOAT,
    texture_worst             FLOAT,
    perimeter_worst           FLOAT,
    area_worst                FLOAT,
    smoothness_worst          FLOAT,
    compactness_worst         FLOAT,
    concavity_worst           FLOAT,
    concave_points_worst      FLOAT,
    symmetry_worst            FLOAT,
    fractal_dimension_worst   FLOAT
);

-- ============================================================
-- Load CSV data
-- Update file path to match your local directory
-- ============================================================
LOAD DATA INFILE '/path/to/data/breast_cancer.csv'
INTO TABLE tumor_data
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

-- ============================================================
-- Basic inspection
-- ============================================================

-- Row count
SELECT COUNT(*) AS total_records
FROM tumor_data;

-- Check for NULL values across all columns
SELECT
    SUM(CASE WHEN diagnosis IS NULL THEN 1 ELSE 0 END)              AS null_diagnosis,
    SUM(CASE WHEN radius_mean IS NULL THEN 1 ELSE 0 END)            AS null_radius_mean,
    SUM(CASE WHEN texture_mean IS NULL THEN 1 ELSE 0 END)           AS null_texture_mean,
    SUM(CASE WHEN perimeter_mean IS NULL THEN 1 ELSE 0 END)         AS null_perimeter_mean,
    SUM(CASE WHEN area_mean IS NULL THEN 1 ELSE 0 END)              AS null_area_mean,
    SUM(CASE WHEN concavity_mean IS NULL THEN 1 ELSE 0 END)         AS null_concavity_mean,
    SUM(CASE WHEN concave_points_mean IS NULL THEN 1 ELSE 0 END)    AS null_concave_points_mean,
    SUM(CASE WHEN radius_worst IS NULL THEN 1 ELSE 0 END)           AS null_radius_worst,
    SUM(CASE WHEN concave_points_worst IS NULL THEN 1 ELSE 0 END)   AS null_concave_points_worst
FROM tumor_data;

-- Class distribution
SELECT
    diagnosis,
    COUNT(*)                                        AS count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS pct_of_total
FROM tumor_data
GROUP BY diagnosis;

-- Quick sanity check on value ranges
SELECT
    diagnosis,
    ROUND(MIN(radius_mean), 3)   AS radius_min,
    ROUND(MAX(radius_mean), 3)   AS radius_max,
    ROUND(MIN(area_mean), 3)     AS area_min,
    ROUND(MAX(area_mean), 3)     AS area_max
FROM tumor_data
GROUP BY diagnosis;
