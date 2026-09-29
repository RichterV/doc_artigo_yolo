# Pipeline overview

The experiment has nine steps. Steps 1–3 prepare data and are done once. Steps 4–7 are repeated **once per representation**, with identical parameters. Step 8 compares the five sets of predictions.

| Step | What | Tooling | Main output |
|---|---|---|---|
| [1](01-imagery.md) | Photogrammetric processing of the RGB and RedEdge-MX flights | Metashape | Orthomosaics (EPSG:32721) |
| [2](02-representations.md) | Build the five representations | `harmonize_rgb_to_rededge_explicit.py`, QGIS | 5 raster sets |
| [3](03-reference-data.md) | Reference points and development/validation split | QGIS | 8 point shapefiles |
| [4](04-patch-extraction.md) | Extract 32 × 32 patches around every point | `1_extract_*.py` | `X_context_32_*.npy`, `Y_labels_32_*.npy` |
| [5](05-model.md) | U-Net++ patch classifier (identical architecture) | `2_train*.py` | — |
| [6](06-training.md) | Train with the common protocol | `2_train*.py` | `best_model_32_*.keras` |
| [7](07-predictions.md) | Predict the 571 validation observations | `3_*.py`, `5_exportar_*.py` | `predicoes_*.csv` |
| [8](08-statistics.md) | Paired bootstrap, McNemar, Holm | `4_comparacao_estatistica_rgb_degradado.py` | `.xlsx` / `.csv` tables |
| [9](09-expected-results.md) | Check against the paper | — | Tables 3–4, Fig. 6 |

## Invariants: what must be identical across the five models

Treat these as the controlled variables of the experiment. Changing any one of them for a single representation invalidates the comparison.

| Invariant | Value |
|---|---|
| Patch size | 32 × 32 pixels, centred on the point |
| Architecture | U-Net++ classifier ([step 5](05-model.md)) |
| Loss / optimiser | categorical cross-entropy / Adam, lr = 1 × 10⁻⁴ |
| Batch size / max epochs | 16 / 5,000 |
| Early stopping | `val_loss`, patience 30, restore best weights |
| LR schedule | ReduceLROnPlateau(factor 0.5, patience 10, min_lr 1 × 10⁻⁶) |
| Split | stratified 70/30, `random_state = 153` |
| Class balancing | oversampling with replacement, **fitting subset only** |
| Augmentation | rotation ≤ 20°, zoom 0.2, horizontal flip |
| Validation set | the same 571 observations, paired by `sample_id` / coordinates |

**What is allowed to change:** only the spectral content and the number of input channels (3 for the RGB-like inputs, 1 for CCCI and PSRI). A consequence of the fixed pixel size is that the **ground footprint** also changes with GSD: 1.04 m for native RGB and 2.69 m for everything else.
