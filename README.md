# Basic Radar Formulas

An R-based collection of radar formulas, equations, visualizations, and demonstrations. The project is intended to make fundamental radar and sensor-fusion concepts easier to explore through executable examples and small applications. 

This project focuses on **automotive radar applications**, including Adaptive Cruise Control (ACC), Autonomous Emergency Braking (AEB), Blind Spot Detection, and parking assist systems, where radar sensors operating at 77 GHz and 24 GHz are essential for object detection, range estimation, and velocity measurement.

---

## Topics

### 1. FMCW Radar Range Estimation

**Description:** Estimate target range from beat frequencies in a Frequency Modulated Continuous Wave (FMCW) radar system. Essential for automotive applications like Adaptive Cruise Control (ACC) and Autonomous Emergency Braking (AEB).

**R Files:**
- [`src/R/demo_range_estimation.R`](src/R/demo_range_estimation.R) — Self-contained demonstration calculating range from beat frequencies

**Theory:**

FMCW radar transmits a frequency-modulated chirp signal. When the signal reflects off a target, the received signal mixes with the transmitted signal, producing a beat frequency that is proportional to the target's range. In automotive radar systems, FMCW is the dominant architecture due to its ability to simultaneously measure range and velocity with high accuracy using compact, cost-effective hardware.

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

**Practical Context in Automotive Systems:**
In automotive FMCW radar (typically 77 GHz):
- Range estimation enables Adaptive Cruise Control to maintain safe following distances
- High range resolution (1 m in this example) allows detection of close vehicles
- Maximum range of 300 m covers typical highway scenarios for ACC systems
- Beat frequencies in the MHz range correspond to targets at various distances

**Visualizations:**
To ease the understanding of FMCW principles, the demonstration generates explanatory plots showing the signal processing chain:

1. **Transmitted Chirp Signal** (`plots/range_chirp_transmitted.png`):
   - Shows the transmitted chirp waveform in the time domain
   - Visualizes the oscillating signal with linearly increasing frequency
   - Demonstrates the chirp concept before any processing

![][range_chirp_transmitted]

2. **Transmitted Chirp Frequency** (`plots/range_chirp_frequency.png`):
   - Displays the instantaneous frequency of the transmitted chirp
   - Linear sweep from start frequency to start + bandwidth
   - Slope = B_sweep / T_chirp = 150 MHz / 5.5 μs ≈ 27.3 MHz/μs
   - Key insight: This linear frequency modulation is what enables range measurement

![][range_chirp_frequency]

3. **Transmitted vs Received Chirp** (`plots/range_chirp_delay.png`):
   - Compares transmitted (blue) and received (red) chirp instantaneous frequencies
   - Shows the time delay (τ = 2R/c) between transmission and reception
   - For a target at 12.1 m: delay = 0.081 μs
   - The received chirp is a delayed version of the transmitted chirp

![][range_chirp_delay]

4. **Beat Signal Formation** (`plots/range_beat_frequency.png`):
   - Shows the beat signal resulting from mixing transmitted and received chirps
   - Beat frequency f_b = (2 × B_sweep × R) / (c × T_chirp)
   - For target at 12.1 m: f_b ≈ 1.1 MHz (matches input beat frequency)
   - This is the low-frequency signal that contains range information

![][range_beat_frequency]

5. **Beat Frequency vs Range** (`plots/range_beat_vs_range.png`):
   - Scatter plot showing the linear relationship between beat frequency and range
   - Red line: Linear fit f_b = (2 × B_sweep) / (c × T_chirp) × R
   - Each target appears as a point on this line
   - Demonstrates the fundamental FMCW principle: beat frequency is proportional to range

![][range_beat_vs_range]

6. **FMCW Process Overview** (`plots/range_fmcw_process.png`):
   - Six-panel figure showing the complete FMCW range estimation process:
     - Panel 1: Transmitted chirp frequency sweep
     - Panel 2: Received chirp (delayed by τ = 2R/c)
     - Panel 3: Mixing of transmitted and received signals
     - Panel 4: Beat signal (low-frequency result)
     - Panel 5: FFT of beat signal (peak at f_b)
     - Panel 6: Range calculation from beat frequency
   - Provides a complete visual guide to understanding FMCW range estimation

