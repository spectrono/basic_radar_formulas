# Basic Radar Formulas

An R-based collection of radar formulas, equations, visualizations, and demonstrations. The project is intended to make fundamental radar and sensor-fusion concepts easier to explore through executable examples and small applications.

---

## Topics

### 1. FMCW Radar Range Estimation

**Description:** Estimate target range from beat frequencies in a Frequency Modulated Continuous Wave (FMCW) radar system.

**R Files:**
- [`demo_range_estimation.R`](demo_range_estimation.R) — Self-contained demonstration calculating range from beat frequencies

**Theory:**

FMCW radar transmits a frequency-modulated chirp signal. When the signal reflects off a target, the received signal mixes with the transmitted signal, producing a beat frequency that is proportional to the target's range.

**Key Components:**
- **Sweep Bandwidth (B_sweep):** The bandwidth of the chirp, determining range resolution. For a desired range resolution ΔR: B_sweep = c / (2 × ΔR)
- **Chirp Time (T_chirp):** Duration of one frequency sweep. For FMCW systems, T_chirp should be at least 5-6 times the round-trip time to the maximum range. This example uses factor 5.5: T_chirp = 5.5 × 2 × R_max / c
- **Beat Frequency (f_b):** The frequency difference between transmitted and received signal, directly related to target range

**Derivations:**

1. **Range Resolution:** The minimum distinguishable range difference is determined by the sweep bandwidth:
   
   ΔR = c / (2 × B_sweep)
   
   Rearranged to solve for required bandwidth:
   
   B_sweep = c / (2 × ΔR)

2. **Chirp Time:** Based on the time for the signal to travel to the maximum range and back:
   
   T_chirp = factor × 2 × R_max / c
   
   where factor = 5.5 ensures the chirp duration is sufficient for the signal to travel to R_max and return.

3. **Beat Frequency to Range:** The relationship between beat frequency and target range:
   
   f_b = (2 × B_sweep × R) / (c × T_chirp)
   
   Solving for range:
   
   R = (f_b × c × T_chirp) / (2 × B_sweep)

**Usage with VS Code:**

1. Open this repository in Visual Studio Code
2. Install the [R extension](https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r) for syntax highlighting and IntelliSense
3. Open `demo_range_estimation.R`
4. Use the VS Code debugger (F5) or run the script directly with `source('demo_range_estimation.R')` in the R terminal
5. View the calculated ranges printed in the console

**Example Output:**
For beat frequencies [0 MHz, 1.1 MHz, 13 MHz, 24 MHz] with R_max = 300 m and R_res = 1 m:
- Target 1: f_b = 0.0 MHz → Range = 0.000 m
- Target 2: f_b = 1.1 MHz → Range = 4.033 m
- Target 3: f_b = 13.0 MHz → Range = 47.667 m
- Target 4: f_b = 24.0 MHz → Range = 88.001 m

---

### Template for New Topics

**Description:** Brief explanation of the topic

**R Files:**
- [`file_name.R`](file_name.R) — Description of what the script demonstrates

**Theory:**

Explanation of the radar concept or formula being demonstrated.

**Key Components:**
- Component 1: Description
- Component 2: Description

**Derivations:**

Mathematical derivations showing how formulas are derived from first principles.

**Usage:**

Instructions for running the demonstration.

---

## Planned topics

- Radar range, velocity, and angle relationships
- Doppler shift and radial velocity
- Coordinate transformations and sensor geometry
- Visual demonstrations of radar measurements
- Small applications that combine the formulas

## Getting started

Install a recent version of [R](https://cran.r-project.org/) and run the examples from an R session or an R-compatible IDE such as [RStudio](https://posit.co/download/rstudio-desktop/) or [Visual Studio Code](https://code.visualstudio.com/) with the R extension.

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.