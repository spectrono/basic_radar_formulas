#' Radar Doppler Velocity Estimation Demonstration
#'
#' @title Doppler Effect in Radar - Velocity Estimation
#' @description Self-contained demonstration of calculating target velocity from Doppler
#'   frequency shifts in a radar system.
#'
#' @section Theory:
#' The Doppler effect describes the shift in frequency of a wave for an observer moving
#' relative to its source. In radar systems, the Doppler frequency shift of the returned
#' signal is directly proportional to the radial velocity of the target.
#'
#' When a radar transmits a signal with frequency f0, the received signal from a moving
#' target exhibits a frequency shift fd (Doppler shift). For a monostatic radar (transmitter
#' and receiver co-located), the relationship between Doppler shift and radial velocity is:
#'
#'   fd = 2 * vr / lambda
#'
#' where:
#' - fd is the Doppler frequency shift (in Hz)
#' - vr is the radial velocity of the target (in m/s)
#' - lambda is the wavelength of the transmitted signal (in m)
#'
#' The factor of 2 arises because the signal travels to the target and back, so the
#' Doppler shift occurs twice: once when the signal hits the moving target, and again
#' when the reflected signal returns to the receiver.
#'
#' @section Key Formulas:
#' 1. Wavelength: lambda = c / f0
#'    Where c is the speed of light and f0 is the radar operating frequency
#'
#' 2. Doppler to Velocity: vr = (fd * lambda) / 2
#'    Rearranged from fd = 2 * vr / lambda
#'
#' 3. Alternatively: vr = (fd * c) / (2 * f0)
#'    Substituting lambda = c / f0 into the velocity formula
#'
#' @section Motivation of the Formula:
#' The Doppler effect occurs because of the relative motion between the radar and the target.
#' 
#' Consider a radar transmitting at frequency f0 with wavelength lambda = c/f0.
#' 
#' For a target moving toward the radar at velocity vr:
#' - The transmitted signal encounters the target, which is moving toward it. The
#'   effective frequency at the target is increased due to the Doppler effect.
#' - The target reflects this shifted signal. Since the target is also moving, it
#'   acts as a moving source, causing a second Doppler shift in the reflected signal.
#' - The radar receiver detects a signal with frequency f0 + fd (for approaching targets)
#'   or f0 - fd (for receding targets).
#'
#' The total Doppler shift fd is the sum of both shifts:
#' - Shift on reception at target: f0 * (1 + vr/c) ≈ f0 + f0 * vr/c
#' - Shift on transmission from target (as moving source): (f0 + f0*vr/c) * (1 + vr/c) ≈ f0 + 2*f0*vr/c
#' 
#' Therefore: fd = 2 * f0 * vr / c = 2 * vr / lambda
#'
#' The sign of fd indicates direction:
#' - Positive fd: target approaching (vr > 0, moving toward radar)
#' - Negative fd: target receding (vr < 0, moving away from radar)
#'
#' @section Usage:
#' Run this script directly in R or RStudio, or use VS Code with the R extension.
#' Simply source this file: source('demo_doppler_velocity.R')
#'
#' @section Parameters in this demonstration:
#' - Doppler frequency shifts of four targets: [3 kHz, -4.5 kHz, 11 kHz, -3 kHz]
#' - Radar operating frequency (f0): 77 GHz
#' - Speed of light (c): 3e8 m/s

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

# Physical constants
c <- 3e8  # Speed of light [m/s]

# Radar system parameters
f0_GHz <- 77  # Operating frequency [GHz]
f0_Hz <- f0_GHz * 1e9  # Convert to Hz

# Doppler frequency shifts of four targets [kHz]
doppler_shifts_kHz <- c(3, -4.5, 11, -3)
doppler_shifts_Hz <- doppler_shifts_kHz * 1000  # Convert to Hz

cat("=== Doppler Effect - Radar Velocity Estimation ===\n")
cat("Parameters:\n")
cat("  Radar operating frequency (f0):", f0_GHz, "GHz (", f0_Hz, "Hz)\n")
cat("  Speed of light (c):", c, "m/s\n")
cat("  Doppler frequency shifts:", paste(doppler_shifts_kHz, "kHz"), "\n\n")