![][range_fmcw_process]

7. **Frequency Difference** (`plots/range_frequency_difference.png`):
   - Shows the **instantaneous frequency difference** between transmitted and received chirps
   - The difference is **constant** over time: f_tx - f_rx = μτ = (B/T_c) × (2R/c)
   - For Target 2 at 12.1 m: constant difference = 1.1 MHz
   - This is the **beat frequency** itself
   - Blue dashed line shows the constant beat frequency value

![][range_frequency_difference]

8. **Signal Mixing Demonstration** (`plots/range_mixing_demo.png`):
   - Three-panel visualization of the mixing process using trigonometric identity: cos(A)×cos(B) = 0.5[cos(A+B) + cos(A-B)]
   - **Top panel**: Transmitted (blue) and received (red) signals at a specific moment in time
     - Shows two cosine waves with slightly different frequencies
   - **Middle panel**: The product (mixed) signal containing both sum and difference frequencies
     - Appears as a high-frequency carrier with a low-frequency envelope
   - **Bottom panel**: The beat signal after filtering out the high-frequency sum component
     - This is the pure cosine at the beat frequency
   - Demonstrates how mixing creates both sum and difference frequencies

![][range_mixing_demo]

9. **Mixing Spectrum** (`plots/range_mixing_spectrum.png`):
   - Shows the four frequency components involved in mixing:
     - Transmitted signal frequency (f_tx)
     - Received signal frequency (f_rx)
     - Sum frequency: f_tx + f_rx (filtered out - too high)
     - Difference frequency: |f_tx - f_rx| = beat frequency (kept for measurement)
   - Visualizes why we get both sum and difference frequencies from mixing
   - Highlights that the beat frequency is the measurable difference component

![][range_mixing_spectrum]

**Key Insight from Visualizations:**
The beat frequency is directly proportional to target range because the time delay τ = 2R/c causes a frequency offset in the received chirp. When mixed with the transmitted chirp, this creates a beat signal whose frequency is f_b = μ × τ = (B/T_c) × (2R/c) = (2BR)/(cT_c). This linear relationship is the foundation of FMCW range measurement.

---


### 2. Doppler Effect - Velocity Estimation

**Description:** Calculate target velocity from Doppler frequency shifts in radar systems.

**R Files:**
- [`src/R/demo_doppler_velocity.R`](src/R/demo_doppler_velocity.R) — Self-contained demonstration calculating velocity from Doppler frequency shifts

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

**Visualizations:**
All demonstration scripts generate and save plots to the `plots/` directory:

1. **Doppler Frequency and Velocity Plot** (`plots/doppler_velocity_plot.png`):
   - Combined visualization showing Doppler frequency shifts and calculated radial velocities
   - Left panel: Bar plot of Doppler frequency shifts for each target
   - Right panel: Bar plot of corresponding radial velocities
   - Color coding: Green bars for approaching targets (positive fd), red bars for receding targets (negative fd)
   - Zero line (blue dashed) indicates the boundary between approaching and receding targets

![][doppler_velocity]

**Usage with VS Code:**

1. Open this repository in Visual Studio Code
2. Install the [R extension](https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r) for syntax highlighting and IntelliSense
3. Open `src/R/demo_range_estimation.R`, `src/R/demo_doppler_velocity.R`, `src/R/demo_fft_signal_analysis.R`, or `src/R/demo_fmcw_radar_chirp.R`
4. Use the VS Code debugger (F5) or run the script directly with `source('src/R/demo_range_estimation.R')`, `source('src/R/demo_doppler_velocity.R')`, `source('src/R/demo_fft_signal_analysis.R')`, or `source('src/R/demo_fmcw_radar_chirp.R')` in the R terminal
5. View the calculated results printed in the console and the generated plots in the `plots/` directory

**Example Output:**
For beat frequencies [0 MHz, 1.1 MHz, 13 MHz, 24 MHz] with R_max = 300 m and R_res = 1 m:
- Target 1: f_b = 0.0 MHz → Range = 0.000 m
- Target 2: f_b = 1.1 MHz → Range = 12.100 m
- Target 3: f_b = 13.0 MHz → Range = 143.000 m
- Target 4: f_b = 24.0 MHz → Range = 264.000 m

