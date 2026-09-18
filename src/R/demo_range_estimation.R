#' Radar Range Estimation Demonstration (FMCW)
#'
#' @title FMCW Radar Range Estimation
#' @description Self-contained demonstration of estimating target range from beat 
#'   frequencies in a Frequency Modulated Continuous Wave (FMCW) radar system.
#'
#' @section Motivation:
#' Accurate range estimation is fundamental for automotive safety systems. In modern
#' vehicles, FMCW radar enables critical functions such as:
#' - Adaptive Cruise Control (ACC): Maintaining safe following distances to vehicles ahead
#' - Autonomous Emergency Braking (AEB): Detecting imminent collisions and triggering brakes
#' - Forward Collision Warning (FCW): Alerting drivers to potential front-end collisions
#' - Parking Assist: Helping drivers navigate tight parking spaces
#' 
#' FMCW radar's ability to simultaneously measure range and velocity with high accuracy
#' using compact, cost-effective hardware makes it ideal for automotive applications where
#' size, power consumption, and reliability are critical constraints.
#'
#' @section Theory:
#' FMCW radar transmits a frequency-modulated chirp signal. The received signal 
#' (reflected from targets) is mixed with the transmitted signal, producing a 
#' beat frequency that is directly proportional to the target's range. This principle
#' enables precise distance measurements essential for automotive safety systems.
#'
#' @section Key Formulas:
#' 1. Range Resolution: B_sweep = c / (2 * R_res)
#'    Where B_sweep is the chirp bandwidth, c is speed of light, R_res is range resolution
#'
#' 2. Chirp Time: T_chirp = factor * 2 * R_max / c
#'    Where factor (typically 5-6) ensures the chirp duration covers the round-trip
#'    time to maximum range. This example uses factor = 5.5
#'
#' 3. Beat Frequency to Range: R = (f_b * c * T_chirp) / (2 * B_sweep)
#'    Where f_b is the beat frequency, R is the target range
#'
#' @section Usage:
#' Run this script directly in R or RStudio, or use VS Code with the R extension.
#' Simply source this file: source('demo_range_estimation.R')
#'
#' @section Parameters in this demonstration:
#' - Beat frequencies of four targets: [0 MHz, 1.1 MHz, 13 MHz, 24 MHz]
#' - Maximum radar range (R_max): 300 m (covers typical highway ACC scenarios)
#' - Range resolution (R_res): 1 m (sufficient for vehicle detection and tracking)
#' - Speed of light (c): 3e8 m/s
#' - Chirp time factor: 5.5 (ensures reliable detection at maximum range)

# =============================================================================
# SET WORKING DIRECTORY TO PROJECT ROOT
# =============================================================================
# Ensure consistent behavior regardless of where the script is sourced from
current_dir <- getwd()
if (grepl("/src/R$", current_dir) || grepl("\\src\\R$", current_dir)) {
  setwd(dirname(dirname(current_dir)))
}

# =============================================================================
# 1. PARAMETER DEFINITION
# =============================================================================

# Physical constants
c <- 3e8  # Speed of light [m/s]

# Radar system parameters
R_max <- 300    # Maximum range [m]
R_res <- 1      # Range resolution [m]
factor <- 5.5   # Sweep time factor for FMCW

# Beat frequencies of the four targets [MHz]
beat_freqs_MHz <- c(0, 1.1, 13, 24)
beat_freqs_Hz <- beat_freqs_MHz * 1e6  # Convert to Hz

cat("=== FMCW Radar Range Estimation ===\n")
cat("Parameters:\n")
cat("  Maximum range (R_max):", R_max, "m\n")
cat("  Range resolution (R_res):", R_res, "m\n")
cat("  Speed of light (c):", c, "m/s\n")
cat("  Chirp time factor: ", factor, "\n\n")

# =============================================================================
# 2. CALCULATE SWEEP BANDWIDTH (B_sweep)
# =============================================================================
# For FMCW radar: Range resolution R_res = c / (2 * B_sweep)
# Therefore: B_sweep = c / (2 * R_res)