# =============================================================================
# 2. CALCULATE WAVELENGTH (lambda)
# =============================================================================
# The wavelength is the distance the wave travels in one period.
# For electromagnetic waves: lambda = c / f0
#
# This is a fundamental relationship: wave speed = frequency * wavelength
# For light (and radar waves, which are electromagnetic): c = f0 * lambda

lambda <- c / f0_Hz

cat("1. Wavelength Calculation:\n")
cat("   lambda = c / f0 = ", c, " / ", f0_Hz, "\n")
cat(sprintf("   lambda = %.6f m = %.3f mm\n\n", lambda, lambda * 1000))

# =============================================================================
# 3. VERIFY DOPPLER SHIFT FORMULA
# =============================================================================
# Let's verify the relationship: fd = 2 * vr / lambda
# This can also be written as: vr = (fd * lambda) / 2
#
# Substituting lambda = c / f0:
#   vr = (fd * c) / (2 * f0)
#
# This shows that the Doppler shift is directly proportional to the radial velocity.
# The factor of 2 accounts for the round-trip of the signal.

cat("2. Doppler Shift Formula:\n")
cat("   The fundamental relationship is: fd = 2 * vr / lambda\n")
cat("   \n")
cat("   Motivation:\n")
cat("   - When radar wave hits a moving target, the frequency shifts\n")
cat("   - The shift occurs TWICE: once at the target, once on return\n")
cat("   - For approach: fd > 0, for recession: fd < 0\n")
cat("   \n")
cat("   Rearranged for velocity: vr = (fd * lambda) / 2\n")
cat("   Alternative form: vr = (fd * c) / (2 * f0)\n\n")

# =============================================================================
# 4. CALCULATE RADIAL VELOCITIES
# =============================================================================
# Using: vr = (fd * lambda) / 2
# Or equivalently: vr = (fd * c) / (2 * f0)

# Method 1: Using wavelength
velocities_method1 <- (doppler_shifts_Hz * lambda) / 2

# Method 2: Using frequency (should give same result)
velocities_method2 <- (doppler_shifts_Hz * c) / (2 * f0_Hz)

# Verify both methods give identical results
if (all(abs(velocities_method1 - velocities_method2) < 1e-10)) {
  cat("3. Velocity Calculation (using both methods):\n")
  cat("   Both methods give identical results.\n\n")
  velocities <- velocities_method1
} else {
  cat("ERROR: Methods give different results!\n")
  stop("Velocity calculation methods do not match")
}

cat("   Using: vr = (fd * lambda) / 2\n")
cat("   or: vr = (fd * c) / (2 * f0)\n\n")

for (i in seq_along(doppler_shifts_kHz)) {
  sign <- ifelse(doppler_shifts_kHz[i] >= 0, "approaching", "receding")
  cat(sprintf("   Target %d: fd = %+7.1f kHz -> vr = %+8.3f m/s (%s)\n", 
              i, doppler_shifts_kHz[i], velocities[i], sign))
}
cat("\n")

# =============================================================================
# 5. CONVERT TO km/h FOR BETTER INTUITION
# =============================================================================
velocities_kmh <- velocities * 3.6  # 1 m/s = 3.6 km/h

cat("4. Velocities in km/h:\n")
for (i in seq_along(velocities_kmh)) {
  sign <- ifelse(doppler_shifts_kHz[i] >= 0, "approaching", "receding")
  cat(sprintf("   Target %d: fd = %+7.1f kHz -> vr = %+8.3f km/h (%s)\n", 
              i, doppler_shifts_kHz[i], velocities_kmh[i], sign))
}
cat("\n")

# =============================================================================
# 6. VISUALIZATION
# =============================================================================
# Create a bar plot showing the Doppler shifts and corresponding velocities

# Set up the plot
par(mar = c(5, 6, 4, 2) + 0.1)

# Create target labels
target_labels <- sprintf("Target %d", 1:length(doppler_shifts_kHz))
colors <- ifelse(doppler_shifts_kHz >= 0, "darkgreen", "darkred")