---

### 3. Fast Fourier Transform - Signal Frequency Analysis

**Description:** Detect frequency components of signals buried in noise using FFT. Essential for automotive radar signal processing to extract beat frequencies and Doppler shifts from noisy returns.

**R Files:**
- [`src/R/demo_fft_signal_analysis.R`](src/R/demo_fft_signal_analysis.R) — Self-contained demonstration of FFT-based frequency detection in noisy signals

---

### 4. FMCW Radar Chirp Simulation - Automotive Scene

**Description:** Complete FMCW radar system simulation for automotive applications. Models the entire signal processing chain: chirp generation, target reflection, beat signal extraction, range/velocity estimation, and preparation for 2D-FFT. Simulates a realistic automotive scenario with two moving targets (50m at -3m/s and 80m at -7m/s).

**R Files:**
- [`src/R/demo_fmcw_radar_chirp.R`](src/R/demo_fmcw_radar_chirp.R) — Comprehensive FMCW radar simulation with two targets

**Theory:**

FMCW (Frequency Modulated Continuous Wave) radar is the dominant architecture in automotive applications (76-81 GHz). Unlike pulsed radar, FMCW transmits a continuous signal with linearly increasing frequency (chirp). The received signal from a target is a delayed and Doppler-shifted version of the transmitted signal. When mixed with the transmitted signal, the result is a beat signal whose frequency contains information about the target's range and velocity.

The key advantage of FMCW for automotive is its ability to simultaneously measure both range and velocity with high accuracy using a single antenna, making it compact and cost-effective for mass production. The continuous wave nature also provides high Doppler resolution for accurate velocity measurement.

**Key Components:**
- **Carrier Frequency (f₀):** 77 GHz (automotive standard frequency band)
- **Sweep Bandwidth (B):** Determines range resolution (ΔR = c / (2B)). Typical: 100-300 MHz for automotive
- **Chirp Duration (T_c):** Determines maximum unambiguous range (R_max = c × T_c / 2). Typical: 20-200 μs
- **Chirp Slope (μ):** Rate of frequency change (μ = B / T_c). Determines beat frequency for range
- **Transmitted Signal:** s_tx(t) = cos(2π × (f₀t + 0.5μt²)) - Linear FM chirp
- **Received Signal:** s_rx(t) = cos(2π × (f₀(t-τ) + 0.5μ(t-τ)² + f_d×t)) - Delayed with Doppler shift
- **Beat Signal:** s_beat(t) = s_tx(t) × s_rx(t) → Contains range and velocity information

**Derivations:**

1. **Wavelength:**
   
   λ = c / f₀
   
   At 77 GHz: λ = 3e8 / 77e9 = 3.896 mm

2. **Time Delay (Round-trip to target):**
   
   τ = 2R / c
   
   The time for the signal to travel to the target and back

3. **Chirp Slope:**
   
   μ = B / T_c [Hz/s]
   
   Rate at which the frequency increases during the chirp

4. **Doppler Frequency Shift:**
   
   f_d = 2 × v_r × f₀ / c
   
   Frequency shift due to target motion (positive for approaching, negative for receding)

5. **Instantaneous Transmitted Frequency:**
   
   f_tx(t) = f₀ + μ × t
   
   Frequency at time t during the chirp

6. **Instantaneous Received Frequency (from moving target):**
   
   f_rx(t) = f₀ + μ × (t - τ) + f_d
   
   Accounts for time delay τ and Doppler shift f_d

7. **Beat Frequency (from mixing):**
   
   f_b = f_rx(t) - f_tx(t) = μ × τ + f_d
   = (2 × B × R) / (c × T_c) + (2 × v_r × f₀) / c
   
   The beat frequency contains both range (first term) and velocity (second term) information

8. **Range from Beat Frequency (ignoring Doppler for range FFT):**
   
   R = (f_b_range × c × T_c) / (2 × B)
   
   Where f_b_range = μ × τ is the range component of the beat frequency

9. **Velocity from Doppler:**
   
   v_r = (f_d × c) / (2 × f₀)
   
   Direct calculation from Doppler shift

