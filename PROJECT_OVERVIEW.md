# Project Overview

## Introduction

This project studies and compares advanced multiple access techniques for next-generation 6G wireless communication networks. It implements a reproducible MATLAB simulation that evaluates OFDMA, NOMA, SCMA, PDMA, and the proposed Channel-Aware Hybrid Multiple Access and Resource Allocation (CA-HMRA) approach.

## Objectives

- Compare traditional and advanced multiple access techniques.
- Analyze BER, throughput, spectral efficiency, energy efficiency, and outage probability.
- Demonstrate a hybrid channel-aware resource-allocation concept.
- Generate tables and charts suitable for academic reports and presentations.
- Keep the simulation open, understandable, and reproducible.

## Proposed CA-HMRA Concept

CA-HMRA is modeled as a channel-aware hybrid strategy with:

- High assumed access efficiency.
- Positive effective link gain.
- Lower residual multi-user interference.
- Reduced modeled power per active user.
- Better resource allocation under the reference operating conditions.

The proposed method is a conceptual system-level model, not a complete 6G standard implementation.

## Methodology

The MATLAB script creates a common test configuration for all algorithms. It calculates BER with BPSK over an equivalent AWGN link, throughput using bandwidth and Shannon-style spectral efficiency, energy efficiency using aggregate throughput and modeled power, and outage probability using a Rayleigh-fading expression.

Algorithm-specific parameters are used to represent relative access efficiency, link gain, interference, and power behavior. The resulting datasets and figures are exported automatically.

## Limitations

- It is a comparative simulation rather than hardware or channel-measurement data.
- BPSK/AWGN assumptions are simplified.
- Rayleigh outage modeling is not a complete 6G channel model.
- Link gain and interference coefficients are scenario parameters rather than measured constants.
- Results may not generalize to every 6G deployment.

## Intended Use

Suitable for:

- Undergraduate or postgraduate coursework.
- Simulation-based academic demonstrations.
- Comparative visualization of multiple access concepts.
- A starting point for more detailed PHY/MAC-level research.
