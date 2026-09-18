#' FFT Signal Analysis Demonstration
#'
#' @title Fast Fourier Transform - Frequency Component Detection
#' @description Self-contained demonstration of using FFT to extract frequency components
#'   from a noisy signal. Shows how FFT reveals hidden periodic signals in noise.
#'
#' @section Theory:
#' The Fast Fourier Transform (FFT) is an efficient algorithm to compute the Discrete Fourier
#' Transform (DFT), which decomposes a signal into its constituent frequencies. This is essential
#' in radar signal processing for detecting targets, analyzing beat frequencies, and extracting
#' useful information from noisy measurements.
#'
#' @section Key Formulas:
#' 1. Sampling: t = n / fs, where n = 0, 1, ..., N-1
#'
#' 2. Signal generation: x(t) = A * sin(2 * pi * f * t) + noise
#'
#' 3. FFT: X = fft(x, N) returns the N-point DFT
#'
#' 4. Magnitude: |X| = abs(X) gives the amplitude spectrum
#'
#' 5. Frequency bins: f_k = k * fs / N, where k = 0, 1, ..., N/2
#'
#' @section Usage:
#' Run this script directly in R or RStudio, or use VS Code with the R extension.
#' Simply source this file: source('demo_fft_signal_analysis.R')
#'
#' @section Parameters in this demonstration:
#' - Sampling frequency (fs): 1000 Hz (1 kHz) [Note: Automotive radar uses 1-10 MHz]
#' - Signal duration: 1.5 seconds [Note: Automotive radar uses microsecond-level chirps]
#' - Signal frequency (f): 50 Hz [Simplified; automotive uses beat frequencies in kHz-MHz range]
#' - Signal amplitude (A): 2.0 [Represents relative signal strength]
#' - Noise: Zero-mean random normal distribution with σ=1.0 [SNR=3dB, typical for radar]
#'
#' Note: Parameters are simplified for demonstration. Automotive FMCW radar typically
#' uses sampling rates of 1-10 MHz and operating frequencies of 76-81 GHz, with beat
#' frequencies corresponding to target ranges of 1-300 meters.

# =============================================================================
# SET WORKING DIRECTORY TO PROJECT ROOT
# =============================================================================
# Ensure plots are saved to the project root's plots/ directory regardless of
# where the script is sourced from
current_dir <- getwd()
if (grepl("/src/R$", current_dir) || grepl("\\src\\R$", current_dir)) {
  setwd(dirname(dirname(current_dir)))
}

# =============================================================================
# 1. PARAMETER DEFINITION
# =============================================================================

# Sampling parameters
fs <- 1000    # Sampling frequency [Hz]
duration <- 1.5  # Signal duration [seconds]

# Signal parameters
A <- 2.0       # Signal amplitude
f_signal <- 50 # Signal frequency [Hz]

# Derived parameters
N <- duration * fs  # Number of samples (must be integer)
if (N != as.integer(N)) {
  stop("N must be an integer. Adjust fs or duration.")
}
N <- as.integer(N)

t <- seq(0, duration - 1/fs, by = 1/fs)  # Time vector

cat("=== FFT Signal Analysis Demonstration ===\n")
cat("Parameters:\n")
cat("  Sampling frequency (fs):", fs, "Hz\n")
cat("  Signal duration:", duration, "s\n")
cat("  Number of samples (N):", N, "\n")
cat("  Signal frequency (f):", f_signal, "Hz\n")
cat("  Signal amplitude (A):", A, "\n\n")

# =============================================================================
# 2. GENERATE PURE SIGNAL
# =============================================================================

pure_signal <- A * sin(2 * pi * f_signal * t)

cat("1. Pure Signal Generation:\n")
cat("   x(t) = A * sin(2 * pi * f * t)\n")
cat(sprintf("   x(t) = %.1f * sin(2 * pi * %d * t)\n\n", A, f_signal))

# =============================================================================
# 3. ADD NOISE
# =============================================================================

set.seed(12345)
sigma_noise <- 1.0
noise <- rnorm(N, mean = 0, sd = sigma_noise)
noisy_signal <- pure_signal + noise