**Scene Setup in This Demonstration:**
- **Radar Parameters:** f₀ = 77 GHz, B = 150 MHz, T_c = 100 μs, fs = 1.5 MHz
- **Target 1:** R₁ = 50 m, v_r₁ = -3 m/s (receding from radar)
- **Target 2:** R₂ = 80 m, v_r₂ = -7 m/s (receding from radar)
- **Scene:** Both targets on the same line-of-sight, moving away from the radar

**Practical Context in Automotive Systems:**

This simulation demonstrates the complete signal processing chain used in automotive FMCW radars for applications including:

1. **Adaptive Cruise Control (ACC):** Maintains safe following distance by measuring range and relative velocity to the vehicle ahead
2. **Autonomous Emergency Braking (AEB):** Detects rapid closure rates (high negative relative velocity) to trigger emergency braking
3. **Blind Spot Detection:** Monitors side and rear areas using multiple radar sensors
4. **Parking Assist:** Short-range detection with high resolution for obstacle avoidance

The 77 GHz frequency band is specifically allocated for automotive radar worldwide, providing good range resolution with compact antenna sizes. The FMCW architecture allows simultaneous measurement of range (from beat frequency) and velocity (from Doppler shift), which is essential for automotive safety systems that need to make real-time decisions.

**Signal Processing Pipeline for FMCW Radar:**

The complete processing chain demonstrated in this script:

1. **Chirp Generation:** Create linear FM signal with frequency sweep from f₀ to f₀+B over T_c
2. **Transmission:** Send chirp via antenna (simulated as instantaneous frequency)
3. **Target Reflection:** Each target reflects signal with delay τ = 2R/c and Doppler shift f_d = 2vf₀/c
4. **Reception:** Receive superposition of reflections from all targets
5. **Mixing:** Multiply received signal with transmitted signal to get beat signal
6. **Beat Signal:** Extract low-frequency beat signal containing range and velocity info
7. **FFT (Range Dimension):** Perform FFT on each chirp to separate targets in range
8. **FFT (Velocity Dimension):** Perform FFT across chirps to separate targets in velocity
9. **2D-FFT:** Combine into range-velocity heatmap for target detection
10. **Target Extraction:** Identify peaks in 2D-FFT corresponding to targets

**Why FMCW for Automotive:**
- Single antenna for transmit and receive (compact, low-cost)
- Simultaneous range and velocity measurement
- High range resolution with moderate bandwidth
- Excellent Doppler resolution for velocity measurement
- Low power consumption (critical for battery-powered vehicles)
- Good clutter rejection (stationary objects have zero Doppler)
- Simple signal processing chain suitable for real-time operation

**Example Output:**
For automotive FMCW radar with f₀ = 77 GHz, B = 150 MHz, T_c = 100 μs:
- Range resolution: 1.00 m
- Maximum unambiguous range: 15.00 km (practically limited by SNR)
- Velocity resolution: 0.13 m/s (depends on number of chirps)
- Target 1: fb₁ ≈ 150.00 kHz → Range ≈ 50.000 m, Velocity ≈ -3.000 m/s
- Target 2: fb₂ ≈ 240.00 kHz → Range ≈ 80.000 m, Velocity ≈ -7.000 m/s

**Visualizations:**
All demonstration scripts generate and save plots to the `plots/` directory:

1. **Transmitted Chirp** (`plots/fmcw_transmitted_chirp.png`):
   - Shows the instantaneous frequency of the transmitted chirp over time
   - Linear sweep from 77.000 GHz to 77.150 GHz over 100 μs
   - Blue line represents the linear frequency modulation
   - Demonstrates the fundamental FMCW principle of frequency sweeping

2. **Chirp Linearity** (`plots/fmcw_chirp_linearity.png`):
   - Highlights the linear nature of the frequency sweep
   - Shows start and end frequencies with markers
   - Slope of 1.5 MHz/μs (B/Tc = 150 MHz / 100 μs)
   - This linearity is critical for accurate range measurement