# Create a figure with two subplots
# First, check if we're in an environment that can display graphics
# Use interactive() and try to detect if we can create graphics
can_display <- tryCatch({
  interactive() || capabilities("cairo") || capabilities("quartz") || capabilities("X11")
}, error = function(e) FALSE)

if (can_display && interactive()) {
  # For interactive environments (RStudio, R GUI on macOS, etc.)
  
  # Create a new window or device
    if (!dir.exists("plots")) {
    dir.create("plots")
  }
  png(file.path("plots", "doppler_frequency_velocities.png"), width = 1000, height = 600)
  
  # Layout with two plots side by side
  layout(matrix(c(1, 2), nrow = 1, ncol = 2), widths = c(1, 1))
  
  # Plot 1: Doppler Frequency Shifts
  barplot(doppler_shifts_kHz, 
          names.arg = target_labels,
          col = colors,
          main = "Doppler Frequency Shifts",
          ylab = "Frequency [kHz]",
          xlab = "Target",
          ylim = c(min(doppler_shifts_kHz) - 2, max(doppler_shifts_kHz) + 2),
          cex.names = 0.9)
  abline(h = 0, col = "blue", lwd = 2, lty = 2)
  legend("topright", 
         legend = c("Approaching (positive)", "Receding (negative)"),
         fill = c("darkgreen", "darkred"),
         cex = 0.8)
  
  # Plot 2: Calculated Velocities
  barplot(velocities, 
          names.arg = target_labels,
          col = colors,
          main = "Radial Velocities",
          ylab = "Velocity [m/s]",
          xlab = "Target",
          ylim = c(min(velocities) - 2, max(velocities) + 2),
          cex.names = 0.9)
  abline(h = 0, col = "blue", lwd = 2, lty = 2)
  legend("topright",
         legend = c("Approaching (positive)", "Receding (negative)"),
         fill = c("darkgreen", "darkred"),
         cex = 0.8)
  
  # Reset layout
  layout(1)
  
  # If we opened a PDF device, close it
  if (!interactive()) {
    dev.off()
    cat("7. Visualization:\n")
    cat("   Plot saved to 'doppler_velocity_plot.pdf'\n")
  } else {
    cat("7. Visualization:\n")
    cat("   Interactive plot displayed.\n")
    cat("   Red bars: targets receding (moving away)\n")
    cat("   Green bars: targets approaching (moving toward radar)\n\n")
  }
  
  # Additional combined visualization
  par(mfrow = c(1, 2))
  
  # Scatter plot: Doppler shift vs Velocity
  plot(doppler_shifts_kHz, velocities, 
       type = "p", 
       col = colors, 
       pch = 19, 
       cex = 1.5,
       main = "Doppler Shift vs. Velocity",
       xlab = "Doppler Frequency [kHz]",
       ylab = "Radial Velocity [m/s]",
       xlim = c(min(doppler_shifts_kHz) - 1, max(doppler_shifts_kHz) + 1),
       ylim = c(min(velocities) - 2, max(velocities) + 2))
  abline(0, c/2/f0_Hz*1000, col = "blue", lwd = 2)  # Slope = c/(2*f0) * 1000 (for kHz to Hz conversion)
  abline(h = 0, v = 0, col = "gray", lty = 2)
  
  # Add linear relationship label
  m <- c / (2 * f0_Hz) * 1000  # Conversion factor from kHz to m/s
  legend("topleft", 
         legend = sprintf("vr = fd * c / (2*f0)\nSlope = %.4f m/s per kHz", m),
         bty = "n",
         cex = 0.8)
  
  # Add target labels
  for (i in seq_along(doppler_shifts_kHz)) {
    text(doppler_shifts_kHz[i], velocities[i], 
         labels = sprintf("T%d", i),
         pos = ifelse(doppler_shifts_kHz[i] > 0, 2, 4),
         offset = 0.5,
         cex = 0.8)
  }
  
  # Second subplot: Velocity in km/h for better intuition
  plot(doppler_shifts_kHz, velocities_kmh, 
       type = "p", 
       col = colors, 
       pch = 19, 
       cex = 1.5,
       main = "Doppler Shift vs. Velocity [km/h]",
       xlab = "Doppler Frequency [kHz]",
       ylab = "Radial Velocity [km/h]",
       xlim = c(min(doppler_shifts_kHz) - 1, max(doppler_shifts_kHz) + 1),
       ylim = c(min(velocities_kmh) - 5, max(velocities_kmh) + 5))
  abline(0, c/2/f0_Hz*1000*3.6, col = "blue", lwd = 2)
  abline(h = 0, v = 0, col = "gray", lty = 2)
  
  for (i in seq_along(doppler_shifts_kHz)) {
    text(doppler_shifts_kHz[i], velocities_kmh[i], 
         labels = sprintf("T%d", i),
         pos = ifelse(doppler_shifts_kHz[i] > 0, 2, 4),
         offset = 0.5,
         cex = 0.8)
  }
  
  par(mfrow = c(1, 1))
  
} else {
  # For non-interactive environments, print a description instead
  cat("7. Visualization:\n")
  cat("   Note: Running in non-interactive mode. Plot cannot be displayed.\n")
  cat("   The visualization would show:\n")
  cat("   - Bar plot of Doppler frequency shifts: positive values (green) for approaching targets,\n")
  cat("     negative values (red) for receding targets\n")
  cat("   - Bar plot of calculated velocities with the same color coding\n")
  cat("   - Scatter plot showing the linear relationship between Doppler shift and velocity\n")
  cat("   - The linear relationship: vr = (c / (2 * f0)) * fd\n")
  cat("     With c = 3e8 m/s and f0 = 77 GHz:\n")
  cat(sprintf("     vr = %.6f * fd [where fd is in Hz]\n", c / (2 * f0_Hz)))
  cat(sprintf("     vr = %.6f * fd [where fd is in kHz]\n\n", c / (2 * f0_Hz) * 1000))
  
  # Also save the plot to PNG for non-interactive mode
  cat("   Saving visualization to 'plots/' directory...\n")
  if (!dir.exists("plots")) {
    dir.create("plots")
  }
  png(file.path("plots", "doppler_velocity_plot.png"), width = 1200, height = 600)
  
  par(mfrow = c(1, 2))
  
  # Plot 1: Doppler Frequency Shifts
  barplot(doppler_shifts_kHz, 
          names.arg = target_labels,
          col = colors,
          main = "Doppler Frequency Shifts",
          ylab = "Frequency [kHz]",
          xlab = "Target",
          ylim = c(min(doppler_shifts_kHz) - 2, max(doppler_shifts_kHz) + 2),
          cex.names = 0.9)
  abline(h = 0, col = "blue", lwd = 2, lty = 2)
  legend("topright", 
         legend = c("Approaching (positive)", "Receding (negative)"),
         fill = c("darkgreen", "darkred"),
         cex = 0.8)
  
  # Plot 2: Calculated Velocities
  barplot(velocities, 
          names.arg = target_labels,
          col = colors,
          main = "Radial Velocities",
          ylab = "Velocity [m/s]",
          xlab = "Target",
          ylim = c(min(velocities) - 2, max(velocities) + 2),
          cex.names = 0.9)
  abline(h = 0, col = "blue", lwd = 2, lty = 2)
  legend("topright",
         legend = c("Approaching (positive)", "Receding (negative)"),
         fill = c("darkgreen", "darkred"),
         cex = 0.8)
  
  par(mfrow = c(1, 1))
  dev.off()
  cat("   Plot saved successfully.\n\n")
}

