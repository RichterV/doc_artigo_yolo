# File formats

## Patch arrays

| File | dtype | Shape | Notes |
|---|---|---|---|
| `X_context_32_<fs>.npy` | float32 | `(n, 32, 32, C)` | channels-last; RGB in [0, 1], indices raw |
| `Y_labels_32_<fs>.npy` | float32 | `(n, 4)` | one-hot in `CLASS_NAMES` order |

## Samples CSV

Row *i* describes sample *i* of `X`/`Y`.

| Column | RGB `samples_32.csv` | Index `samples_32_<raster>.csv` |
|---|---|---|
| `sample_id` | — (rebuilt at export) | ✓ |
| `classe` | ✓ | ✓ |
| `label` | ✓ | ✓ |
| `fid` | ✓ (row index in the shapefile) | ✓ |
| `x`, `y` | ✓ (raster CRS) | ✓ |
| `raster` | — | ✓ |

## Normalisation JSON

```json
{
  "metodo": "percentile_stretch",
  "percentis": [2.0, 98.0],
  "canais": {
    "R": {"p_low": 0.0, "p_high": 0.0},
    "G": {"p_low": 0.0, "p_high": 0.0},
    "B": {"p_low": 0.0, "p_high": 0.0}
  },
  "raster_set": "drone_rgb",
  "script_version": "..."
}
```

## Prediction CSV { #prediction-csv }

One row per validation observation. `<m>` is the model name (`RGB`, `RGB_degradado`, `MS_RGB`, `CCCI`, `PSRI`).

| Column | Meaning |
|---|---|
| `sample_id` | observation key used for pairing |
| `classe`, `label`, `fid`, `x`, `y` (`raster`) | copied from the samples CSV |
| `classe_real_id`, `classe_real` | true class index / name |
| `pred_<m>`, `pred_<m>_id` | predicted class name / index (argmax) |
| `conf_<m>` | max probability |
| `prob_<m>_estressadas` … `prob_<m>_solo_residuos` | softmax output |

The shipped `linux/comparacao/predicoes_CCCI.csv` uses `;` as separator. The statistics script auto-detects the separator (`sep=None`).