3. **Received Frequencies** (`plots/fmcw_received_frequencies.png`):
   - Shows transmitted signal (blue dashed) vs received signals from both targets
   - Target 1 (50m): Red line, received with delay of 0.333 μs
   - Target 2 (80m): Green line, received with delay of 0.533 μs
   - Demonstrates how farther targets have greater time delays
   - Vertical lines mark the time delays for each target

4. **Beat Signals** (`plots/fmcw_beat_signals.png`):
   - Shows individual beat signals for each target after mixing
   - Target 1: Beat frequency ≈ 150 kHz (from range component)
   - Target 2: Beat frequency ≈ 240 kHz (from range component)
   - These are the baseband signals used for range estimation

5. **Combined Beat Signal** (`plots/fmcw_combined_beat_signal.png`):
   - Superposition of beat signals from both targets
   - Shows the interference pattern of two different frequency components
   - This is the signal that would be digitized and processed

6. **Scaled Beat Signal** (`plots/fmcw_scaled_beat_signal.png`):
   - Combined beat signal with amplitude scaling based on range (1/R²)
   - Shows how Target 2 (80m) has smaller amplitude than Target 1 (50m)
   - Demonstrates the radar equation effect (signal strength decreases with range)

7. **FFT of Beat Signal** (`plots/fmcw_fft_beat_signal.png`):
   - Frequency spectrum of the combined beat signal
   - Two clear peaks at ≈ 150 kHz and ≈ 240 kHz
   - These peaks correspond to the two targets at 50m and 80m
   - Demonstrates how FFT separates targets in the frequency domain

8. **Scene Visualization** (`plots/fmcw_scene_visualization.png`):
   - Graphical representation of the radar scene
   - Radar at origin (0m) with 77 GHz carrier
   - Target 1 at 50m moving away at -3 m/s
   - Target 2 at 80m moving away at -7 m/s
   - Arrows indicate direction of motion

9. **Signal Processing Chain** (`plots/fmcw_signal_processing_chain.png`):
   - Six-panel overview showing all processing steps
   - Step 1: Transmitted chirp frequency sweep
   - Steps 2-3: Received signals from both targets
   - Steps 4-5: Individual beat signals
   - Step 6: Combined beat signal ready for FFT

10. **Range and Velocity Extraction** (`plots/fmcw_range_velocity_extraction.png`):
    - Left: Bar plot showing estimated ranges vs actual ranges
    - Right: Bar plot showing estimated velocities vs actual velocities
    - Demonstrates accurate extraction of both parameters

11. **2D-FFT Preparation** (`plots/fmcw_2dfft_preparation.png`):
    - Shows phase evolution across multiple chirps
    - The phase shift between chirps encodes velocity information
    - Prepares for the 2D-FFT that creates a range-velocity heatmap

**Usage with VS Code:**

1. Open this repository in Visual Studio Code
2. Install the [R extension](https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r) for syntax highlighting and IntelliSense
3. Open `src/R/demo_fmcw_radar_chirp.R`
4. Use the VS Code debugger (F5) or run the script directly with `source('src/R/demo_fmcw_radar_chirp.R')` in the R terminal
5. View the calculated results printed in the console and the generated plots in `plots/`

**Example Output:**


The Fast Fourier Transform (FFT) is an efficient algorithm to compute the Discrete Fourier Transform (DFT). It decomposes a time-domain signal into its constituent frequency components, which is fundamental for automotive radar signal processing. In modern vehicles, FFT enables real-time processing of radar returns to detect targets, analyze their motion, and make critical driving decisions.

For a signal x(t) sampled at frequency fs with N samples, the FFT computes X[k] for k = 0, 1, ..., N-1, where each X[k] represents the amplitude and phase of a specific frequency component.

**Key Components:**
- **Sampling Frequency (fs):** The rate at which the signal is sampled (1000 Hz = 1 kHz in this example)
- **Signal Duration:** The total observation time (1.5 seconds in this example)
- **Number of Samples (N):** N = fs × duration = 1500 samples
- **Signal:** x(t) = A × sin(2π × f × t), where A is amplitude and f is frequency
- **Noise:** Zero-mean random Gaussian noise added to the signal
- **FFT Output:** Complex values representing frequency components
- **Magnitude Spectrum:** abs(FFT) gives the amplitude of each frequency component

**Derivations:**