cat("2. Adding Zero-Mean Random Noise:\n")
cat("   noise ~ N(0, sigma^2)\n")
cat(sprintf("   sigma = %.2f\n\n", sigma_noise))
cat("   Signal-to-Noise Ratio (SNR) is approximately:")
SNR <- 10 * log10(var(pure_signal) / var(noise))
cat(sprintf("   SNR = 10 * log10(var(signal) / var(noise)) = %.2f dB\n\n", SNR))

# =============================================================================
# 4. PERFORM FFT
# =============================================================================

signal_fft <- fft(noisy_signal, N)

cat("3. FFT Computation:\n")
cat("   signal_fft = fft(noisy_signal, N)\n")
cat("   This returns the N-point Discrete Fourier Transform (DFT)\n")
cat(sprintf("   Length of FFT output: %d points\n\n", length(signal_fft)))

# =============================================================================
# 5. EXTRACT AND NORMALIZE MAGNITUDE
# =============================================================================

signal_fft_mag <- abs(signal_fft)
signal_fft_mag <- signal_fft_mag / N
signal_fft_mag[1] <- signal_fft_mag[1]  # DC component
signal_fft_mag[2:(N/2 + 1)] <- 2 * signal_fft_mag[2:(N/2 + 1)]  # Positive frequencies

cat("4. Magnitude Extraction and Normalization:\n")
cat("   signal_fft_mag = abs(signal_fft) / N\n")
cat("   Positive frequencies multiplied by 2 (except DC)\n\n")

# =============================================================================
# 6. EXTRACT POSITIVE FREQUENCIES
# =============================================================================

L <- length(signal_fft_mag)
signal_fft_mag_positive <- signal_fft_mag[1:(L/2 + 1)]
freq_vector <- seq(0, fs/2, length.out = length(signal_fft_mag_positive))

cat("5. Extract Positive Frequencies:\n")
cat("   Frequency range: 0 Hz to", max(freq_vector), "Hz\n")
cat(sprintf("   Frequency resolution: %.4f Hz\n\n", fs / N))

# =============================================================================
# 7. DETECT PEAK FREQUENCY
# =============================================================================

magnitude_without_dc <- signal_fft_mag_positive[-1]
peak_idx <- which.max(magnitude_without_dc)
detected_frequency <- freq_vector[peak_idx + 1]
peak_magnitude <- magnitude_without_dc[peak_idx]

cat("6. Peak Detection:\n")
cat(sprintf("   Original signal frequency: %.1f Hz\n", f_signal))
cat(sprintf("   Detected peak frequency: %.4f Hz\n", detected_frequency))
cat(sprintf("   Peak magnitude: %.4f\n", peak_magnitude))
cat(sprintf("   Detection error: %.4f Hz\n\n", abs(f_signal - detected_frequency)))

# =============================================================================
# 8. VISUALIZATION - Save plots to plots/ directory
# =============================================================================

cat("7. Visualization:\n")
cat("   Saving plots to 'plots/' directory...\n")

if (!dir.exists("plots")) {
  dir.create("plots")
}

# Plot 1: Pure Signal in Time Domain
png(file.path("plots", "fft_pure_signal.png"), width = 800, height = 600)
plot(t, pure_signal, 
     type = "l", 
     col = "blue", 
     lwd = 2,
     main = "Pure Signal in Time Domain",
     xlab = "Time [s]",
     ylab = "Amplitude",
     xlim = c(0, duration),
     ylim = c(-A*1.1, A*1.1))
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = sprintf("x(t) = %.1f*sin(2*pi*%d*t)", A, f_signal), bty = "n")
dev.off()

# Plot 2: Noisy Signal in Time Domain (showing both pure and noisy)
png(file.path("plots", "fft_noisy_signal.png"), width = 800, height = 600)
plot(t, pure_signal, type = "l", col = "blue", lwd = 2, 
     main = sprintf("Noisy Signal in Time Domain (SNR = %.2f dB)", SNR),
     xlab = "Time [s]", ylab = "Amplitude")
