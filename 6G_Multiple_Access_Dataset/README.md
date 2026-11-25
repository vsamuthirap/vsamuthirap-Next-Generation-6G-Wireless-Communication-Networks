# Performance Evaluation and Optimization of Advanced Multiple Access Techniques for Next-Generation 6G Wireless Networks

Simulation code, result CSVs and charts for comparing **OFDMA, NOMA, SCMA, PDMA** and the proposed **CA-HMRA** (Channel-Aware Hybrid Multiple Access and Resource Allocation).

> **Note:** This is a comparative system-level simulation with explicit simplified assumptions (BPSK/AWGN BER, Rayleigh outage, assumed link-gain, interference and power parameters). It is not a standards-compliant 6G physical-layer simulator; results must not be described as measured or real-world data.

## Repository structure
| Path | Content |
|---|---|
| `6G_Multiple_Access_Simulation.m` | Base-MATLAB simulation script (seed `rng(10)`) |
| `OFDMA/`, `NOMA/`, `SCMA/`, `PDMA/`, `CA-HMRA/` | Per-algorithm BER, throughput and outage charts |
| `benchmark charts/` | Combined comparison figures (BER, throughput, spectral efficiency, energy efficiency, outage) |
| `<Algorithm>_sim results.csv` | All metrics for one algorithm (tidy format: Metric, X_Variable, X_Value, Value) |
| `BER_Results.csv`, `Throughput_Results.csv`, `Spectral_Efficiency_Results.csv`, `Energy_Efficiency_Results.csv`, `Outage_Probability_Results.csv` | Comparison tables for all algorithms |
| `Best_Algorithm_Summary.csv`, `Combined_comparison.csv` | Best performer per metric / reference-point comparison |

## Simulation settings
Bandwidth 20 MHz; BER SNR 0-30 dB (step 5), 10 users; operating SNR 10 dB; users 5-40; reference load 20 users; outage threshold 0 dB, average SNR 0/5/10/15 dB.

## Key results (10 dB SNR, 20 users)
| Algorithm | BER @10 dB | Throughput (Mbps) | Spectral eff. (bit/s/Hz) | Energy eff. (Mbit/J) | Outage @10 dB |
|---|---|---|---|---|---|
| OFDMA | 0.00119 | 33.93 | 1.848 | 2.262 | 0.1947 |
| NOMA | 0.000251 | 39.25 | 2.138 | 2.364 | 0.1523 |
| SCMA | 0.000294 | 38.57 | 2.101 | 2.457 | 0.1558 |
| PDMA | 0.000444 | 37.25 | 2.029 | 2.403 | 0.1656 |
| CA-HMRA | 1.58e-07 | 61.85 | 3.369 | 4.355 | 0.0736 |

CA-HMRA gives the best value in all five metrics under the stated model assumptions.

## Reproduce
Run `6G_Multiple_Access_Simulation.m` in MATLAB (no toolboxes). It regenerates the CSV tables and PNG figures.

## License
MIT - see `LICENSE.md`.
