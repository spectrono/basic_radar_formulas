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

**Usage with VS Code:**

1. Open this repository in Visual Studio Code
2. Install the [R extension](https://marketplace.visualstudio.com/items?itemName=Ikuyadeu.r) for syntax highlighting and IntelliSense
3. Open `src/R/demo_range_estimation.R`, `src/R/demo_doppler_velocity.R`, or `src/R/demo_fft_signal_analysis.R`
4. Use the VS Code debugger (F5) or run the script directly with `source('src/R/demo_range_estimation.R')`, `source('src/R/demo_doppler_velocity.R')`, or `source('src/R/demo_fft_signal_analysis.R')` in the R terminal
5. View the calculated results printed in the console

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

**Theory:**

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