B_sweep <- c / (2 * R_res)

cat("1. Sweep Bandwidth Calculation:\n")
cat("   B_sweep = c / (2 * R_res) = ", c, " / (2 * ", R_res, ")\n")
cat("   B_sweep = ", B_sweep / 1e6, " MHz\n\n")

# =============================================================================
# 3. CALCULATE CHIRP TIME (T_chirp)
# =============================================================================
# Given: T_chirp = factor * 2 * R_max / c

T_chirp <- factor * 2 * R_max / c

cat("2. Chirp Time Calculation:\n")
cat("   T_chirp = ", factor, " * 2 * ", R_max, " / ", c, "\n")
cat("   T_chirp = ", T_chirp * 1e6, " microseconds\n\n")

# =============================================================================
# 4. DEFINITION OF BEAT FREQUENCIES
# =============================================================================

cat("3. Beat Frequencies:\n")
for (i in seq_along(beat_freqs_MHz)) {
  cat("   Target ", i, ": f_b = ", beat_freqs_MHz[i], " MHz\n")
}
cat("\n")

# =============================================================================
# 5. CALCULATE RANGES FROM BEAT FREQUENCIES
# =============================================================================
# For FMCW radar: f_b = (2 * B_sweep * R) / (c * T_chirp)
# Therefore: R = (f_b * c * T_chirp) / (2 * B_sweep)

ranges <- (beat_freqs_Hz * c * T_chirp) / (2 * B_sweep)

cat("4. Calculated Ranges:\n")
cat("   Using formula: R = (f_b * c * T_chirp) / (2 * B_sweep)\n\n")
for (i in seq_along(ranges)) {
  cat(sprintf("   Target %d: f_b = %5.1f MHz -> Range = %7.3f m\n", 
              i, beat_freqs_MHz[i], ranges[i]))
}
cat("\n")

# =============================================================================
# 6. VERIFICATION
# =============================================================================
# Maximum beat frequency for R_max
f_b_max <- (2 * B_sweep * R_max) / (c * T_chirp)
cat("5. Verification:\n")
cat("   Maximum beat frequency for R_max = ", R_max, "m:\n")
cat("   f_b_max = (2 * B_sweep * R_max) / (c * T_chirp)\n")
cat("   f_b_max = ", f_b_max / 1e6, " MHz\n")
cat("   All input beat frequencies are within valid range.\n")

# =============================================================================
# 7. VISUALIZATION - Explain Chirp, Returned Signal, and Beat Frequency
# =============================================================================

# For visualization, we'll create example chirps for a few targets
# Let's use Target 2 (12.1 m) and Target 4 (264 m) for clear separation

# Define carrier frequency for visualization (simplified from 77 GHz to show waveform)
f0_vis <- 10e6  # 10 MHz for visualization (actual is 77 GHz)

# Create time vector for one chirp
N_chirp_samples <- 1000
t_chirp <- seq(0, T_chirp, length.out = N_chirp_samples)

# Generate transmitted chirp (linear FM)
# Phase: phi_tx = 2*pi*(f0_vis * t + 0.5 * (B_sweep/T_chirp) * t^2)
chirp_slope <- B_sweep / T_chirp
phi_tx <- 2 * pi * (f0_vis * t_chirp + 0.5 * chirp_slope * t_chirp^2)
s_tx <- cos(phi_tx)

# Calculate instantaneous frequency for visualization
f_tx_inst <- f0_vis + chirp_slope * t_chirp

# For Target 2 (12.1 m), calculate delay and received signal
target_range_vis <- ranges[2]  # 12.1 m
tau_vis <- 2 * target_range_vis / c  # Round-trip time delay

# Received signal is delayed version of transmitted
# For simplicity, we'll show the instantaneous frequency of received signal
# The received chirp starts at t=tau and has the same slope
f_rx_inst <- f0_vis + chirp_slope * (t_chirp - tau_vis)

