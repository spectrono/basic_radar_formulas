#' FMCW Radar Chirp Simulation - Automotive Scene with Two Targets
#'
#' @title FMCW Radar System Simulation for Automotive Applications
#' @description Comprehensive demonstration of FMCW radar chirp signal generation,
#'   target reflection modeling, beat signal extraction, and preparation for 2D-FFT.
#'   Simulates a realistic automotive scenario with two moving targets.
#'
#' @section Motivation:
#' This demonstration shows the complete signal processing chain of an FMCW radar system,
#' which is the dominant architecture in automotive applications (77 GHz radars). The simulation
#' covers:
#' - Transmitted chirp signal generation
#' - Target reflection with range delay and Doppler shift
#' - Received signal modeling for multiple targets
#' - Beat signal extraction via mixing
#' - Range and velocity estimation from beat frequencies
#' - Visualization of all intermediate signals
#' - Preparation for 2D-FFT (range-velocity map)
#'
#' FMCW radar is ideal for automotive applications because it can simultaneously measure
#' range and velocity with high accuracy using a single antenna, making it compact and
#' cost-effective for mass production in vehicles.
#'
#' @section Theory:
#' FMCW (Frequency Modulated Continuous Wave) radar transmits a frequency-modulated chirp
#' signal that increases linearly over time. The received signal from a target is a
#' delayed and Doppler-shifted version of the transmitted signal.
#'
#' When the transmitted and received signals are mixed (multiplied), the result is a
#' beat signal whose frequency components contain information about both the target's
#' range (from the time delay) and velocity (from the Doppler shift).
#'
#' For multiple targets, the beat signal is a superposition of signals from all targets,
#' and FFT is used to separate them in the frequency domain.
#'
#' @section Key Formulas:
#' 1. Wavelength: lambda = c / f0
#'    Where c is speed of light, f0 is carrier frequency
#'
#' 2. Doppler Frequency Shift: fd = 2 * vr * f0 / c
#'    The frequency shift due to target motion (positive for approaching, negative for receding)
#'
#' 3. Time Delay: tau = 2 * R / c
#'    Round-trip time for signal to reach target and return
#'
#' 4. Chirp Slope: mu = B / Tc
#'    Rate of frequency change in the chirp
#'
#' 5. Instantaneous Transmitted Frequency: ft(t) = f0 + mu * t
#'    Frequency at time t during the chirp
#'
#' 6. Instantaneous Received Frequency (from moving target):
#'    fr(t) = f0 + mu * (t - tau) + fd
#'    Received frequency accounts for delay and Doppler shift
#'
#' 7. Beat Frequency (from mixing):
#'    fb(t) = fr(t) - ft(t) = mu * tau - mu * (2 * vr * t / c) + fd
#'    Contains range information (mu * tau) and velocity information (Doppler term)
#'
#' 8. Range from Beat Frequency: R = (fb_range * c * Tc) / (2 * B)
#'    Where fb_range is the range component of the beat frequency
#'
#' 9. Velocity from Doppler: vr = (fd * c) / (2 * f0)
#'    Direct relationship between Doppler shift and radial velocity
#'
#' @section System Design Steps:
#' 1. Define radar parameters (frequency, bandwidth, chirp time)
#' 2. Define target parameters (range, velocity)
#' 3. Generate transmitted chirp signal
#' 4. Simulate received signals from each target with delay and Doppler
#' 5. Combine received signals (superposition for multiple targets)
#' 6. Mix transmitted and received to get beat signal
#' 7. Perform FFT to extract frequency components
#' 8. Calculate range and velocity from beat frequencies
#' 9. Visualize all signals at each processing stage
#'
#' @section Usage:
#' Run this script directly in R or RStudio, or use VS Code with the R extension.
#' Simply source this file: source('demo_fmcw_radar_chirp.R')
#'
#' @section Parameters in this demonstration:
#' - Radar operating frequency (f0): 77 GHz (automotive standard)
#' - Sweep bandwidth (B): 150 MHz (provides ~1m range resolution)
#' - Chirp duration (Tc): 100 microseconds
#' - Number of chirps: 128 (for velocity estimation via 2D-FFT)
#' - Sampling rate: 1.5 MHz (10 samples per microsecond)
#' - Target 1: Range = 50 m, Velocity = -3 m/s (receding)
#' - Target 2: Range = 80 m, Velocity = -7 m/s (receding)
#'

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
# 1. RADAR SYSTEM PARAMETERS
# =============================================================================

cat("=== FMCW Radar Chirp Simulation - Automotive Scene ===\n")
cat("Simulating a realistic automotive FMCW radar with two moving targets\n\n")

# Physical constants
c <- 3e8  # Speed of light [m/s]

