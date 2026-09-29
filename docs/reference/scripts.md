# Scripts

Every script expects to run from **its own folder**, the one that contains `config.yml`.

## Paper pipeline

| Folder | Script | Step | Reads | Writes |
|---|---|---|---|---|
| `rgb_degradado` | `harmonize_rgb_to_rededge_explicit.py` | [2](../pipeline/02-representations.md) | native RGB bands, one RE-MX band (grid) | `b*_degradado.tif` |
| `rgb_drone`, `rgb_degradado`, `rgb_micasense` | `1_extract_train_data_from_points.py` | [4](../pipeline/04-patch-extraction.md) | `config.yml`, band rasters, point shapefiles | `context_data*/X_*.npy, Y_*.npy, samples_32.csv`, normalisation JSON |
| same | `2_train.py` | [5–6](../pipeline/06-training.md) | `context_data/` | `context_models/<fs>/best_model_32_<fs>.keras`, `logs/`, `resultados/` |
| same | `3_predict.py` | [7](../pipeline/07-predictions.md) (optional) | `context_data_validation/`, model | `metrics/`, `best_model_selection.json` |
| `rgb_drone`, `rgb_degradado` | `5_exportar_predicoes.py` | [7](../pipeline/07-predictions.md) | model, validation X/Y/samples (CLI) | `predicoes_individuais/predicoes_<nome>.csv/.xlsx` |
| `rgb_micasense` | `5_exportar_predicoes_ms_rgb.py` | [7](../pipeline/07-predictions.md) | same (default `--nome MS_RGB`) | same |
| `rgb_micasense` | `bands_indices.py` | module | — | — (shared helpers; copy into the other RGB folders) |
| `IVs` | `1_extract_multi_com_id.py` | [4](../pipeline/04-patch-extraction.md) | `config_multi_controlado.yml`, `*_recortado.tif`, shapefiles | `context_data*/X_*, Y_*, samples_32_<raster>.csv` |
| `IVs` | `2_train_multi_controlado.py` | [6](../pipeline/06-training.md) | `context_data/` | `context_models/<raster>/best_model_32_<raster>.keras`, `resultados_controlados/` |
| `IVs` | `3_exportar_predicoes_com_matriz.py` | [7](../pipeline/07-predictions.md) | models + validation arrays (fixed paths) | `predicoes_individuais/` predictions, confusion matrices, metrics |
| `comparacao` | `4_comparacao_estatistica_rgb_degradado.py` | [8](../pipeline/08-statistics.md) | 5 prediction CSVs | `resultados_comparacao_rgb_degradado/` |

## Superseded or extra

| Folder | Script | Purpose |
|---|---|---|
| `IVs` | `4_comparacao_estatistica.py` | earlier version of the paired test with **native RGB** as reference (`--rgb`, `--multi`). The paper uses the harmonized-RGB version in `comparacao/`. |
| `rgb_drone`, `rgb_micasense` | `4_pos_processamento_shps.py` | [wall-to-wall mapping](../extras/mapping.md) |
| `rgb_drone` | `7xai_rgb_integrated.py` | [Grad-CAM + Integrated Gradients](../extras/xai.md) |
| `rgb_drone` | `8_estatistica_xai_rgb.py` | [statistics on XAI outputs](../extras/xai.md) |

## Identical copies

These files are byte-identical across folders, so a fix applied to one should go to all of them:

- `1_extract_train_data_from_points.py`: `rgb_drone` = `rgb_micasense`. The `rgb_degradado` copy is a longer rewrite with the same logic that accepts only `executar: [rgb]` and forbids indices.
- `2_train.py`: `rgb_drone` = `rgb_degradado`. `rgb_micasense` differs only in the name of the summary Excel file.
- `3_predict.py`: identical in the three RGB folders.
- `4_pos_processamento_shps.py`: `rgb_drone` = `rgb_micasense`.
- `5_exportar_predicoes*.py`: identical except for the default `--nome`.
