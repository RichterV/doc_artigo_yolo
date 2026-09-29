# Explainability (XAI)

Both scripts target the **native RGB** model and its **589** validation patches.

## `7xai_rgb_integrated.py`

Edit the constants at the top, then run it from `rgb_drone/`:

| Constant | Value | Meaning |
|---|---|---|
| `FEATURE_SET`, `CONTEXT_SIZE` | `rgb`, 32 | model `context_models/rgb/best_model_32_rgb.keras` |
| `GRADCAM_LAYER_NAME` | `conv2d_17` | layer used for Grad-CAM (`None` = last Conv2D) |
| `HIGH_ACTIVATION_THRESHOLD` | 0.50 | pixel counted as "strongly activated" |
| `BORDER_FRACTION` | 0.25 | periphery width for the centre/periphery ratio |
| `IG_STEPS`, `IG_BASELINE` | 64, `zeros` | Integrated Gradients settings |
| `N_CORRECT_PER_CLASS`, `N_ERRORS_PER_CLASS` | 5, 5 | representative figures saved |
| `OUTPUT_ROOT` | `xai_rgb_conv2d_17_final` | output folder |

For every validation sample it computes:

- **Grad-CAM metrics:** mean, sd and max activation; proportion ≥ 0.5; centre and periphery means and their ratio; activation centre of mass; share in the top-10 % of pixels.
- **IG channel attribution:** relative (%) and signed contribution of R, G and B, plus the dominant channel.

The results are merged into `dados/xai_completo_gradcam_ig_589.csv`, and figures are saved for representative correct and incorrect cases per class.

## `8_estatistica_xai_rgb.py`

Set `INPUT_FILE` to that CSV. The script runs:

1. **Friedman** test of R vs G vs B IG shares within each class (correct predictions only), followed by pairwise **Wilcoxon** tests with Holm correction and rank-biserial effect sizes.
2. **Correct vs error:** Mann–Whitney U with Holm correction and rank-biserial r. Classes with fewer than 5 errors are reported descriptively only.
3. **Dominant channel × correctness:** exact Fisher–Freeman–Halton test on the 2 × 3 table, with Holm correction across classes.

Outputs go to `estatistica/` as CSV files and one consolidated Excel file.
