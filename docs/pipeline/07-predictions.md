# 7 · Validation predictions

The goal of this step is **one CSV per representation**, with one row per validation observation. Each row holds the true class, the predicted class and the four softmax probabilities. Step 8 needs nothing else.

## Prerequisite: extract the validation patches

In each folder, set `modo: validacao` and rerun the extraction script ([step 4](04-patch-extraction.md)). This writes `context_data_validation/X_context_32_<fs>.npy`, `Y_labels_32_<fs>.npy` and the samples CSV, normalised with the **training** parameters.

## Export per-observation predictions

=== "RGB-like representations"

    `5_exportar_predicoes.py` (in `rgb_drone/` and `rgb_degradado/`) and `5_exportar_predicoes_ms_rgb.py` (in `rgb_micasense/`) are the same script. They differ only in the default `--nome`.

    ```bash
    # --nome sets the column suffix: RGB | RGB_degradado | MS_RGB
    python 5_exportar_predicoes.py \
      --nome    RGB_degradado \
      --model   context_models/rgb/best_model_32_rgb.keras \
      --x       context_data_validation/X_context_32_rgb.npy \
      --y       context_data_validation/Y_labels_32_rgb.npy \
      --samples context_data_validation/samples_32.csv \
      --outdir  predicoes_individuais \
      --batch-size 128
    ```

    The script refuses to run unless `len(X) == len(Y) == len(samples)`. Because extraction writes all three in the same order, row *i* of the CSV is sample *i* of X.

=== "CCCI / PSRI"

    `IVs/3_exportar_predicoes_com_matriz.py` takes no arguments. It looks for:

    ```text
    context_models/{CCCI,PSRI}_recortado/best_model_32_{CCCI,PSRI}_recortado.keras
    context_data_validation/X_context_32_*.npy, Y_labels_32_*.npy, samples_32_*.csv
    ```

    ```bash
    cd linux/IVs && python 3_exportar_predicoes_com_matriz.py
    ```

    Besides the predictions, it writes the confusion matrix (`matriz_confusao_<n>.xlsx`, `confusion_matrix_percent_<n>.png`) and the per-class and global metrics (`metricas_<n>.xlsx`, `metricas_globais_<n>.csv`).

### Column names must match step 8

The statistics script finds predictions by the column name **`pred_<nome>`**. Use these names:

| Representation | `--nome` | File |
|---|---|---|
| Native RGB | `RGB` | `predicoes_RGB.csv` |
| Harmonized RGB (reference) | `RGB_degradado` | `predicoes_RGB_degradado.csv` |
| Narrowband RGB | `MS_RGB` | `predicoes_MS_RGB.csv` |
| CCCI | `CCCI` (fixed) | `predicoes_CCCI.csv` |
| PSRI | `PSRI` (fixed) | `predicoes_PSRI.csv` |

### What the export computes

```python
probs  = model.predict(X, batch_size=128)
y_true = argmax(Y, axis=1)
y_pred = argmax(probs, axis=1)     # no threshold, no calibration
conf   = max(probs, axis=1)
```

The column layout is described in [File formats](../reference/file-formats.md#prediction-csv).

## Optional: quick metric check (RGB)

`3_predict.py` evaluates every feature set in the config on the validation arrays. It writes `metrics/metrics_resumo_completo.xlsx`, with per-class accuracy, precision, recall and F1 plus absolute and row-normalised confusion matrices, and PNG heatmaps under `metrics/confusion_matrices/`. It also writes `best_model_selection.json`, which only the [mapping extra](../extras/mapping.md) uses. The paired comparison does not depend on this script.

!!! warning "Native RGB is evaluated on 571, not 589"
    Metrics that `3_predict.py` prints for native RGB use all 589 valid patches. The paper's Table 3 values for native RGB come from the **571 paired** observations, which step 8 computes.