lines(t, noisy_signal, col = "red", lwd = 1)
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = c(sprintf("Pure signal (%.1f Hz)", f_signal), "Noisy signal"),
       col = c("blue", "red"), lty = c(1, 1), lwd = c(2, 1), bty = "n")
dev.off()

# Plot 3: FFT Magnitude Spectrum
png(file.path("plots", "fft_magnitude_spectrum.png"), width = 800, height = 600)
plot(freq_vector, signal_fft_mag_positive, 
     type = "l", 
     col = "darkgreen", 
     lwd = 2,
     main = "FFT Magnitude Spectrum",
     xlab = "Frequency [Hz]",
     ylab = "Amplitude")
abline(v = f_signal, col = "red", lwd = 2, lty = 2)
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = c(sprintf("Signal at %d Hz", f_signal), "FFT magnitude"),
       col = c("red", "darkgreen"), 
       lty = c(2, 1), 
       lwd = c(2, 2),
       bty = "n")
max_idx_plot <- which.max(signal_fft_mag_positive[2:length(signal_fft_mag_positive)]) + 1
detected_freq_plot <- freq_vector[max_idx_plot]
points(detected_freq_plot, signal_fft_mag_positive[max_idx_plot], 
       col = "red", pch = 19, cex = 1.5)
text(detected_freq_plot, signal_fft_mag_positive[max_idx_plot] + 0.1, 
     labels = sprintf("Detected: %.1f Hz", detected_freq_plot),
     col = "red", pos = 1, offset = 0.5, cex = 0.8)
dev.off()

# Combined plot with all signals
png(file.path("plots", "fft_combined_plots.png"), width = 1000, height = 1600)
par(mfrow = c(4, 1))

# Plot 1: Pure Signal
plot(t, pure_signal, type = "l", col = "blue", lwd = 2,
     main = "Pure Signal in Time Domain", xlab = "Time [s]", ylab = "Amplitude",
     xlim = c(0, duration), ylim = c(-A*1.1, A*1.1))
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = sprintf("x(t) = %.1f*sin(2*pi*%d*t)", A, f_signal), bty = "n")

# Plot 2: Pure Noise
plot(t, noise, type = "l", col = "orange", lwd = 1,
     main = "Pure Noise Signal (Zero-Mean Gaussian)", xlab = "Time [s]", ylab = "Amplitude")
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = sprintf("Noise ~ N(0, %.2f^2)", sigma_noise), bty = "n")

# Plot 3: Noisy Signal
plot(t, pure_signal, type = "l", col = "blue", lwd = 2, 
     main = sprintf("Noisy Signal in Time Domain (SNR = %.2f dB)", SNR),
     xlab = "Time [s]", ylab = "Amplitude")
lines(t, noisy_signal, col = "red", lwd = 1)
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = c("Pure signal", "Noisy signal"), col = c("blue", "red"),
       lty = c(1, 1), lwd = c(2, 1), bty = "n")

# Plot 4: FFT Magnitude Spectrum
plot(freq_vector, signal_fft_mag_positive, type = "l", col = "darkgreen", lwd = 2,
     main = "FFT Magnitude Spectrum", xlab = "Frequency [Hz]", ylab = "Amplitude")
abline(v = f_signal, col = "red", lwd = 2, lty = 2)
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = c(sprintf("Signal at %d Hz", f_signal), "FFT magnitude"),
       col = c("red", "darkgreen"), lty = c(2, 1), lwd = c(2, 2), bty = "n")
max_idx_plot <- which.max(signal_fft_mag_positive[2:length(signal_fft_mag_positive)]) + 1
detected_freq_plot <- freq_vector[max_idx_plot]
points(detected_freq_plot, signal_fft_mag_positive[max_idx_plot], col = "red", pch = 19, cex = 1.5)
text(detected_freq_plot, signal_fft_mag_positive[max_idx_plot] + 0.1,
     labels = sprintf("Detected: %.1f Hz", detected_freq_plot),
     col = "red", pos = 1, offset = 0.5, cex = 0.8)

par(mfrow = c(1, 1))
dev.off()