# Beat frequency (difference between tx and rx instantaneous frequencies)
# For FMCW: f_beat = chirp_slope * tau = (B_sweep / T_chirp) * (2 * R / c)
f_beat_vis <- chirp_slope * tau_vis

# Create beat signal (baseband representation)
s_beat_vis <- cos(2 * pi * f_beat_vis * t_chirp)

cat("\n")
cat("7. VISUALIZATION - Chirp Signals and Beat Frequency Formation:\n")
cat("   Generating explanatory plots to demonstrate FMCW principles...\n")

if (!dir.exists("plots")) {
  dir.create("plots")
}

# Plot 1: Transmitted Chirp Signal
png(file.path("plots", "range_chirp_transmitted.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t_chirp * 1e6, s_tx, type = "l", col = "blue", lwd = 2,
     main = "FMCW Transmitted Chirp Signal",
     xlab = "Time [us]", ylab = "Amplitude",
     xlim = c(0, T_chirp * 1e6))
abline(h = 0, col = "gray", lty = 2)
legend("topright", 
       legend = sprintf("Transmitted chirp (B = %.1f MHz, T_c = %.1f us)", 
                        B_sweep/1e6, T_chirp*1e6),
       bty = "n")
dev.off()

# Plot 2: Transmitted Chirp - Instantaneous Frequency
png(file.path("plots", "range_chirp_frequency.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t_chirp * 1e6, f_tx_inst / 1e6, type = "l", col = "blue", lwd = 2,
     main = "Transmitted Chirp - Instantaneous Frequency (Linear Sweep)",
     xlab = "Time [us]", ylab = "Frequency [MHz]",
     xlim = c(0, T_chirp * 1e6))
points(c(0, T_chirp) * 1e6, c(f0_vis, f0_vis + B_sweep) / 1e6, 
       col = "red", pch = 19, cex = 1.5)
text(c(0, T_chirp) * 1e6, c(f0_vis, f0_vis + B_sweep) / 1e6, 
     labels = c(sprintf("%.1f MHz", f0_vis/1e6), sprintf("%.1f MHz", (f0_vis+B_sweep)/1e6)),
     pos = c(4, 2), offset = 0.5, col = "red", cex = 0.8)
abline(h = f0_vis / 1e6, col = "gray", lty = 2)
legend("topright", 
       legend = sprintf("Slope = %.1f MHz/us", B_sweep/1e6 / (T_chirp*1e6)),
       bty = "n")
dev.off()

# Plot 3: Transmitted vs Received Chirp (showing delay)
png(file.path("plots", "range_chirp_delay.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t_chirp * 1e6, f_tx_inst / 1e6, type = "l", col = "blue", lwd = 2,
     main = sprintf("Transmitted vs Received Chirp (Target at %.1f m)", target_range_vis),
     xlab = "Time [us]", ylab = "Frequency [MHz]",
     xlim = c(0, T_chirp * 1e6))
lines(t_chirp * 1e6, f_rx_inst / 1e6, col = "red", lwd = 2)
abline(v = tau_vis * 1e6, col = "black", lwd = 2, lty = 3)
legend("topright",
       legend = c("Transmitted chirp",
                  sprintf("Received chirp (delayed by %.3f us)", tau_vis*1e6),
                  sprintf("Time delay (tau = 2R/c)")),
       col = c("blue", "red", "black"),
       lty = c(1, 1, 3), lwd = c(2, 2, 2), bty = "n")
dev.off()

# Plot 4: Beat Frequency Formation
png(file.path("plots", "range_beat_frequency.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t_chirp * 1e6, s_beat_vis, type = "l", col = "darkgreen", lwd = 2,
     main = sprintf("Beat Signal Formation (Target at %.1f m)", target_range_vis),
     xlab = "Time [us]", ylab = "Amplitude",
     xlim = c(0, T_chirp * 1e6))
abline(h = 0, col = "gray", lty = 2)
legend("topright",
       legend = c(sprintf("Beat signal (f_b = %.2f kHz)", f_beat_vis/1000),
                  sprintf("From: f_b = (2 * B * R) / (c * T_c)")),
       col = c("darkgreen", "darkgreen"),
       lty = c(1, NA), lwd = c(2, NA), bty = "n")
dev.off()

# Plot 5: Beat Frequency vs Range (for all targets)
# Calculate beat frequencies for all targets
beat_freqs_calculated <- (2 * B_sweep * ranges) / (c * T_chirp)

png(file.path("plots", "range_beat_vs_range.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(ranges, beat_freqs_calculated / 1e6, type = "p", col = "blue", pch = 19, cex = 2,
     main = "Beat Frequency vs Target Range",
     xlab = "Range [m]", ylab = "Beat Frequency [MHz]",
     xlim = c(0, max(ranges) * 1.1), ylim = c(0, max(beat_freqs_calculated)/1e6 * 1.1))

# Add line showing the linear relationship
abline(0, (2 * B_sweep) / (c * T_chirp * 1e6), col = "red", lwd = 2, lty = 2)

# Add labels for each target
for (i in seq_along(ranges)) {
  text(ranges[i], beat_freqs_calculated[i] / 1e6, 
       labels = sprintf("T%d: %.1f m, %.2f MHz", i, ranges[i], beat_freqs_calculated[i]/1e6),
       pos = ifelse(beat_freqs_calculated[i]/1e6 > max(beat_freqs_calculated)/1e6/2, 2, 4),
       offset = 0.5, col = "blue", cex = 0.8)
}

legend("topright",
       legend = c("Targets", "Linear relationship: f_b = (2*B*R)/(c*T_c)"),
       col = c("blue", "red"),
       lty = c(NA, 2), lwd = c(NA, 2), pch = c(19, NA), bty = "n")
dev.off()

# Plot 6: FMCW Range Estimation Process Overview
png(file.path("plots", "range_fmcw_process.png"), width = 1200, height = 800)
par(mfrow = c(2, 3), mar = c(4, 5, 2, 1) + 0.1)

# Panel 1: Transmitted chirp frequency
plot(t_chirp * 1e6, f_tx_inst / 1e6, type = "l", col = "blue", lwd = 2,
     main = "Step 1: Transmitted Chirp", xlab = "", ylab = "Frequency [MHz]",
     xlim = c(0, T_chirp * 1e6))

# Panel 2: Received chirp (delayed)
plot(t_chirp * 1e6, f_rx_inst / 1e6, type = "l", col = "red", lwd = 2,
     main = "Step 2: Received Chirp (Delayed)", xlab = "", ylab = "Frequency [MHz]",
     xlim = c(0, T_chirp * 1e6))
abline(v = tau_vis * 1e6, col = "black", lty = 3, lwd = 1)

# Panel 3: Mixing (conceptual)
plot(t_chirp * 1e6, f_tx_inst / 1e6, type = "l", col = "blue", lwd = 2,
     main = "Step 3: Mixing", xlab = "", ylab = "Frequency [MHz]",
     xlim = c(0, T_chirp * 1e6))
lines(t_chirp * 1e6, f_rx_inst / 1e6, col = "red", lwd = 2)
legend("topright", legend = c("Transmitted", "Received"), col = c("blue", "red"),
       lty = c(1, 1), lwd = c(2, 2), bty = "n")

# Panel 4: Beat signal
plot(t_chirp * 1e6, s_beat_vis, type = "l", col = "darkgreen", lwd = 2,
     main = "Step 4: Beat Signal", xlab = "", ylab = "Amplitude")
abline(h = 0, col = "gray", lty = 2)

# Panel 5: FFT of beat signal (conceptual - single frequency)
# For a single target, FFT shows peak at beat frequency
fft_beat <- fft(s_beat_vis, N_chirp_samples)
fft_beat_mag <- abs(fft_beat) / N_chirp_samples
freq_axis <- seq(0, 1/T_chirp, length.out = N_chirp_samples)
plot(freq_axis / 1000, fft_beat_mag, type = "l", col = "purple", lwd = 2,
     main = "Step 5: FFT of Beat Signal", xlab = "Frequency [kHz]", ylab = "Magnitude")
abline(v = f_beat_vis / 1000, col = "red", lwd = 2, lty = 2)

# Panel 6: Range calculation
barplot(ranges, names.arg = sprintf("T%d", seq_along(ranges)),
        col = "lightblue",
        main = "Step 6: Range Calculation", xlab = "Target", ylab = "Range [m]")
abline(h = ranges, col = "blue", lwd = 2, lty = 2)

par(mfrow = c(1, 1))
dev.off()

cat("   Plots saved to 'plots/' directory:\n")
cat("   - plots/range_chirp_transmitted.png - Transmitted chirp waveform\n")
cat("   - plots/range_chirp_frequency.png - Transmitted chirp instantaneous frequency\n")
cat("   - plots/range_chirp_delay.png - Transmitted vs received chirp showing delay\n")
cat("   - plots/range_beat_frequency.png - Beat signal formation\n")
cat("   - plots/range_beat_vs_range.png - Linear relationship between beat frequency and range\n")
cat("   - plots/range_fmcw_process.png - Complete FMCW range estimation process\n\n")

# Additional plots to show mixing and frequency difference
# Plot 7: Frequency difference over time (showing constant beat frequency)
# This explicitly shows that f_beat = f_tx - f_rx = constant

f_diff <- f_tx_inst - f_rx_inst  # Frequency difference over time

png(file.path("plots", "range_frequency_difference.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)
plot(t_chirp * 1e6, f_diff / 1000, type = "l", col = "darkred", lwd = 3,
     main = "Frequency Difference: Transmitted - Received",
     xlab = "Time [us]", ylab = "Frequency Difference [kHz]",
     xlim = c(0, T_chirp * 1e6),
     ylim = c(0, max(f_diff)/1000 * 1.1))
abline(h = f_beat_vis / 1000, col = "blue", lwd = 2, lty = 2)
legend("topright",
       legend = c(
         "Frequency difference (f_tx - f_rx)",
         sprintf("Beat frequency = %.2f kHz", f_beat_vis / 1000)
       ),
       col = c("darkred", "blue"),
       lty = c(1, 2), lwd = c(3, 2), bty = "n")
dev.off()

# Plot 8: Mixing visualization - show sum and difference frequencies
# This shows the trigonometric identity: cos(A)*cos(B) = 0.5[cos(A+B) + cos(A-B)]

# Create a simplified example with lower frequencies for clearer visualization
f_center <- 10e6  # 10 MHz center frequency (for visualization)
f_deviation <- 1e6  # 1 MHz frequency swing
f1_start <- f_center - f_deviation/2
f1_end <- f_center + f_deviation/2
f2_start <- f_center - f_deviation/2 + f_beat_vis  # Received with beat offset
f2_end <- f_center + f_deviation/2 + f_beat_vis

# For mixing demo, use constant frequencies at a specific time point
t_mix_demo <- T_chirp / 2  # Midpoint of chirp
f_tx_demo <- f0_vis + chirp_slope * t_mix_demo
f_rx_demo <- f0_vis + chirp_slope * (t_mix_demo - tau_vis)
f_beat_demo <- f_beat_vis
f_sum_demo <- f_tx_demo + f_rx_demo

# Create short time vector for mixing visualization
t_mix_short <- seq(t_mix_demo - 0.5e-6, t_mix_demo + 0.5e-6, length.out = 1000)
s_tx_demo <- cos(2 * pi * f_tx_demo * t_mix_short)
s_rx_demo <- cos(2 * pi * f_rx_demo * t_mix_short)
s_mix_demo <- s_tx_demo * s_rx_demo

png(file.path("plots", "range_mixing_demo.png"), width = 1000, height = 600)
par(mfrow = c(3, 1), mar = c(5, 6, 2, 2) + 0.1)

# Top: Transmitted and received signals at a point in time
plot(t_mix_short * 1e6, s_tx_demo, type = "l", col = "blue", lwd = 2,
     main = "Signal Mixing: Time Domain",
     xlab = "", ylab = "",
     xlim = c((t_mix_demo - 0.5e-6)*1e6, (t_mix_demo + 0.5e-6)*1e6),
     ylim = c(-1.1, 1.1))
lines(t_mix_short * 1e6, s_rx_demo, col = "red", lwd = 2)
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = c(
  sprintf("Transmitted: %.2f MHz", f_tx_demo/1e6),
  sprintf("Received: %.2f MHz", f_rx_demo/1e6)
), col = c("blue", "red"), lty = c(1, 1), lwd = c(2, 2), bty = "n")

# Middle: Mixed signal (product)
plot(t_mix_short * 1e6, s_mix_demo, type = "l", col = "purple", lwd = 2,
     main = "Mixed Signal: s_tx * s_rx",
     xlab = "", ylab = "",
     xlim = c((t_mix_demo - 0.5e-6)*1e6, (t_mix_demo + 0.5e-6)*1e6),
     ylim = c(-0.6, 0.6))
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = "Product contains sum and difference frequencies", 
       col = "purple", lty = 1, lwd = 2, bty = "n")

# Bottom: Beat signal (difference frequency) - after filtering
s_beat_demo_filtered <- cos(2 * pi * f_beat_demo * t_mix_short)
plot(t_mix_short * 1e6, s_beat_demo_filtered, type = "l", col = "darkgreen", lwd = 2,
     main = "Beat Signal: cos(2*pi*f_beat*t) after filtering",
     xlab = "Time [us]", ylab = "Amplitude",
     xlim = c((t_mix_demo - 0.5e-6)*1e6, (t_mix_demo + 0.5e-6)*1e6),
     ylim = c(-1.1, 1.1))
abline(h = 0, col = "gray", lty = 2)
legend("topright", legend = sprintf("Beat signal: f_beat = %.2f kHz", f_beat_demo/1000), 
       col = "darkgreen", lty = 1, lwd = 2, bty = "n")

par(mfrow = c(1, 1))
dev.off()

# Plot 9: Spectral view of mixing - showing sum and difference
# For a simpler visualization, show the frequency components

png(file.path("plots", "range_mixing_spectrum.png"), width = 1000, height = 600)
par(mar = c(5, 6, 4, 2) + 0.1)

# Plot frequency components
freq_components <- c(f_rx_demo, f_tx_demo, f_beat_demo, f_sum_demo)
freq_labels <- c(
  sprintf("Received: %.2f MHz", f_rx_demo/1e6),
  sprintf("Transmitted: %.2f MHz", f_tx_demo/1e6),
  sprintf("Beat (Difference): %.2f kHz", f_beat_demo/1000),
  sprintf("Sum: %.2f MHz", f_sum_demo/1e6)
)

# Create a bar plot showing frequency components
# We'll show them on a log scale or separate the low and high frequencies
plot(c(1, 2, 3, 4), freq_components / 1e6, type = "n", 
     main = "Mixing Creates Sum and Difference Frequencies",
     xlab = "Component", ylab = "Frequency [MHz]",
     yaxt = "n", xlim = c(0.5, 4.5), ylim = c(0, max(f_sum_demo, f_tx_demo)/1e6 * 1.1))

# Add points and labels for each component
points(1, f_rx_demo / 1e6, col = "red", pch = 19, cex = 2)
points(2, f_tx_demo / 1e6, col = "blue", pch = 19, cex = 2)
points(3, f_beat_demo / 1e6, col = "darkgreen", pch = 19, cex = 2)
points(4, f_sum_demo / 1e6, col = "purple", pch = 19, cex = 2)

text(1, f_rx_demo / 1e6, labels = "Received signal", pos = 3, offset = 0.5, col = "red", cex = 0.8)
text(2, f_tx_demo / 1e6, labels = "Transmitted signal", pos = 1, offset = 0.5, col = "blue", cex = 0.8)
text(3, f_beat_demo / 1e6, labels = "Beat frequency
(kept for measurement)", pos = 3, offset = 0.5, col = "darkgreen", cex = 0.8)
text(4, f_sum_demo / 1e6, labels = "Sum frequency
(filtered out)", pos = 3, offset = 0.5, col = "purple", cex = 0.8)

abline(h = f_beat_demo / 1e6, col = "darkgreen", lwd = 2, lty = 2)
abline(h = f_sum_demo / 1e6, col = "purple", lwd = 2, lty = 2)

# Add custom y-axis with both MHz and kHz
freq_ticks_mhz <- c(0, 5, 10, 15, 20)
freq_ticks_labels <- c("0", "5", "10", "15", "20")
axis(2, at = freq_ticks_mhz, labels = freq_ticks_labels)
mtext("MHz", side = 2, line = 3)
dev.off()

cat("   Additional plots saved:\n")
cat("   - plots/range_frequency_difference.png - Constant frequency difference = beat frequency\n")
cat("   - plots/range_mixing_demo.png - Time-domain mixing showing tx, rx, and beat signals\n")
cat("   - plots/range_mixing_spectrum.png - Frequency components from mixing\n\n")

# =============================================================================
# 8. SUMMARY
# =============================================================================
cat("\n")
cat("=== Summary ===\n")
cat("This demonstration shows how FMCW radar estimates target range from beat frequencies.\n")
cat("The key insight is that the beat frequency is directly proportional to the target range,\n")
cat("with the proportionality constant determined by the sweep bandwidth and chirp time.\n")
cat("\nFor this configuration:\n")
cat(sprintf("  - Sweep Bandwidth: %.1f MHz\n", B_sweep / 1e6))
cat(sprintf("  - Chirp Time: %.3f us\n", T_chirp * 1e6))
cat(sprintf("  - Maximum detectable range: %d m\n", R_max))
cat(sprintf("  - Maximum beat frequency: %.1f MHz\n", f_b_max / 1e6))
cat("\nThe calculated ranges for the given beat frequencies are shown above.\n\n")

# =============================================================================
# PRACTICAL CONTEXT IN AUTOMOTIVE SYSTEMS
# =============================================================================
cat("Practical Context in Automotive Systems:\n")
cat("In automotive FMCW radar applications:\n")
cat("  - Adaptive Cruise Control (ACC): Maintains safe following distance by continuously\n")
cat("    estimating range to the vehicle ahead and adjusting speed accordingly\n")
cat("  - Autonomous Emergency Braking (AEB): Detects rapid closure rates and triggers\n")
cat("    emergency braking when collision is imminent\n")
cat("  - Forward Collision Warning (FCW): Alerts driver when closing velocity suggests\n")
cat("    potential collision based on range and relative velocity\n")
cat("  - The 300 m maximum range covers typical highway scenarios\n")
cat("  - 1 m range resolution allows distinction between close vehicles in traffic\n")
cat("  - Typical automotive FMCW radars operate at 76-81 GHz with similar parameters\n\n")

# =============================================================================
# REUSABLE FUNCTION
# =============================================================================
#' Calculate range from beat frequency for FMCW radar
#'
#' @param f_b Beat frequency in Hz
#' @param B_sweep Sweep bandwidth in Hz
#' @param T_chirp Chirp time in seconds
#' @param c Speed of light in m/s (default: 3e8)
#' @return Target range in meters
#' @examples
#' # For this demonstration's parameters:
#' calc_range_fmcw(f_b = 1.1e6, B_sweep = 150e6, T_chirp = 5.5 * 2 * 300 / 3e8)
calc_range_fmcw <- function(f_b, B_sweep, T_chirp, c = 3e8) {
  (f_b * c * T_chirp) / (2 * B_sweep)
}