1. **Sampling and Time Vector:**
   
   t[n] = n / fs, where n = 0, 1, ..., N-1

2. **Signal Generation:**
   
   x(t) = A × sin(2π × f × t)

3. **FFT Computation:**
   
   X[k] = FFT(x[n]) for k = 0, 1, ..., N-1
   
   Returns N-point DFT as complex numbers

4. **Magnitude Extraction:**
   
   |X[k]| = abs(X[k]) = sqrt(Re(X[k])² + Im(X[k])²)
   
   Gives the amplitude spectrum

5. **Normalization:**
   
   |X[k]| = |X[k]| / N × 2 (for k > 0)
   |X[0]| = |X[0]| / N (DC component)
   
   Scales to actual amplitude values

6. **Frequency Bins:**
   
   f_k = k × fs / N, where k = 0, 1, ..., N/2
   
   Maps each FFT index to its corresponding frequency

7. **Frequency Resolution:**
   
   Δf = fs / N = 1 / duration
   
   Minimum distinguishable frequency difference

**Example Output:**
For signal x(t) = 2.0 × sin(2π × 50 × t) with fs = 1000 Hz, duration = 1.5 s, and zero-mean Gaussian noise (σ = 1.0):
- Number of samples (N): 1500
- Frequency resolution: 0.6667 Hz
- Signal frequency: 50 Hz
- Detected frequency: 50.0000 Hz
- Detection error: 0.0000 Hz
- Signal-to-Noise Ratio (SNR): 3.00 dB
- Peak magnitude: 2.0029

**Key Insight:** Even with moderate noise (SNR = 3 dB), FFT can reliably extract the signal frequency.

---

### Additional Investigations: Noise Robustness

To demonstrate the robustness of FFT-based signal analysis, we explore two additional scenarios
that are particularly relevant for automotive radar applications where signals must be detected
in challenging noise conditions.

#### Investigation 1: Signal Detection with Tripled Noise
**Question:** How does FFT perform when the noise level is significantly increased?

**Setup:**
- Same 50 Hz signal as Example 1
- Noise standard deviation increased to σ = 3.0 (3× original)
- All other parameters unchanged

**Results:**
- SNR: **-4.77 dB** (signal is now buried deep in noise)
- Detected frequency: 50.0000 Hz
- Peak magnitude: ~0.67 (reduced by factor of ~3)
- Detection error: 0.0000 Hz

**Conclusion:** FFT successfully detects the signal even with negative SNR. The peak magnitude 
scales inversely with the noise level, but the frequency detection remains accurate. This 
demonstrates FFT's robustness against noise, which is crucial for automotive radar operating 
in challenging environments with interference and clutter.

#### Investigation 2: Multiple Signals Hidden in Noise
**Question:** Can FFT detect multiple signals when both are buried in noise, including a 
weak signal that may not be visible in the time domain?

**Setup:**
- Original signal: 50 Hz, amplitude = 2.0
- Hidden signal: 120 Hz, amplitude = 0.5 (4× weaker)
- Noise standard deviation: σ = 1.0 (same as Example 1)
- Combined signal: pure_signal + hidden_signal + noise

**Results:**
- SNR for original signal: 3.00 dB
- SNR for hidden signal: **-9.54 dB** (extremely challenging)
- Detected peaks: 2
- Peak 1: ~50.0 Hz (original signal) ✓
- Peak 2: ~120.0 Hz (hidden signal) ✓

**Conclusion:** FFT can simultaneously detect multiple frequency components, even when one 
signal has a negative SNR. The time-domain representation shows a heavily noise-dominated 
signal where individual components are not visible, but the FFT clearly reveals both signals 
in the frequency domain. This capability is essential for automotive radar systems that must 
detect multiple targets (e.g., vehicles in different lanes) in complex environments.

**Visualizations for Doppler Effect:**
All demonstration scripts generate and save plots as PNG files to the `plots/` directory:

1. **Doppler Frequency and Velocity Plot** (`plots/doppler_velocity_plot.png`):
   - Combined visualization showing Doppler frequency shifts and calculated radial velocities
   - Left panel: Bar plot of Doppler frequency shifts for each target
   - Right panel: Bar plot of corresponding radial velocities
   - Color coding: Green bars for approaching targets (positive fd), red bars for receding targets (negative fd)
   - Zero line (blue dashed) indicates the boundary between approaching and receding targets