# Plot 2b: Pure Noise Signal
png(file.path("plots", "fft_noise_only.png"), width = 800, height = 600)
plot(t, noise, 
     type = "l", 
     col = "orange", 
     lwd = 1,
     main = "Pure Noise Signal (Zero-Mean Gaussian)",
     xlab = "Time [s]",
     ylab = "Amplitude")
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = sprintf("Noise ~ N(0, %.2f^2)", sigma_noise), bty = "n")
dev.off()

cat("   Plots saved to 'plots/' directory:\n")
cat("   - plots/fft_pure_signal.png - Pure signal in time domain\n")
cat("   - plots/fft_noise_only.png - Pure noise signal (zero-mean Gaussian)\n")
cat("   - plots/fft_noisy_signal.png - Signal with added noise in time domain\n")
cat("   - plots/fft_magnitude_spectrum.png - FFT magnitude spectrum\n")
cat("   - plots/fft_combined_plots.png - All plots combined\n\n")

# =============================================================================
# 9. FREQUENCY RESOLUTION ANALYSIS
# =============================================================================

frequency_resolution <- fs / N

cat("8. Frequency Resolution:\n")
cat("   The minimum distinguishable frequency difference:\n")
cat(sprintf("   delta_f = fs / N = %.1f / %d = %.4f Hz\n", fs, N, frequency_resolution))
cat(sprintf("   This is equivalent to 1 / duration = 1 / %.1f = %.4f Hz\n\n", duration, frequency_resolution))

# =============================================================================
# 10. SUMMARY
# =============================================================================
cat("=== Summary ===\n")
cat("This demonstration shows how FFT can extract frequency components from noisy signals.\n\n")
cat("Key insights:\n")
cat(sprintf("  - Number of samples: %d\n", N))
cat(sprintf("  - Sampling frequency: %.1f Hz\n", fs))
cat(sprintf("  - Frequency resolution: %.4f Hz\n", frequency_resolution))
cat(sprintf("  - Signal frequency: %.1f Hz\n", f_signal))
cat(sprintf("  - Detected frequency: %.4f Hz\n", detected_frequency))
cat(sprintf("  - Detection error: %.4f Hz\n\n", abs(f_signal - detected_frequency)))

cat("The FFT successfully identified the signal frequency despite the presence of noise.\n")
cat("This is the fundamental principle behind radar signal processing, where FFT is used\n")
cat("to detect beat frequencies, Doppler shifts, and other periodic components in\n")
cat("noisy radar returns.\n\n")

# =============================================================================
# EXTENDED EXAMPLES WITH DIFFERENT NOISE LEVELS
# =============================================================================

cat("=== Extended FFT Examples ===\n\n")

# =============================================================================
# EXAMPLE 2: TRIPLED NOISE LEVEL
# =============================================================================

cat("EXAMPLE 2: Signal with Tripled Noise Level\n")
cat("----------------------------------------\n")

# Reset seed for reproducibility
set.seed(12345)

# Tripled noise level
sigma_noise_2 <- 3.0  # Three times the original noise
noise_2 <- rnorm(N, mean = 0, sd = sigma_noise_2)
noisy_signal_2 <- pure_signal + noise_2

SNR_2 <- 10 * log10(var(pure_signal) / var(noise_2))

cat("Parameters:\n")
cat(sprintf("  Signal frequency: %.1f Hz\n", f_signal))
cat(sprintf("  Noise standard deviation: %.2f (3x original)\n", sigma_noise_2))
cat(sprintf("  SNR: %.2f dB (lower than original %.2f dB)\n\n", SNR_2, SNR))

# Perform FFT for Example 2
signal_fft_2 <- fft(noisy_signal_2, N)
signal_fft_mag_2 <- abs(signal_fft_2)
signal_fft_mag_2 <- signal_fft_mag_2 / N
signal_fft_mag_2[1] <- signal_fft_mag_2[1]
signal_fft_mag_2[2:(N/2 + 1)] <- 2 * signal_fft_mag_2[2:(N/2 + 1)]
signal_fft_mag_positive_2 <- signal_fft_mag_2[1:(L/2 + 1)]

