# Findings: What the Data Says

## Overview

This analysis examined 569 biopsy records — 212 malignant (37.3%) and 357 benign (62.7%) — across 30 cell nucleus measurements. The goal was not to build a classifier but to understand, at the feature level, what physically distinguishes malignant from benign tumors in this dataset.

---

## Finding 1: Shape irregularity separates the classes more than size

The two strongest diagnostic signals were **concavity_mean** (3.49x ratio) and **concave_points_mean** (3.42x ratio) — both measuring how irregular and indented the cell nucleus boundary is. Malignant nuclei had nearly 3.5x more concavity on average than benign ones.

Size features like radius and area showed meaningful but weaker separation (1.44x and 2.11x respectively). This suggests that while malignant tumors do tend to be larger, it is the *shape* of the nucleus — specifically how irregular and pitted its boundary is — that carries the strongest diagnostic signal in this dataset.

This aligns with established cell biology: malignant transformation disrupts the cytoskeleton and nuclear envelope, producing the irregular, lobulated nuclear shapes that pathologists look for under a microscope.

---

## Finding 2: Fractal dimension is a non-signal

**fractal_dimension_mean** returned a malignant-to-benign ratio of essentially 1.00 — no separation whatsoever between classes. This was the most surprising finding.

Fractal dimension measures the complexity of the nucleus boundary at a self-similar scale. The expectation might be that more irregular malignant nuclei would show higher fractal dimension — but the data does not support this. The absolute boundary complexity appears similar between classes even when the presence and depth of concavities is dramatically different.

This is a useful reminder that intuitive biological hypotheses do not always hold in real data, and that exploratory analysis before modeling is essential.

---

## Finding 3: Mean features outperform worst-case features for shape, but not for size

For concavity and concave points, the **mean** feature (averaged across the nucleus image) actually separated the classes better than the **worst-case** feature (the single most extreme measurement). The reverse was true for area and radius, where worst-case measurements were stronger signals.

This makes biological sense: concavity is a structural property of the nucleus that tends to be consistently expressed across the entire cell in malignant cases — it is not just an occasional extreme outlier. In contrast, the largest observed radius or area in a biopsy sample may be more diagnostically informative than the average, since a single very large cell can be a stronger indicator than the mean size across all measured cells.

---

## Finding 4: Malignant tumors are far more morphologically variable

Malignant cases showed dramatically higher variance across all features. The most striking example was **area_worst**, where malignant variance (355,879) was approximately 13x higher than benign variance (26,690).

This variability is not noise — it reflects genuine biological heterogeneity. Malignant tumors contain cells at different stages of abnormal division, producing a wider range of sizes and shapes within the same biopsy sample. Benign tumors, by contrast, tend to be more morphologically uniform.

From an analytical standpoint this means that the mean alone understates the difference between classes — the spread matters as much as the center.

---

## Finding 5: The boxplots show near-clean separation for concave points

The distribution chart shows that the interquartile ranges for **concave_points_worst** barely overlap between malignant and benign cases. The benign median sits below the malignant Q1. This is the kind of visual separation that gives a clinician — or a model — meaningful signal to work with.

In contrast, **concavity_worst** shows substantial overlap in the tails, particularly due to a cluster of high-concavity benign outliers. This illustrates why no single feature is sufficient for diagnosis, and why multivariate approaches are necessary in practice.

---

## Summary Table

| Feature | M/B Ratio | Interpretation |
|---|---|---|
| concavity_mean | 3.49x | Strongest signal — shape irregularity |
| concave_points_mean | 3.42x | Strong signal — nuclear indentation |
| concavity_worst | 2.71x | Strong but weaker than mean version |
| area_worst | 2.54x | Size matters most at extremes |
| area_mean | 2.11x | Moderate size signal |
| fractal_dimension_mean | 1.00x | No signal — boundary complexity alone is uninformative |

---

## Limitations

- This is exploratory analysis, not a predictive model. Ratios and variance comparisons do not account for feature correlations — many of these features are highly collinear (radius, perimeter, and area, for example, are mathematically related).
- The dataset originates from a single institution (University of Wisconsin) and may not generalize across imaging equipment, biopsy technique, or patient populations.
- 569 records is sufficient for exploratory analysis but small by modern standards.
