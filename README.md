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

---

### 2. Doppler Effect - Velocity Estimation

**Description:** Calculate target velocity from Doppler frequency shifts in radar systems.

**R Files:**
- [`demo_doppler_velocity.R`](demo_doppler_velocity.R) — Self-contained demonstration calculating velocity from Doppler frequency shifts

**Theory:**

The Doppler effect describes the shift in frequency of a wave for an observer moving relative to its source. In radar systems, the Doppler frequency shift of the returned signal is directly proportional to the radial velocity of the target.

When a radar transmits a signal at frequency f0, the received signal from a moving target exhibits a frequency shift fd (Doppler shift). For a monostatic radar (transmitter and receiver co-located), the relationship is: fd = 2 × vr / λ, where vr is the radial velocity and λ is the wavelength.

**Key Components:**
- **Operating Frequency (f0):** The transmission frequency of the radar (77 GHz in this example)
- **Wavelength (λ):** The wavelength of the transmitted signal, calculated as λ = c / f0
- **Doppler Shift (fd):** The frequency difference between transmitted and received signal, directly related to target velocity
- **Radial Velocity (vr):** The component of target velocity along the radar line-of-sight

**Derivations:**

1. **Wavelength:** The distance the wave travels in one period:
   
   λ = c / f0

2. **Doppler Shift to Velocity:** The fundamental relationship for monostatic radar:
   
   fd = 2 × vr / λ
   
   Rearranged to solve for velocity:
   
   vr = (fd × λ) / 2

3. **Alternative Form:** Substituting λ = c / f0 into the velocity formula:
   
   vr = (fd × c) / (2 × f0)
   
   This shows the linear relationship between Doppler shift and velocity.

**Example Output:**
For Doppler frequency shifts [3 kHz, -4.5 kHz, 11 kHz, -3 kHz] with f0 = 77 GHz:
- Target 1: fd = +3.0 kHz → Velocity = +5.844 m/s (+21.039 km/h, approaching)
- Target 2: fd = -4.5 kHz → Velocity = -8.766 m/s (-31.558 km/h, receding)
- Target 3: fd = +11.0 kHz → Velocity = +21.429 m/s (+77.143 km/h, approaching)
- Target 4: fd = -3.0 kHz → Velocity = -5.844 m/s (-21.039 km/h, receding)

**Usage with VS Code:**

1. Open this repository in Visual Studio Code
2. Install the [R extension](https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r) for syntax highlighting and IntelliSense
3. Open either `demo_range_estimation.R` or `demo_doppler_velocity.R`
4. Use the VS Code debugger (F5) or run the script directly with `source('demo_range_estimation.R')` or `source('demo_doppler_velocity.R')` in the R terminal
5. View the calculated results printed in the console

**Example Output:**
For beat frequencies [0 MHz, 1.1 MHz, 13 MHz, 24 MHz] with R_max = 300 m and R_res = 1 m:
- Target 1: f_b = 0.0 MHz → Range = 0.000 m
- Target 2: f_b = 1.1 MHz → Range = 12.100 m
- Target 3: f_b = 13.0 MHz → Range = 143.000 m
- Target 4: f_b = 24.0 MHz → Range = 264.000 m

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
- Coordinate transformations and sensor geometry
- Visual demonstrations of radar measurements
- Small applications that combine the formulas

## Getting started

Install a recent version of [R](https://cran.r-project.org/) and run the examples from an R session or an R-compatible IDE such as [RStudio](https://posit.co/download/rstudio-desktop/) or [Visual Studio Code](https://code.visualstudio.com/) with the R extension.

This project is licensed under the GNU General Public License v3.0. See [LICENSE](LICENSE) for details.