# Radar system parameters (typical automotive 77 GHz FMCW radar)
f0 <- 77e9      # Carrier frequency [Hz] (77 GHz)
B <- 150e6     # Sweep bandwidth [Hz] (150 MHz -> ~1m range resolution)
Tc <- 100e-6   # Chirp duration [s] (100 microseconds)
fs <- 15e6     # Sampling frequency [Hz] (1.5 MHz -> 10 samples/microsecond)

# Calculate derived parameters
lambda <- c / f0  # Wavelength [m]
mu <- B / Tc     # Chirp slope [Hz/s]

cat("1. RADAR SYSTEM PARAMETERS:\n")
cat(sprintf("   Carrier frequency (f0): %.1f GHz\n", f0 / 1e9))
cat(sprintf("   Wavelength (lambda): %.4f mm\n", lambda * 1000))
cat(sprintf("   Sweep bandwidth (B): %.1f MHz\n", B / 1e6))
cat(sprintf("   Chirp duration (Tc): %.1f us\n", Tc * 1e6))
cat(sprintf("   Chirp slope (mu): %.2e Hz/s\n", mu))
cat(sprintf("   Sampling frequency (fs): %.1f MHz\n", fs / 1e6))
cat(sprintf("   Range resolution: %.2f m\n", c / (2 * B)))
cat(sprintf("   Maximum unambiguous range: %.1f m\n", c * Tc / 2))
cat("\n")

# =============================================================================
# 2. TARGET SPECIFICATIONS
# =============================================================================

# Define two targets
R1 <- 50   # Range of target 1 [m]
vr1 <- -3  # Velocity of target 1 [m/s] (negative = receding)

R2 <- 80   # Range of target 2 [m]
vr2 <- -7  # Velocity of target 2 [m/s] (negative = receding)

# Calculate Doppler shifts for each target
fd1 <- (2 * vr1 * f0) / c  # Doppler shift [Hz]
fd2 <- (2 * vr2 * f0) / c  # Doppler shift [Hz]

# Calculate time delays for each target
tau1 <- (2 * R1) / c  # Round-trip time delay [s]
tau2 <- (2 * R2) / c  # Round-trip time delay [s]

cat("2. TARGET SPECIFICATIONS:\n")
cat("   Target 1:\n")
cat(sprintf("     Range (R1): %.1f m\n", R1))
cat(sprintf("     Velocity (vr1): %.1f m/s (%s)\n", vr1, ifelse(vr1 < 0, "receding", "approaching")))
cat(sprintf("     Doppler shift (fd1): %.2f Hz\n", fd1))
cat(sprintf("     Time delay (tau1): %.3f us\n", tau1 * 1e6))
cat("\n")
cat("   Target 2:\n")
cat(sprintf("     Range (R2): %.1f m\n", R2))
cat(sprintf("     Velocity (vr2): %.1f m/s (%s)\n", vr2, ifelse(vr2 < 0, "receding", "approaching")))
cat(sprintf("     Doppler shift (fd2): %.2f Hz\n", fd2))
cat(sprintf("     Time delay (tau2): %.3f us\n", tau2 * 1e6))
cat("\n")

# =============================================================================
# 3. GENERATE TIME VECTOR FOR ONE CHIRP
# =============================================================================

N_samples <- floor(Tc * fs)  # Number of samples per chirp
if (N_samples != Tc * fs) {
  warning("Sampling parameters adjusted to fit integer number of samples")
  fs <- N_samples / Tc
}

t <- seq(0, Tc - 1/fs, by = 1/fs)  # Time vector for one chirp [s]

cat("3. SAMPLING:\n")
cat(sprintf("   Number of samples per chirp (N): %d\n", N_samples))
cat(sprintf("   Sampling interval: %.3f us\n", 1/fs * 1e6))
cat(sprintf("   Adjusted sampling frequency: %.3f MHz\n", fs / 1e6))
cat("\n")

# =============================================================================
# 4. GENERATE TRANSMITTED CHIRP SIGNAL
# =============================================================================

# Transmitted signal: linear frequency modulation
# s_tx(t) = cos(2 * pi * (f0 * t + 0.5 * mu * t^2))
# For simulation, we'll use the phase directly (baseband representation)

# Using baseband representation (I/Q signals)
# Transmitted phase: phi_tx = 2 * pi * (f0 * t + 0.5 * mu * t^2)
# But f0 is very high (77 GHz), so we'll work with the beat frequencies directly

# For visualization, we'll show the instantaneous frequency
f_tx_inst <- f0 + mu * t  # Instantaneous frequency of transmitted chirp [Hz]

