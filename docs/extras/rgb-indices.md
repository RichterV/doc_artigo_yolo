# RGB vegetation indices

`bands_indices.calcular_indices_rgb` computes eight visible-band indices on the **chromatic coordinates** \(r=R/(R+G+B)\), \(g=G/(R+G+B)\) and \(b=B/(R+G+B)\). Divisions with \(|den| \le 10^{-6}\) return 0.

| Key | Formula |
|---|---|
| `exg` | \(2g - r - b\) |
| `exr` | \(1.4r - g\) |
| `exgr` | \(\mathrm{ExG} - \mathrm{ExR}\) |
| `vari` | \((g-r)/(g+r-b)\) |
| `gli` | \((2g-r-b)/(2g+r+b)\) |
| `ngrdi` | \((g-r)/(g+r)\) |
| `rgbvi` | \((g^2-rb)/(g^2+rb)\) |
| `mgrvi` | \((g^2-r^2)/(g^2+r^2)\) |

In `rgb_drone/config.yml` the feature set `ivs` (8 channels, indices only) and `rgb_ivs` (11 channels) can be trained next to `rgb`. Each index channel gets its own percentile 2–98 stretch. When several feature sets are trained, `3_predict.py` selects a "winner" by the mean F1 of stressed and dead (`f1_doentes`), with balanced accuracy as the tie-breaker.

For the paper, use `executar: [rgb]`.