# Detect peak for Example 2
magnitude_without_dc_2 <- signal_fft_mag_positive_2[-1]
peak_idx_2 <- which.max(magnitude_without_dc_2)
detected_frequency_2 <- freq_vector[peak_idx_2 + 1]
peak_magnitude_2 <- magnitude_without_dc_2[peak_idx_2]

cat("Results:\n")
cat(sprintf("  Detected frequency: %.4f Hz\n", detected_frequency_2))
cat(sprintf("  Peak magnitude: %.4f (reduced due to higher noise)\n", peak_magnitude_2))
cat(sprintf("  Detection error: %.4f Hz\n\n", abs(f_signal - detected_frequency_2)))

# Save plots for Example 2
png(file.path("plots", "fft_tripled_noise_signal.png"), width = 800, height = 600)
plot(t, pure_signal, type = "l", col = "blue", lwd = 2, 
     main = sprintf("Tripled Noise: Noisy Signal (SNR = %.2f dB)", SNR_2),
     xlab = "Time [s]", ylab = "Amplitude")
lines(t, noisy_signal_2, col = "red", lwd = 1)
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = c(sprintf("Pure signal (%.1f Hz)", f_signal), "Noisy signal (3x noise)"),
       col = c("blue", "red"), lty = c(1, 1), lwd = c(2, 1), bty = "n")
dev.off()

png(file.path("plots", "fft_tripled_noise_spectrum.png"), width = 800, height = 600)
plot(freq_vector, signal_fft_mag_positive_2, 
     type = "l", 
     col = "darkgreen", 
     lwd = 2,
     main = sprintf("FFT with Tripled Noise (SNR = %.2f dB)", SNR_2),
     xlab = "Frequency [Hz]",
     ylab = "Amplitude")
abline(v = f_signal, col = "red", lwd = 2, lty = 2)
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = c(sprintf("Signal at %d Hz", f_signal), "FFT magnitude"),
       col = c("red", "darkgreen"), 
       lty = c(2, 1), 
       lwd = c(2, 2),
       bty = "n")
max_idx_2 <- which.max(signal_fft_mag_positive_2[2:length(signal_fft_mag_positive_2)]) + 1
detected_freq_2 <- freq_vector[max_idx_2]
points(detected_freq_2, signal_fft_mag_positive_2[max_idx_2], 
       col = "red", pch = 19, cex = 1.5)
text(detected_freq_2, signal_fft_mag_positive_2[max_idx_2] + 0.1, 
     labels = sprintf("Detected: %.1f Hz", detected_freq_2),
     col = "red", pos = 1, offset = 0.5, cex = 0.8)
dev.off()

cat("Plots saved:\n")
cat("   - plots/fft_tripled_noise_signal.png - Noisy signal with 3x noise\n")
cat("   - plots/fft_tripled_noise_spectrum.png - FFT spectrum with 3x noise\n\n")

# =============================================================================
# EXAMPLE 3: RANDOM NOISE WITH HIDDEN SIGNAL
# =============================================================================

cat("EXAMPLE 3: Random Noise with Hidden Signal\n")
cat("------------------------------------------\n")

# Reset seed for reproducibility
set.seed(54321)

# Hidden signal parameters (different frequency)
f_hidden <- 120  # Hidden signal at 120 Hz
A_hidden <- 0.5  # Smaller amplitude, hidden in noise

# Create hidden signal
hidden_signal <- A_hidden * sin(2 * pi * f_hidden * t)

# New noise
noise_3 <- rnorm(N, mean = 0, sd = sigma_noise)

# Noisy signal with hidden component
noisy_signal_3 <- noise_3 + hidden_signal

# Also create version with original signal + hidden signal + noise
noisy_signal_with_both <- pure_signal + hidden_signal + noise_3

SNR_3_original <- 10 * log10(var(pure_signal) / var(noise_3))
SNR_3_hidden <- 10 * log10(var(hidden_signal) / var(noise_3))