# =============================================================================
# 7. THEORETICAL VERIFICATION
# =============================================================================
# Verify the calculation with an example
# For a target moving at 100 m/s toward the radar at 77 GHz:
# fd = 2 * vr / lambda = 2 * 100 * 77e9 / 3e8 = 2 * 100 * 77 / 300 * 1000 = ...

cat("8. Theoretical Verification:\n")
test_velocity <- 100  # m/s (typical car speed: ~360 km/h)
expected_fd <- (2 * test_velocity * f0_Hz) / c
cat(sprintf("   For a target at %.1f m/s (%.1f km/h):\n", test_velocity, test_velocity * 3.6))
cat(sprintf("   Expected Doppler shift: %.2f Hz = %.2f kHz\n", expected_fd, expected_fd / 1000))

# Verify with our calculation
calculated_velocity <- (expected_fd * c) / (2 * f0_Hz)
cat(sprintf("   Calculated velocity from fd: %.2f m/s\n", calculated_velocity))
cat(sprintf("   Difference: %.6f m/s (should be ~0)\n\n", abs(test_velocity - calculated_velocity)))

# =============================================================================
# 8. SUMMARY
# =============================================================================
cat("=== Summary ===\n")
cat("This demonstration shows how radar systems use the Doppler effect to measure\n")
cat("target velocity from frequency shifts.\n\n")
cat("Key insights:\n")
cat(sprintf("  - Radar wavelength at 77 GHz: %.3f mm\n", lambda * 1000))
cat(sprintf("  - Velocity per kHz of Doppler shift: %.4f m/s\n", c / (2 * f0_Hz) * 1000))
cat(sprintf("  - Or: %.4f km/h per kHz\n", c / (2 * f0_Hz) * 1000 * 3.6))
cat("\n")
cat("The Doppler effect provides a direct and linear relationship between the observed\n")
cat("frequency shift and the target's radial velocity. The sign of the shift indicates\n")
cat("direction (approaching or receding), and the magnitude indicates speed.\n\n")