cat("4. TRANSMITTED CHIRP SIGNAL:\n")
cat("   Generated linear frequency modulated (LFM) chirp\n")
cat(sprintf("   Start frequency: %.3f GHz\n", f0 / 1e9))
cat(sprintf("   End frequency: %.3f GHz\n", (f0 + B) / 1e9))
cat(sprintf("   Frequency sweep: %.1f MHz over %.1f us\n", B / 1e6, Tc * 1e6))
cat("\n")

# =============================================================================
# 5. SIMULATE RECEIVED SIGNALS FROM TARGETS
# =============================================================================

cat("5. RECEIVED SIGNALS:\n")

# For each target, the received signal has:
# - Time delay: tau (round-trip)
# - Doppler shift: fd (from target motion)
# - Amplitude reduction: proportional to 1/R^4 (radar equation simplified)

# Target 1 received signal
# Instantaneous frequency at time t:
# fr1_inst(t) = f0 + mu * (t - tau1) + fd1
fr1_inst <- f0 + mu * (t - tau1) + fd1

# Target 2 received signal
fr2_inst <- f0 + mu * (t - tau2) + fd2

cat("   Target 1 received signal:\n")
cat(sprintf("     Doppler shift: %.2f Hz\n", fd1))
cat(sprintf("     Delay: %.3f us\n", tau1 * 1e6))
cat("\n")
cat("   Target 2 received signal:\n")
cat(sprintf("     Doppler shift: %.2f Hz\n", fd2))
cat(sprintf("     Delay: %.3f us\n", tau2 * 1e6))
cat("\n")

# =============================================================================
# 6. BEAT SIGNAL GENERATION (MIXING)
# =============================================================================

# Beat frequency for each target (range component)
fb_range1 <- mu * tau1  # From time delay
fb_range2 <- mu * tau2  # From time delay

# Total beat frequency for each target (includes Doppler)
# For FMCW: fb = mu * tau + fd
# But fd is very small compared to mu * tau in our case
fb1 <- mu * tau1 + fd1
fb2 <- mu * tau2 + fd2

cat("6. BEAT SIGNAL ANALYSIS:\n")
cat("   Beat frequencies from mixing transmitted and received signals:\n")
cat("\n")
cat("   Target 1:\n")
cat(sprintf("     Range component (mu * tau1): %.2f kHz\n", fb_range1 / 1000))
cat(sprintf("     Doppler component (fd1): %.2f Hz\n", fd1))
cat(sprintf("     Total beat frequency (fb1): %.2f kHz\n", fb1 / 1000))
cat("\n")
cat("   Target 2:\n")
cat(sprintf("     Range component (mu * tau2): %.2f kHz\n", fb_range2 / 1000))
cat(sprintf("     Doppler component (fd2): %.2f Hz\n", fd2))
cat(sprintf("     Total beat frequency (fb2): %.2f kHz\n", fb2 / 1000))
cat("\n")

# Calculate expected ranges from beat frequencies
R1_from_fb <- (fb_range1 * c * Tc) / (2 * B)
R2_from_fb <- (fb_range2 * c * Tc) / (2 * B)

# Calculate velocities from Doppler shifts
vr1_from_fd <- (fd1 * c) / (2 * f0)
vr2_from_fd <- (fd2 * c) / (2 * f0)

cat("7. RANGE AND VELOCITY ESTIMATION:\n")
cat("   From beat frequency range component:\n")
cat(sprintf("     Target 1 range: %.3f m (expected: %.1f m)\n", R1_from_fb, R1))
cat(sprintf("     Target 2 range: %.3f m (expected: %.1f m)\n", R2_from_fb, R2))
cat("\n")
cat("   From Doppler shift:\n")
cat(sprintf("     Target 1 velocity: %.3f m/s (expected: %.1f m/s)\n", vr1_from_fd, vr1))
cat(sprintf("     Target 2 velocity: %.3f m/s (expected: %.1f m/s)\n", vr2_from_fd, vr2))
cat("\n")

# =============================================================================
# 8. GENERATE BASEBAND SIGNALS (for simulation and visualization)
# =============================================================================

# We'll work with baseband (beat frequency) signals for visualization
# These represent the difference between transmitted and received

# Beat signal for target 1 (baseband)
# s_beat1(t) = cos(2 * pi * fb1 * t)
fb1_baseband <- fb1  # Beat frequency for target 1
s_beat1 <- cos(2 * pi * fb1_baseband * t)

# Beat signal for target 2 (baseband)
fb2_baseband <- fb2  # Beat frequency for target 2
s_beat2 <- cos(2 * pi * fb2_baseband * t)

# Combined beat signal (superposition of both targets)
s_beat_combined <- s_beat1 + s_beat2