cat("Parameters:\n")
cat(sprintf("  Original signal: %.1f Hz, amplitude = %.1f\n", f_signal, A))
cat(sprintf("  Hidden signal: %.1f Hz, amplitude = %.1f (smaller)\n", f_hidden, A_hidden))
cat(sprintf("  Noise standard deviation: %.2f\n", sigma_noise))
cat(sprintf("  SNR for original signal: %.2f dB\n", SNR_3_original))
cat(sprintf("  SNR for hidden signal: %.2f dB (more challenging to detect)\n\n", SNR_3_hidden))

# Perform FFT for Example 3
signal_fft_3 <- fft(noisy_signal_with_both, N)
signal_fft_mag_3 <- abs(signal_fft_3)
signal_fft_mag_3 <- signal_fft_mag_3 / N
signal_fft_mag_3[1] <- signal_fft_mag_3[1]
signal_fft_mag_3[2:(N/2 + 1)] <- 2 * signal_fft_mag_3[2:(N/2 + 1)]
signal_fft_mag_positive_3 <- signal_fft_mag_3[1:(L/2 + 1)]

# Detect peaks for Example 3
magnitude_without_dc_3 <- signal_fft_mag_positive_3[-1]

# Find all significant peaks (above a threshold)
peaks_3 <- which(magnitude_without_dc_3 > max(magnitude_without_dc_3) * 0.3)

cat("Results:\n")
cat(sprintf("  Number of detected peaks: %d\n", length(peaks_3)))

for (i in seq_along(peaks_3)) {
  idx <- peaks_3[i]
  freq <- freq_vector[idx + 1]
  mag <- magnitude_without_dc_3[idx]
  cat(sprintf("  Peak %d: %.4f Hz, magnitude = %.4f\n", i, freq, mag))
}
cat("\n")

# Check if both signals are detected
has_50Hz <- any(abs(freq_vector[peaks_3 + 1] - f_signal) < 2)
has_120Hz <- any(abs(freq_vector[peaks_3 + 1] - f_hidden) < 2)

cat("Detection Summary:\n")
cat(sprintf("  Original signal (%.1f Hz) detected: %s\n", f_signal, ifelse(has_50Hz, "YES", "NO")))
cat(sprintf("  Hidden signal (%.1f Hz) detected: %s\n", f_hidden, ifelse(has_120Hz, "YES", "NO")))
cat("\n")

# Save plots for Example 3
png(file.path("plots", "fft_hidden_signal_time.png"), width = 800, height = 600)
plot(t, hidden_signal, type = "l", col = "purple", lwd = 2,
     main = sprintf("Hidden Signal: %.1f Hz, Amplitude = %.1f", f_hidden, A_hidden),
     xlab = "Time [s]", ylab = "Amplitude")
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = sprintf("x(t) = %.1f*sin(2*pi*%d*t)", A_hidden, f_hidden), bty = "n")
dev.off()

png(file.path("plots", "fft_noise_with_hidden_signal.png"), width = 800, height = 600)
plot(t, noisy_signal_with_both, type = "l", col = "orange", lwd = 1,
     main = "Noisy Signal with Hidden Component",
     xlab = "Time [s]", ylab = "Amplitude")
lines(t, pure_signal, col = "blue", lwd = 1)
lines(t, hidden_signal, col = "purple", lwd = 1)
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = c(sprintf("Original (%.1f Hz)", f_signal), 
                  sprintf("Hidden (%.1f Hz)", f_hidden),
                  "Noise + both signals"),
       col = c("blue", "purple", "orange"), 
       lty = c(1, 1, 1), 
       lwd = c(1, 1, 1),
       bty = "n")
dev.off()

png(file.path("plots", "fft_hidden_signal_spectrum.png"), width = 800, height = 600)
plot(freq_vector, signal_fft_mag_positive_3, 
     type = "l", 
     col = "darkgreen", 
     lwd = 2,
     main = "FFT Spectrum: Detecting Hidden Signal in Noise",
     xlab = "Frequency [Hz]",
     ylab = "Amplitude")