![][doppler_velocity]

**Visualizations for FFT Signal Analysis:**
All plots are saved as PNG files for direct embedding in this README:

1. **Pure Signal Plot** (`plots/fft_pure_signal.png`):
   - Shows the clean sinusoidal signal x(t) = 2.0×sin(2π×50×t) in the time domain
   - The signal is a perfect 50 Hz sine wave with amplitude 2.0
   - Blue line represents the pure signal, oscillating between +2.0 and -2.0
   - X-axis: Time in seconds (0 to 1.5 s)
   - Y-axis: Amplitude

![][fft_pure]

2. **Pure Noise Plot** (`plots/fft_noise_only.png`):
   - Shows the zero-mean Gaussian noise signal without any signal component
   - Orange line represents random fluctuations around zero
   - This is the noise that gets added to the pure signal to create the noisy signal
   - Standard deviation: σ = 1.0, following N(0, 1.0²) distribution
   - X-axis: Time in seconds
   - Y-axis: Amplitude

![][fft_noise]

3. **Noisy Signal Plot** (`plots/fft_noisy_signal.png`):
   - Shows both the pure signal (blue) and the noisy signal (red) superimposed
   - Demonstrates how the original 50 Hz signal is buried in zero-mean Gaussian noise
   - The noisy signal fluctuates around the pure sine wave
   - SNR of 3.00 dB indicates the signal is partially obscured by noise
   - X-axis: Time in seconds
   - Y-axis: Amplitude

![][fft_noisy]

4. **FFT Magnitude Spectrum Plot** (`plots/fft_magnitude_spectrum.png`):
   - Shows the FFT magnitude spectrum in the frequency domain
   - X-axis: Frequency in Hz (0 to 500 Hz, the Nyquist frequency at fs/2)
   - Y-axis: Amplitude (normalized)
   - Green line: FFT magnitude for all frequency bins
   - Red vertical dashed line: Expected signal frequency at 50 Hz
   - Red dot with label: Detected peak at exactly 50.0 Hz
   - The FFT successfully identifies the 50 Hz component despite the noise
   - All other frequency bins show much lower magnitudes (noise floor)

![][fft_spectrum]

5. **Combined Plot** (`plots/fft_combined_plots.png`):
   - All four plots stacked vertically for comprehensive view
   - Shows the complete signal processing pipeline: pure signal → noise → noisy signal → FFT result

![][fft_combined]

**Visualizations for Additional Investigations:**
The following plots illustrate the two extended investigations, demonstrating FFT's robustness
in challenging signal conditions. These examples build upon the basic FFT demonstration to show
real-world applicability where signals are not ideal.

6. **Tripled Noise: Time Domain** (`plots/fft_tripled_noise_signal.png`):
   - Shows the original 50 Hz signal (blue) overlaid with the noisy version (red)
   - Noise standard deviation: σ = 3.0 (three times the original example)
   - SNR: -4.77 dB (signal is heavily obscured by noise)
   - Demonstrates how increased noise affects the time-domain representation

![][fft_tripled_noise]

7. **Tripled Noise: Frequency Domain** (`plots/fft_tripled_noise_spectrum.png`):
   - FFT magnitude spectrum of the signal with tripled noise
   - The 50 Hz peak remains clearly visible despite SNR = -4.77 dB
   - Peak magnitude reduced by approximately 3× compared to Example 1
   - Noise floor is elevated, but signal peak is still distinguishable
   - Key insight: FFT preserves frequency information even with high noise

![][fft_tripled_spectrum]

8. **Hidden Signal: Time Domain** (`plots/fft_hidden_signal_time.png`):
   - Shows the hidden 120 Hz signal alone with amplitude = 0.5
   - This smaller signal represents a weaker target or reflection in radar applications
   - Demonstrates how weak signals can exist alongside stronger ones

![][fft_hidden_time]