# For better visualization, let's also create the scene with proper scaling
# In reality, signal amplitude decreases with range (1/R^4 for radar cross-section)
A1 <- 1 / (R1^2)  # Amplitude scaling for target 1
A2 <- 1 / (R2^2)  # Amplitude scaling for target 2
s_beat1_scaled <- A1 * cos(2 * pi * fb1_baseband * t)
s_beat2_scaled <- A2 * cos(2 * pi * fb2_baseband * t)
s_beat_combined_scaled <- s_beat1_scaled + s_beat2_scaled

cat("8. BASEBAND SIGNAL GENERATION:\n")
cat("   Generated beat signals for visualization:\n")
cat(sprintf("     Target 1 beat frequency: %.2f kHz\n", fb1 / 1000))
cat(sprintf("     Target 2 beat frequency: %.2f kHz\n", fb2 / 1000))
cat(sprintf("     Combined signal contains both frequency components\n"))
cat("\n")

# =============================================================================
# 9. VISUALIZATION - Save plots to plots/ directory
# =============================================================================

cat("9. VISUALIZATION:\n")
cat("   Saving plots to 'plots/' directory...\n")

if (!dir.exists("plots")) {
  dir.create("plots")
}

# Plot 1: Transmitted chirp - Instantaneous frequency
png(file.path("plots", "fmcw_transmitted_chirp.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t * 1e6, f_tx_inst / 1e9, type = "l", col = "blue", lwd = 2,
     main = "Transmitted Chirp - Instantaneous Frequency",
     xlab = "Time [us]", ylab = "Frequency [GHz]",
     xlim = c(0, Tc * 1e6), ylim = c(f0/1e9, (f0 + B)/1e9))
abline(v = 0, col = "gray", lty = 2)
legend("topright", legend = sprintf("f0 = %.1f GHz, B = %.1f MHz", f0/1e9, B/1e6), bty = "n")
dev.off()

# Plot 2: Transmitted chirp - Frequency vs Time (linear sweep)
png(file.path("plots", "fmcw_chirp_linearity.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t * 1e6, f_tx_inst / 1e9, type = "l", col = "blue", lwd = 2,
     main = "Transmitted Chirp - Linear Frequency Sweep",
     xlab = "Time [us]", ylab = "Frequency [GHz]")
# Add start and end markers
points(c(0, Tc) * 1e6, c(f0, f0 + B) / 1e9, col = "red", pch = 19, cex = 1.5)
text(c(0, Tc) * 1e6, c(f0, f0 + B) / 1e9, 
     labels = c(sprintf("%.3f GHz", f0/1e9), sprintf("%.3f GHz", (f0+B)/1e9)),
     pos = c(4, 2), offset = c(0.5, 0.5), col = "red", cex = 0.8)
legend("topright", legend = sprintf("Slope = %.1f MHz/us", mu * 1e6 / 1e6), bty = "n")
dev.off()

# Plot 3: Received signals instantaneous frequencies
png(file.path("plots", "fmcw_received_frequencies.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t * 1e6, fr1_inst / 1e9, type = "l", col = "red", lwd = 2,
     main = "Received Signal Instantaneous Frequencies",
     xlab = "Time [us]", ylab = "Frequency [GHz]",
     ylim = c(f0/1e9, (f0 + B)/1e9))
lines(t * 1e6, fr2_inst / 1e9, col = "green", lwd = 2)
lines(t * 1e6, f_tx_inst / 1e9, col = "blue", lwd = 2, lty = 2)
abline(v = tau1 * 1e6, col = "red", lty = 3, lwd = 1)
abline(v = tau2 * 1e6, col = "green", lty = 3, lwd = 1)
legend("topright", 
       legend = c("Transmitted", "Target 1 (50m)", "Target 2 (80m)"),
       col = c("blue", "red", "green"), 
       lty = c(2, 1, 1), lwd = c(2, 2, 2), bty = "n")
dev.off()

# Plot 4: Beat signals for each target
png(file.path("plots", "fmcw_beat_signals.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t * 1e6, s_beat1, type = "l", col = "red", lwd = 2,
     main = "Beat Signals from Individual Targets",
     xlab = "Time [us]", ylab = "Amplitude",
     xlim = c(0, Tc * 1e6))
lines(t * 1e6, s_beat2, col = "green", lwd = 2)
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = c(sprintf("Target 1 (fb1 = %.1f kHz)", fb1/1000), 
                  sprintf("Target 2 (fb2 = %.1f kHz)", fb2/1000)),
       col = c("red", "green"), lty = c(1, 1), lwd = c(2, 2), bty = "n")
dev.off()

# Plot 5: Combined beat signal (both targets)
png(file.path("plots", "fmcw_combined_beat_signal.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t * 1e6, s_beat_combined, type = "l", col = "darkblue", lwd = 2,
     main = "Combined Beat Signal (Both Targets)",
     xlab = "Time [us]", ylab = "Amplitude")
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = c("Combined beat signal", "Target 1 + Target 2"),
       col = c("darkblue", "darkblue"), lty = c(1, 1), lwd = c(2, 2), bty = "n")
dev.off()

# Plot 6: Scaled combined beat signal (with amplitude based on range)
png(file.path("plots", "fmcw_scaled_beat_signal.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t * 1e6, s_beat_combined_scaled, type = "l", col = "darkblue", lwd = 2,
     main = "Scaled Combined Beat Signal (With Range Attenuation)",
     xlab = "Time [us]", ylab = "Amplitude")
lines(t * 1e6, s_beat1_scaled, col = "red", lwd = 1, lty = 2)
lines(t * 1e6, s_beat2_scaled, col = "green", lwd = 1, lty = 2)
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = c(sprintf("Combined (A1=1/%.0f^2, A2=1/%.0f^2)", R1, R2), 
                  sprintf("Target 1 (%.0f m)", R1), 
                  sprintf("Target 2 (%.0f m)", R2)),
       col = c("darkblue", "red", "green"), 
       lty = c(1, 2, 2), lwd = c(2, 1, 1), bty = "n")
dev.off()

# Plot 7: FFT of combined beat signal (range estimation)
fft_combined <- fft(s_beat_combined, N_samples)
fft_mag_combined <- abs(fft_combined) / N_samples
fft_mag_combined[2:(N_samples/2 + 1)] <- 2 * fft_mag_combined[2:(N_samples/2 + 1)]
freq_bins <- seq(0, fs/2, length.out = N_samples/2 + 1)

png(file.path("plots", "fmcw_fft_beat_signal.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(freq_bins / 1000, fft_mag_combined[1:(N_samples/2 + 1)], type = "l", 
     col = "darkgreen", lwd = 2,
     main = "FFT of Combined Beat Signal - Range Estimation",
     xlab = "Frequency [kHz]", ylab = "Magnitude")
abline(v = fb1 / 1000, col = "red", lwd = 2, lty = 2)
abline(v = fb2 / 1000, col = "blue", lwd = 2, lty = 2)
legend("topright", 
       legend = c("FFT magnitude", 
                  sprintf("Target 1 (%.1f kHz, %.0f m)", fb1/1000, R1),
                  sprintf("Target 2 (%.1f kHz, %.0f m)", fb2/1000, R2)),
       col = c("darkgreen", "red", "blue"), 
       lty = c(1, 2, 2), lwd = c(2, 2, 2), bty = "n")
dev.off()

# Plot 8: Scene visualization - Radar and targets
png(file.path("plots", "fmcw_scene_visualization.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)

# Draw radar at origin
plot(c(-10, 100), c(-5, 5), type = "n", 
     main = "Radar Scene Visualization - Automotive Scenario",
     xlab = "Range [m]", ylab = "", yaxt = "n",
     xlim = c(-5, 100), ylim = c(-2, 2))

# Draw radar
points(0, 0, pch = 19, cex = 3, col = "red")
text(0, 0, labels = "Radar (77 GHz)", pos = 4, offset = 1, col = "red")

# Draw targets
points(R1, 0, pch = 17, cex = 2, col = "blue")
text(R1, 0, labels = sprintf("Target 1\n%.0f m, %.1f m/s", R1, vr1), 
     pos = 3, offset = 0.5, col = "blue", cex = 0.8)

points(R2, 0, pch = 17, cex = 2, col = "green")
text(R2, 0, labels = sprintf("Target 2\n%.0f m, %.1f m/s", R2, vr2), 
     pos = 3, offset = 0.5, col = "green", cex = 0.8)

# Draw arrows showing motion
draw_arrow <- function(x, y, dx, color) {
  arrows(x, y, x + dx, y, length = 0.1, col = color, lwd = 2)
}

# Arrow for target 1 (receding)
draw_arrow(R1, 0, 5, "blue")
# Arrow for target 2 (receding)  
draw_arrow(R2, 0, 5, "green")

# Add legend
legend("topright", 
       legend = c("Radar (77 GHz FMCW)", "Target 1 (50m, -3m/s)", "Target 2 (80m, -7m/s)"),
       col = c("red", "blue", "green"), 
       pch = c(19, 17, 17), cex = c(2, 1.5, 1.5), bty = "n")

# Add grid
abline(h = 0, col = "gray", lty = 2)
dev.off()

# Plot 9: Signal processing chain overview
png(file.path("plots", "fmcw_signal_processing_chain.png"), width = 1200, height = 800)
par(mfrow = c(3, 2), mar = c(4, 5, 2, 1) + 0.1)

# Step 1: Transmitted chirp
plot(t * 1e6, f_tx_inst / 1e9, type = "l", col = "blue", lwd = 2,
     main = "Step 1: Transmitted Chirp", xlab = "Time [us]", ylab = "Frequency [GHz]")

# Step 2: Received from Target 1
plot(t * 1e6, fr1_inst / 1e9, type = "l", col = "red", lwd = 2,
     main = "Step 2: Received from Target 1", xlab = "Time [us]", ylab = "Frequency [GHz]")

# Step 3: Received from Target 2
plot(t * 1e6, fr2_inst / 1e9, type = "l", col = "green", lwd = 2,
     main = "Step 3: Received from Target 2", xlab = "Time [us]", ylab = "Frequency [GHz]")

# Step 4: Beat signal Target 1
plot(t * 1e6, s_beat1, type = "l", col = "red", lwd = 2,
     main = "Step 4: Beat Signal Target 1", xlab = "Time [us]", ylab = "Amplitude")

# Step 5: Beat signal Target 2
plot(t * 1e6, s_beat2, type = "l", col = "green", lwd = 2,
     main = "Step 5: Beat Signal Target 2", xlab = "Time [us]", ylab = "Amplitude")

# Step 6: Combined beat signal
plot(t * 1e6, s_beat_combined, type = "l", col = "darkblue", lwd = 2,
     main = "Step 6: Combined Beat Signal", xlab = "Time [us]", ylab = "Amplitude")

par(mfrow = c(1, 1))
dev.off()

# Plot 10: Range and velocity extraction visualization
png(file.path("plots", "fmcw_range_velocity_extraction.png"), width = 1000, height = 600)
par(mfrow = c(1, 2), mar = c(5, 6, 4, 2) + 0.1)

# Left: Range from beat frequency
freq_range <- c(fb_range1, fb_range2) / 1000
range_estimated <- c(R1_from_fb, R2_from_fb)
barplot(range_estimated, names.arg = c("Target 1", "Target 2"),
        col = c("red", "green"),
        main = "Range Estimation from Beat Frequency",
        ylab = "Range [m]", ylim = c(0, max(R1, R2) * 1.1))
abline(h = c(R1, R2), col = c("red", "green"), lwd = 2, lty = 2)
text(c(1, 2), c(R1, R2), labels = c(sprintf("%.1f m", R1), sprintf("%.1f m", R2)),
     pos = 1, offset = 1, col = c("red", "green"), cex = 0.8)

# Right: Velocity from Doppler
velocity_estimated <- c(vr1_from_fd, vr2_from_fd)
barplot(velocity_estimated, names.arg = c("Target 1", "Target 2"),
        col = c("red", "green"),
        main = "Velocity Estimation from Doppler",
        ylab = "Velocity [m/s]", ylim = c(min(vr1, vr2) * 1.1, max(vr1, vr2) * 1.1))
abline(h = c(vr1, vr2), col = c("red", "green"), lwd = 2, lty = 2)
text(c(1, 2), c(vr1, vr2), labels = c(sprintf("%.1f m/s", vr1), sprintf("%.1f m/s", vr2)),
     pos = ifelse(c(vr1, vr2) > 0, 1, 3), offset = 0.5, 
     col = c("red", "green"), cex = 0.8)

par(mfrow = c(1, 1))
dev.off()

# Plot 11: Preparation for 2D-FFT - Multiple chirps for velocity estimation
# For 2D-FFT, we need multiple chirps to detect velocity via phase shift
N_chirps <- 128  # Number of chirps for velocity estimation
chirp_repetition_time <- 1e-3  # Time between chirps (1 ms)

cat("10. PREPARATION FOR 2D-FFT:\n")
cat("   For velocity estimation, we need multiple chirps to observe phase changes\n")
cat(sprintf("   Number of chirps: %d\n", N_chirps))
cat(sprintf("   Chirp repetition time: %.1f ms\n", chirp_repetition_time * 1000))
cat("\n")

# Create a matrix of samples (N_chirps x N_samples)
# For simplicity, we'll show the concept without generating all data
# In practice, you would have a matrix where each row is a chirp's samples

# The phase shift between chirps gives velocity information
# For target 1: phase shift per chirp = 2 * pi * fd1 * chirp_repetition_time
phase_shift_per_chirp_1 <- 2 * pi * fd1 * chirp_repetition_time
phase_shift_per_chirp_2 <- 2 * pi * fd2 * chirp_repetition_time

cat("   Phase shift per chirp:\n")
cat(sprintf("     Target 1: %.4f radians (from fd1 = %.2f Hz)\n", 
            phase_shift_per_chirp_1, fd1))
cat(sprintf("     Target 2: %.4f radians (from fd2 = %.2f Hz)\n", 
            phase_shift_per_chirp_2, fd2))
cat("\n")

# Visualize the concept
png(file.path("plots", "fmcw_2dfft_preparation.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)

# Create a conceptual diagram
chirp_indices <- 1:N_chirps
time_axis <- chirp_indices * chirp_repetition_time * 1000  # in ms

# Phase evolution for target 1
phase1 <- cumsum(rep(phase_shift_per_chirp_1, N_chirps))
# Phase evolution for target 2
phase2 <- cumsum(rep(phase_shift_per_chirp_2, N_chirps))

# Plot phase evolution over chirps
plot(time_axis, phase1, type = "l", col = "red", lwd = 2,
     main = "Phase Evolution Across Chirps for 2D-FFT",
     xlab = "Chirp Index", ylab = "Phase [radians]",
     xlim = c(1, N_chirps))
lines(time_axis, phase2, col = "green", lwd = 2)
legend("topright",
       legend = c(sprintf("Target 1 (fd = %.2f Hz)", fd1),
                  sprintf("Target 2 (fd = %.2f Hz)", fd2)),
       col = c("red", "green"), lty = c(1, 1), lwd = c(2, 2), bty = "n")
abline(h = 0, col = "gray", lty = 2)
dev.off()

cat("\n")
cat("Plots saved to 'plots/' directory:\n")
cat("   - plots/fmcw_transmitted_chirp.png - Transmitted chirp instantaneous frequency\n")
cat("   - plots/fmcw_chirp_linearity.png - Linear frequency sweep visualization\n")
cat("   - plots/fmcw_received_frequencies.png - Received signal frequencies from both targets\n")
cat("   - plots/fmcw_beat_signals.png - Individual beat signals for each target\n")
cat("   - plots/fmcw_combined_beat_signal.png - Combined beat signal (both targets)\n")
cat("   - plots/fmcw_scaled_beat_signal.png - Scaled beat signal with range attenuation\n")
cat("   - plots/fmcw_fft_beat_signal.png - FFT of beat signal showing frequency peaks\n")
cat("   - plots/fmcw_scene_visualization.png - Radar scene with targets\n")
cat("   - plots/fmcw_signal_processing_chain.png - Complete signal processing chain\n")
cat("   - plots/fmcw_range_velocity_extraction.png - Range and velocity estimation results\n")
cat("   - plots/fmcw_2dfft_preparation.png - Phase evolution for 2D-FFT preparation\n")

# =============================================================================
# 11. PRACTICAL CONTEXT IN AUTOMOTIVE SYSTEMS
# =============================================================================

cat("\n")
cat("Practical Context in Automotive FMCW Radar Systems:\n")
cat("========================================================\n\n")

cat("This simulation demonstrates the complete signal processing chain of an\n")
cat("automotive FMCW radar system, which is used in modern vehicles for:\n\n")

cat("1. ADAPTIVE CRUISE CONTROL (ACC):\n")
cat("   - Measures range and relative velocity of vehicles ahead\n")
cat("   - Adjusts vehicle speed to maintain safe following distance\n")
cat("   - Typical range: 1-200 m, velocity: -30 to +30 m/s\n\n")

cat("2. AUTONOMOUS EMERGENCY BRAKING (AEB):\n")
cat("   - Detects rapid closure rates indicating imminent collision\n")
cat("   - Triggers emergency braking when collision is unavoidable\n")
cat("   - Requires fast processing (typically < 100 ms)\n\n")

cat("3. BLIND SPOT DETECTION:\n")
cat("   - Monitors side and rear areas for vehicles in blind spots\n")
cat("   - Typical range: 1-50 m, angular coverage: +/- 45 degrees\n\n")

cat("4. PARKING ASSIST:\n")
cat("   - Short-range detection for obstacle avoidance during parking\n")
cat("   - Typical range: 0.1-10 m, high range resolution\n\n")

cat("Key Automotive FMCW Radar Characteristics:\n")
cat(sprintf("   - Operating frequency: 76-81 GHz (this demo: %.0f GHz)\n", f0 / 1e9))
cat(sprintf("   - Bandwidth: 100-300 MHz (this demo: %.0f MHz)\n", B / 1e6))
cat(sprintf("   - Chirp duration: 20-200 us (this demo: %.0f us)\n", Tc * 1e6))
cat(sprintf("   - Range resolution: %.2f m (from %.0f MHz bandwidth)\n", c / (2 * B), B / 1e6))
cat(sprintf("   - Maximum range: %.0f m (from %.0f us chirp)\n", c * Tc / 2, Tc * 1e6))
cat("\n")

cat("Signal Processing Pipeline:\n")
cat("   1. Generate chirp signal with linear FM\n")
cat("   2. Receive reflections from targets with delay and Doppler\n")
cat("   3. Mix transmitted and received to get beat signal\n")
cat("   4. Perform FFT on each chirp to get range information\n")
cat("   5. Perform FFT across chirps to get velocity information\n")
cat("   6. Combine into 2D-FFT for range-velocity map\n")
cat("   7. Detect and track targets in the map\n\n")

cat("Why FMCW for Automotive:\n")
cat("   - Single antenna for transmit and receive (compact design)\n")
cat("   - Simultaneous range and velocity measurement\n")
cat("   - High range resolution with moderate bandwidth\n")
cat("   - Low power consumption (suitable for battery-powered vehicles)\n")
cat("   - Good Doppler resolution for velocity estimation\n")

# =============================================================================
# 12. SUMMARY
# =============================================================================

cat("\n")
cat("=== SUMMARY ===\n")
cat("\n")
cat("This demonstration shows the complete FMCW radar signal processing chain:\n\n")

cat("Radar Configuration:\n")
cat(sprintf("   Carrier frequency: %.1f GHz\n", f0 / 1e9))
cat(sprintf("   Bandwidth: %.1f MHz\n", B / 1e6))
cat(sprintf("   Chirp duration: %.1f us\n", Tc * 1e6))
cat(sprintf("   Range resolution: %.2f m\n", c / (2 * B)))
cat("\n")

cat("Target Parameters:\n")
cat(sprintf("   Target 1: R = %.1f m, v = %.1f m/s\n", R1, vr1))
cat(sprintf("   Target 2: R = %.1f m, v = %.1f m/s\n", R2, vr2))
cat("\n")

cat("Extracted Parameters:\n")
cat(sprintf("   Target 1 beat frequency: %.2f kHz\n", fb1 / 1000))
cat(sprintf("   Target 1 range: %.3f m (error: %.3f m)\n", R1_from_fb, abs(R1 - R1_from_fb)))
cat(sprintf("   Target 1 velocity: %.3f m/s (error: %.3f m/s)\n", vr1_from_fd, abs(vr1 - vr1_from_fd)))
cat(sprintf("   Target 2 beat frequency: %.2f kHz\n", fb2 / 1000))
cat(sprintf("   Target 2 range: %.3f m (error: %.3f m)\n", R2_from_fb, abs(R2 - R2_from_fb)))
cat(sprintf("   Target 2 velocity: %.3f m/s (error: %.3f m/s)\n", vr2_from_fd, abs(vr2 - vr2_from_fd)))
cat("\n")

cat("The simulation successfully demonstrates:\n")
cat("   ✓ Transmitted chirp signal generation\n")
cat("   ✓ Target reflection modeling with delay and Doppler\n")
cat("   ✓ Beat signal extraction via mixing\n")
cat("   ✓ Range estimation from beat frequency\n")
cat("   ✓ Velocity estimation from Doppler shift\n")
cat("   ✓ Visualization of all intermediate signals\n")
cat("   ✓ Preparation for 2D-FFT (range-velocity map)\n\n")

cat("Next Steps:\n")
cat("   - Implement 2D-FFT to create a range-velocity heatmap\n")
cat("   - Add CFAR (Constant False Alarm Rate) detection\n")
cat("   - Implement target tracking across multiple frames\n")
cat("   - Add multi-target simulation with various ranges and velocities\n")

# =============================================================================
# REUSABLE FUNCTIONS
# =============================================================================

#' Calculate beat frequency for a target in FMCW radar
#' @param R Range to target [m]
#' @param vr Radial velocity [m/s] (positive = approaching)
#' @param f0 Carrier frequency [Hz]
#' @param B Sweep bandwidth [Hz]
#' @param Tc Chirp duration [s]
#' @param c Speed of light [m/s] (default: 3e8)
#' @return List containing beat frequency and its components
calc_beat_frequency_fmcw <- function(R, vr, f0, B, Tc, c = 3e8) {
  mu <- B / Tc
  tau <- 2 * R / c
  fd <- (2 * vr * f0) / c
  fb_range <- mu * tau
  fb_total <- mu * tau + fd
  
  list(
    beat_frequency = fb_total,
    range_component = fb_range,
    doppler_component = fd,
    time_delay = tau,
    doppler_shift = fd
  )
}

#' Calculate range from beat frequency in FMCW radar
#' @param fb Beat frequency [Hz]
#' @param B Sweep bandwidth [Hz]
#' @param Tc Chirp duration [s]
#' @param c Speed of light [m/s] (default: 3e8)
#' @return Estimated range [m]
calc_range_fmcw <- function(fb, B, Tc, c = 3e8) {
  (fb * c * Tc) / (2 * B)
}

#' Calculate velocity from Doppler shift
#' @param fd Doppler frequency shift [Hz]
#' @param f0 Carrier frequency [Hz]
#' @param c Speed of light [m/s] (default: 3e8)
#' @return Radial velocity [m/s]
calc_velocity_doppler <- function(fd, f0, c = 3e8) {
  (fd * c) / (2 * f0)
}
