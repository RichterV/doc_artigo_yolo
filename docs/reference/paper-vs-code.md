# Paper vs. code

This guide treats the **published method as the reference**. The table lists every place where the delivered scripts differ from it, or where the paper leaves out a detail that reproduction needs. Apply the patches marked **P** before reproducing.

## Differences that need a patch

| ID | Topic | Paper | Delivered code | Fix |
|---|---|---|---|---|
| **P1** | 70/30 split | stratified | `IVs/2_train_multi_controlado.py`: stratified. `rgb_*/2_train.py`: **not** stratified | add `stratify=np.argmax(Y, axis=1)` ([step 6](../pipeline/06-training.md#p1-stratified-split-rgb-scripts)) |
| **P2** | Class balancing | oversampling with replacement, fitting subset only | **absent** in all training scripts | add `oversample_with_replacement` after the split ([step 6](../pipeline/06-training.md#p2-oversample-the-fitting-subset)) |
| **P3** | Seeded augmentation | "fixed random seed" | `datagen.flow(...)` unseeded in the RGB scripts, seeded in IVs | pass `seed=seed_value` ([step 6](../pipeline/06-training.md#p3-seeded-augmentation-stream-rgb-scripts)) |
| **P4** | Holm family | 16 tests (4 alternatives × global, stressed, dead, healthy) | 20 tests (adds soil one-vs-rest) | adjust only the 16 ([step 8](../pipeline/08-statistics.md#p4-restrict-the-holm-family-to-the-16-pre-specified-tests)) |
| **P5** | Development set | 3,818 points | `dados/treino/*.shp` in this repository: 2,991 points | use the final training shapefiles ([Input data](../getting-started/data.md)) |
| **P6** | Missing module | — | `rgb_drone/` and `rgb_degradado/` import `bands_indices` without containing it | copy `rgb_micasense/bands_indices.py` |
| **P7** | Hard-coded paths | — | `harmonize_rgb_to_rededge_explicit.py` uses `/home/sally/...` | edit the constants at the top |

## Details the paper does not state (taken from the code)

| Topic | What the code does |
|---|---|
| Random seed | **153** everywhere. Section 2.10 of the paper also mentions 42, but no script uses it. |
| Input scaling, RGB | per-channel 2nd–98th percentile stretch to [0, 1], fitted on a ≤ 1 Mpx subsample of each representation's own raster, in training mode only ([step 4](../pipeline/04-patch-extraction.md#normalisation-rgb-like-inputs)) |
| Input scaling, CCCI/PSRI | none; raw index values |
| Patch validity | discard if the window leaves the raster, contains NaN/nodata or (RGB) any pixel with R = G = B = 0 |
| ReduceLROnPlateau patience | 10 epochs |
| Dropout position | after the BN that follows the first convolution of each block |
| Head | Flatten of node X0,3 only; the paper's Fig. 3 also draws an X1,3 node, which is not implemented |
| Per-class McNemar | one-vs-rest correctness `(pred == k) == (true == k)` over all 571 observations |
| Pairing fallback | spatial, same class, ≤ 1 cm, greedy 1:1. Used for native RGB, whose CSV has rounded coordinates |
| Bootstrap point estimate | observed Δ on the full paired set; the CI comes from percentiles of the bootstrap distribution |
| Native RGB sample size | 589 valid patches, of which 571 are paired. Table 3 reports the paired 571 |

## Cosmetic notes

- The docstring of the statistics script says `--nomes RGB_original ...`. Both `RGB` and `RGB_original` work, because the script renames the single `pred_*` column. `RGB` gives clearer column names.
- `2_train.py` in `rgb_micasense/` writes `comparacao_treinamento_modelos.xlsx`, while the other RGB folders write `comparacao_treinamento_rgb_ivs.xlsx`. The model is unaffected.
- In the delivered `rgb_micasense/`, `rgb_degradado/` and `IVs/` configs, `modo` is set to `validacao`. Remember to switch it to `treino` first.