abline(v = f_signal, col = "blue", lwd = 2, lty = 2)
abline(v = f_hidden, col = "purple", lwd = 2, lty = 2)
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = c(sprintf("Original signal (%.1f Hz)", f_signal), 
                  sprintf("Hidden signal (%.1f Hz)", f_hidden),
                  "FFT magnitude"),
       col = c("blue", "purple", "darkgreen"), 
       lty = c(2, 2, 1), 
       lwd = c(2, 2, 2),
       bty = "n")

# Mark detected peaks
for (i in seq_along(peaks_3)) {
  idx <- peaks_3[i]
  freq <- freq_vector[idx + 1]
  mag <- signal_fft_mag_positive_3[idx + 1]
  points(freq, mag, col = "red", pch = 19, cex = 1.5)
  text(freq, mag + 0.05, labels = sprintf("%.1f Hz", freq), 
       col = "red", pos = 1, offset = 0.5, cex = 0.8)
}
dev.off()

cat("Plots saved:\n")
cat("   - plots/fft_hidden_signal_time.png - Hidden signal alone\n")
cat("   - plots/fft_noise_with_hidden_signal.png - All signals in noise\n")
cat("   - plots/fft_hidden_signal_spectrum.png - FFT spectrum showing both signals\n\n")

# =============================================================================
# 11. PRACTICAL CONTEXT IN AUTOMOTIVE SYSTEMS
# =============================================================================
cat("\nPractical Context in Automotive Radar Systems:\n")
cat("The parameters in this demonstration (fs=1000 Hz, f=50 Hz) are simplified for clarity,\n")
cat("but the principles directly apply to automotive radar:\n\n")

cat("In automotive FMCW radar systems (76-81 GHz):\n")
cat("  - FFT is applied to the beat signal to determine target range with centimeter accuracy\n")
cat("  - Each range bin corresponds to a specific beat frequency, enabling simultaneous\n")
cat("    detection of multiple targets (vehicles, pedestrians, obstacles)\n")
cat("  - Frequency resolution of ~0.67 Hz in this demo translates to range resolution in\n")
cat("    automotive systems: finer resolution = better ability to distinguish close targets\n")
cat("  - Typical sampling frequencies: 1-10 MHz for automotive radar\n")
cat("  - Typical signal frequencies: Beat frequencies in kHz-MHz range for targets at 1-300m\n\n")

cat("In automotive Doppler radar:\n")
cat("  - FFT extracts Doppler shifts from received signals to measure target velocity\n")
cat("  - Each frequency peak corresponds to a target with specific radial velocity\n")
cat("  - Multiple targets (e.g., vehicles in different lanes) can be separated by their\n")
cat("    distinct Doppler frequencies\n")
cat("  - The FFT's ability to identify signals buried in noise is critical for reliable\n")
cat("    target detection in real-world driving conditions with interference and clutter\n")

# =============================================================================
# REUSABLE FUNCTIONS
# =============================================================================

#' Perform FFT-based frequency analysis on a signal
#' @param signal The input signal (time domain)
#' @param fs Sampling frequency in Hz
#' @return A list containing frequency vector and magnitude spectrum
analyze_frequency_fft <- function(signal, fs) {
  N <- length(signal)
  fft_result <- fft(signal, N)
  mag <- abs(fft_result) / N
  mag[1] <- mag[1]
  mag[2:(N/2 + 1)] <- 2 * mag[2:(N/2 + 1)]
  freq <- seq(0, fs/2, length.out = N/2 + 1)
  list(frequency = freq, magnitude = mag[1:(N/2 + 1)])
}

#' Find peak frequency in a spectrum
#' @param magnitude Magnitude spectrum (single-sided)
#' @param frequency Frequency vector
#' @param exclude_dc Logical, whether to exclude DC component (default: TRUE)
#' @return The frequency at which the maximum magnitude occurs
find_peak_frequency <- function(magnitude, frequency, exclude_dc = TRUE) {
  if (exclude_dc && length(magnitude) > 1) {
    magnitude <- magnitude[-1]
    frequency <- frequency[-1]
  }
  peak_idx <- which.max(magnitude)
  frequency[peak_idx]
}
