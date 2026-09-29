# 3 · Reference data and splits

## Classes

| Label | Key | Class | Visual criterion (from field assessment) |
|---|---|---|---|
| 0 | `estressadas` | **Stressed** (RMD-symptomatic) | reddish-brown bronzing, reduced canopy density, limited growth |
| 1 | `mortas` | **Dead** | dead crown, foliage absent or fully degraded |
| 2 | `saudaveis` | **Healthy** | green foliage, vigorous and uniform growth |
| 3 | `solo_residuos` | **Soil/residue** | exposed soil or harvest residue between rows |

The reference was built from 32 field-characterised trees (16 healthy, 16 RMD-symptomatic) and then extended by image interpretation together with the company's plantation-health specialist.

## Building the point files (QGIS 3.44)

1. Import the GNSS positions of the field trees and convert them to points in EPSG:32721.
2. Add one point **at the crown centre** of each additional interpreted tree, and one point at each soil/residue location.
3. Make sure no two points of **different** classes are close enough for their 32 × 32 patches to be dominated by the same object.
4. Save **one point shapefile per class and per set** (training / validation), named as listed in [Input data](../getting-started/data.md#reference-point-files).

## Dataset allocation

| Component | n | Role |
|---|---|---|
| Model-development set | **3,818** | 1,794 healthy · 548 stressed · 176 dead · 1,300 soil/residue |
| ↳ fitting subset (70 %) | 2,672 | parameter estimation; the **only** part that is oversampled |
| ↳ internal holdout (30 %) | 1,146 | `val_loss` for early stopping, checkpointing and LR schedule |
| **Independent paired validation set** | **571** | 85 stressed · 18 dead · 231 healthy · 237 soil/residue; never used in fitting |

The 70/30 split is not a separate file. `2_train*.py` creates it in memory with `train_test_split(..., test_size=0.30, random_state=153, stratify=labels)` (see [step 6](06-training.md)). The **validation** set is the separate `dados/validacao/*.shp` files.

!!! info "Validation is within-stand"
    All observations come from stand 017A on one date. The 571 are independent of fitting but are **not** an external or spatial-block validation.

## From 591 points to 571 observations

The validation shapefiles hold 591 points. Extraction discards any point whose 32 × 32 window crosses the raster edge or contains nodata (details in [step 4](04-patch-extraction.md#which-points-are-discarded)):

| Representation | Points in shapefiles | Valid patches |
|---|---|---|
| 8.41 cm inputs (harmonized RGB, narrowband RGB, CCCI, PSRI) | 591 | **571** |
| Native RGB, 3.25 cm | 591 | 589 |

A 2.69 m window reaches further than a 1.04 m window, so more points near the stand boundary are lost at 8.41 cm. The 18 extra native-RGB observations are dropped at the pairing stage ([step 8](08-statistics.md#pairing)), and every comparison uses exactly the same 571 cases.

## Observation identity: `sample_id`

Pairing predictions across models requires a stable identifier:

```python
sample_id = sha1(f"{classe}|{x:.6f}|{y:.6f}".encode()).hexdigest()[:16]
```

`classe` is the class key and `x`, `y` are the point coordinates **in the raster CRS**, with 6 decimals. `IVs/1_extract_multi_com_id.py` writes it into `samples_32_<raster>.csv`. The RGB exporters (`5_exportar_predicoes*.py`) rebuild it from `classe`, `x` and `y` in `samples_32.csv` when it is missing.

!!! warning "Rounded coordinates break the ID"
    If a CSV's coordinates were rounded, for example after passing through a spreadsheet, the hash changes. This is the case for the shipped `predicoes_RGB.csv`, whose coordinates have 4 decimals. The statistics script then falls back to **spatial pairing within 1 cm** and requires the same class, so it still recovers the 571 pairs.
