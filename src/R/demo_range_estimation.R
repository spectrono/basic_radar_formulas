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
# 7. SUMMARY
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