cat("Results for the four targets:\n")
for (i in seq_along(doppler_shifts_kHz)) {
  direction <- ifelse(doppler_shifts_kHz[i] > 0, "Approaching", 
                      ifelse(doppler_shifts_kHz[i] < 0, "Receding", "Stationary"))
  cat(sprintf("  Target %d: fd = %+6.1f kHz -> vr = %+7.3f m/s (%+7.3f km/h) [%s]\n",
              i, doppler_shifts_kHz[i], velocities[i], velocities_kmh[i], direction))
}
cat("\n")

# =============================================================================
# 9. PRACTICAL CONTEXT
# =============================================================================
cat("Practical Context:\n")
cat("In automotive radar systems (e.g., for self-driving cars):\n")
cat("  - 77 GHz is a common frequency (wavelength ~3.9 mm)\n")
cat("  - Typical vehicle speeds: 10-40 m/s (36-144 km/h)\n")
cat("  - Corresponding Doppler shifts: 4.8-19.3 kHz for approaching vehicles\n")
cat("  - Negative shifts for vehicles moving away\n")
cat("\n")
cat("This linear relationship makes Doppler radar ideal for velocity measurement\n")
cat("in applications like adaptive cruise control, collision avoidance, and traffic\n")
cat("speed monitoring.\n")

# =============================================================================
# REUSABLE FUNCTIONS
# =============================================================================
#' Calculate wavelength from frequency
#'
#' @param f0 Frequency in Hz
#' @param c Speed of light in m/s (default: 3e8)
#' @return Wavelength in meters
calc_wavelength <- function(f0, c = 3e8) {
  c / f0
}

#' Calculate radial velocity from Doppler shift
#'
#' @param fd Doppler frequency shift in Hz
#' @param f0 Radar operating frequency in Hz
#' @param c Speed of light in m/s (default: 3e8)
#' @return Radial velocity in m/s
calc_velocity_doppler <- function(fd, f0, c = 3e8) {
  (fd * c) / (2 * f0)
}

#' Calculate radial velocity from Doppler shift using wavelength
#'
#' @param fd Doppler frequency shift in Hz
#' @param lambda Wavelength in meters
#' @return Radial velocity in m/s
calc_velocity_doppler_lambda <- function(fd, lambda) {
  (fd * lambda) / 2
}

#' Convert m/s to km/h
#'
#' @param velocity_mps Velocity in meters per second
#' @return Velocity in kilometers per hour
convert_mps_to_kmh <- function(velocity_mps) {
  velocity_mps * 3.6
}