9. **Combined Signal with Hidden Component** (`plots/fft_noise_with_hidden_signal.png`):
   - Shows all three components in time domain:
     - Original signal (50 Hz, blue)
     - Hidden signal (120 Hz, purple)
     - Combined signal with noise (orange)
   - The combined signal appears heavily noise-dominated
   - Individual components are not visually separable in time domain
   - Visualizes the challenge of detecting multiple signals in noise

![][fft_noise_hidden]

10. **Hidden Signal: Frequency Domain** (`plots/fft_hidden_signal_spectrum.png`):
    - FFT magnitude spectrum revealing the frequency content
    - Two distinct peaks visible:
      - Peak 1: ~50.0 Hz (original signal)
      - Peak 2: ~120.0 Hz (hidden signal)
    - Demonstrates FFT's ability to separate multiple frequency components
    - Shows how FFT can reveal signals not visible in the time domain
    - Key insight: FFT transforms complex time-domain signals into interpretable frequency patterns

![][fft_hidden_spectrum]

---

[doppler_velocity]: plots/doppler_velocity_plot.png "Doppler Frequency and Velocity Plot"
[fft_pure]: plots/fft_pure_signal.png "Pure Signal Plot"
[fft_noise]: plots/fft_noise_only.png "Pure Noise Plot"
[fft_noisy]: plots/fft_noisy_signal.png "Noisy Signal Plot"
[fft_spectrum]: plots/fft_magnitude_spectrum.png "FFT Magnitude Spectrum Plot"
[fft_combined]: plots/fft_combined_plots.png "Combined FFT Plots"
[fft_tripled_noise]: plots/fft_tripled_noise_signal.png "Tripled Noise Signal"
[fft_tripled_spectrum]: plots/fft_tripled_noise_spectrum.png "Tripled Noise Spectrum"
[fft_hidden_time]: plots/fft_hidden_signal_time.png "Hidden Signal"
[fft_noise_hidden]: plots/fft_noise_with_hidden_signal.png "Noise with Hidden Signal"
[fft_hidden_spectrum]: plots/fft_hidden_signal_spectrum.png "Hidden Signal Spectrum"
[fmcw_transmitted_chirp]: plots/fmcw_transmitted_chirp.png "FMCW Transmitted Chirp"
[fmcw_chirp_linearity]: plots/fmcw_chirp_linearity.png "FMCW Chirp Linearity"
[fmcw_received_frequencies]: plots/fmcw_received_frequencies.png "FMCW Received Frequencies"
[fmcw_beat_signals]: plots/fmcw_beat_signals.png "FMCW Beat Signals"
[fmcw_combined_beat_signal]: plots/fmcw_combined_beat_signal.png "FMCW Combined Beat Signal"
[fmcw_scaled_beat_signal]: plots/fmcw_scaled_beat_signal.png "FMCW Scaled Beat Signal"
[fmcw_fft_beat_signal]: plots/fmcw_fft_beat_signal.png "FMCW FFT Beat Signal"
[fmcw_scene_visualization]: plots/fmcw_scene_visualization.png "FMCW Scene Visualization"
[fmcw_signal_processing_chain]: plots/fmcw_signal_processing_chain.png "FMCW Signal Processing Chain"
[fmcw_range_velocity_extraction]: plots/fmcw_range_velocity_extraction.png "FMCW Range Velocity Extraction"
[fmcw_2dfft_preparation]: plots/fmcw_2dfft_preparation.png "FMCW 2D-FFT Preparation"
[range_chirp_transmitted]: plots/range_chirp_transmitted.png "Range Chirp Transmitted"
[range_chirp_frequency]: plots/range_chirp_frequency.png "Range Chirp Frequency"
[range_chirp_delay]: plots/range_chirp_delay.png "Range Chirp Delay"
[range_beat_frequency]: plots/range_beat_frequency.png "Range Beat Frequency"
[range_beat_vs_range]: plots/range_beat_vs_range.png "Range Beat vs Range"
[range_fmcw_process]: plots/range_fmcw_process.png "Range FMCW Process"
[range_frequency_difference]: plots/range_frequency_difference.png "Range Frequency Difference"
[range_mixing_demo]: plots/range_mixing_demo.png "Range Mixing Demo"
[range_mixing_spectrum]: plots/range_mixing_spectrum.png "Range Mixing Spectrum"

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