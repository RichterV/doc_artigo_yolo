# 8 · Paired statistics

**Script:** `linux/comparacao/4_comparacao_estatistica_rgb_degradado.py`

**Reference model:** spatially harmonized broadband RGB (`RGB_degradado`). Every alternative is compared with it on the same observations.

```bash
cd linux/comparacao
python 4_comparacao_estatistica_rgb_degradado.py \
  --rgb-degradado predicoes_RGB_degradado.csv \
  --comparados predicoes_RGB.csv predicoes_MS_RGB.csv predicoes_CCCI.csv predicoes_PSRI.csv \
  --nomes RGB MS_RGB CCCI PSRI \
  --bootstrap 10000 --seed 153 --tol 0.01 \
  --outdir resultados_comparacao_rgb_degradado
```

The items in `--nomes` must match the `pred_<nome>` column of each CSV, in the same order as `--comparados`. Runtime is roughly 6 min per comparison on a laptop CPU (about 25 min in total), almost all of it in the bootstrap.

## Pairing { #pairing }

For each alternative:

1. **By `sample_id`:** inner join with `validate="one_to_one"`. The script aborts if any joined pair has a different true class.
2. **Fallback, if no ID matches:** spatial matching.
    - candidates are pairs **of the same true class** within Euclidean distance `--tol` (0.01 m = 1 cm in EPSG:32721);
    - candidates are sorted by distance and matched greedily 1:1.

The summary sheet (`Resumo_pareamento`) records the method, the number of pairs and the distance statistics. **Every comparison must report `n_pareado = 571`.**

## Metrics

Computed with scikit-learn on string labels, over the paired set:

| Symbol | Definition | Code |
|---|---|---|
| OA | \(\frac{1}{n}\sum_i \mathbb{1}[\hat y_i = y_i]\) | `accuracy_score` |
| BA | \(\frac{1}{K}\sum_k \mathrm{Recall}_k\) | `balanced_accuracy_score` |
| Macro-F1 | \(\frac{1}{K}\sum_k F1_k\), K = 4 | `f1_score(average="macro", labels=CLASS_NAMES)` |
| Weighted-F1 | \(\sum_k \frac{n_k}{n} F1_k\) | `f1_score(average="weighted")` (reported descriptively) |
| Precision/Recall/F1 of class k | one-vs-rest binary scores | `precision_score`, `recall_score`, `f1_score` on `y == k` |

The paired effect for a metric \(M\) is

\[
\Delta M = M_{\text{alt}} - M_{\text{hRGB}},
\]

so \(\Delta M<0\) means the alternative is **worse** than harmonized RGB. The point estimate is the **observed** difference on the 571 observations.

## Paired, class-stratified bootstrap

```python
rng = np.random.default_rng(153)
for b in range(10_000):
    idx = concat([rng.choice(idx_k, size=len(idx_k), replace=True) for k in classes])
    #  ↑ resample WITHIN each true class → class counts fixed at 85/18/231/237
    ΔM[b] = M(y[idx], pred_alt[idx]) - M(y[idx], pred_ref[idx])   # same idx for both models
CI95 = percentile(ΔM, [2.5, 97.5])
```

Resampling indices, rather than each model's predictions separately, **keeps the pairing**. Stratifying by class keeps the class composition of every replicate equal to that of the observed set. The inferential endpoints are OA, BA, Macro-F1 and the F1 of the stressed, dead and healthy classes. Soil/residue F1 is only descriptive.

A 95 % CI that excludes 0 is read as a consistently directional difference.

## Exact McNemar test

For a correctness outcome, with the reference first:

- \(b\) = observations **correct with harmonized RGB, wrong with the alternative**
- \(c\) = observations **wrong with harmonized RGB, correct with the alternative**

Under \(H_0\) of symmetric discordance, \(b \sim \text{Binomial}(b+c,\ 0.5)\):

```python
p = binomtest(min(b, c), n=b + c, p=0.5, alternative="two-sided").pvalue   # p = 1 if b + c = 0
```

Correctness outcomes computed per alternative:

| Scope | Correct means… |
|---|---|
| Global | `pred == true` |
| Class k (one-vs-rest) | `(pred == k) == (true == k)`, i.e. the binary *k vs not-k* decision is right |

## Holm correction

Holm's step-down procedure over the family of tests: sort the *m* p-values in ascending order, then take \(p^{adj}_{(i)}=\max_{j\le i}\min\{1,(m-j+1)\,p_{(j)}\}\). Significance is \(p^{adj} < 0.05\).

**The family in the paper has 16 tests:** 4 alternatives × {global, stressed, dead, healthy}.

### P4 · Restrict the Holm family to the 16 pre-specified tests

As delivered, the script also computes one-vs-rest McNemar for **soil/residue** and includes it in the Holm family, giving **20** tests. To match the paper, keep the soil rows as descriptive and adjust only the 16:

```python title="4_comparacao_estatistica_rgb_degradado.py, in main(), replace the Holm block"
mcn_all = pd.concat(all_mcnemar, ignore_index=True)

familia = mcn_all["classe"] != "solo_residuos"          # 16 pre-specified tests
mcn_all["p_holm"] = np.nan
mcn_all.loc[familia, "p_holm"] = holm_adjust(
    mcn_all.loc[familia, "p_exato"].to_numpy()
)
```

For the shipped predictions the global conclusions are the same under both families, because every global test is either p < 0.001 or p = 1. **One class-level conclusion does change:** narrowband RGB vs harmonized RGB on the *dead* class has Holm p = 0.063 with 20 tests and **0.044 with 16 tests**. See [Expected results](09-expected-results.md#mcnemar-tests-all-16-holm-16).

## Outputs (`--outdir`)

| File / sheet | Content |
|---|---|
| `comparacao_estatistica_RGB_degradado.xlsx` | sheets `Pares_*`, `Bootstrap_*`, `McNemar_*` per alternative + the three summaries |
| `resumo_bootstrap_RGB_degradado.csv` | one row per (comparison, metric): `RGB_degradado`, alternative value, `delta_*_menos_RGB_degradado`, `IC95_inf`, `IC95_sup` |
| `resumo_McNemar_RGB_degradado.csv` | one row per test: `b`, `c`, `p_exato`, `p_holm` |
| `resumo_pareamento_RGB_degradado.csv` | pairing method, n, distances |
| `pares_RGB_degradado_<nome>.csv` | the matched pairs |

Table 4 in the paper comes from `resumo_bootstrap` (Δ and CI) and `resumo_McNemar` (global `p_holm`). The native-RGB column of Table 3 comes from the `RGB` values of `Bootstrap_RGB`.
