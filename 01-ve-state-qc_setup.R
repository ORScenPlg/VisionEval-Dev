
# Prerequisites - set up .Renviron with VE_HOME, VE_RUNTIME, VE_BUILD
# NOTE: Be sure to RESTART R after setting up .Renviron

# VE_HOME is the location of the VisionEval repository
# VE_RUNTIME is the location where VisionEval will run
# VE_BUILD is the location where VisionEval will be built

# This is what .Renviron looks like on azmdlppw05
# R_LIBS_USER=E:/odot-ve-state-qc/VE_Builds/built/ve-state-qc/%V/ve-lib;E:/odot-ve-state-qc/VE_Builds/dev/lib/%V
# VE_HOME=E:/odot-ve-state-qc/VisionEval-Dev
# VE_RUNTIME=E:/odot-ve-state-qc/VE_Models
# VE_BUILD=E:/odot-ve-state-qc/VE_Builds


# Install some packages for VSCode
install.packages(
    c("languageserver", "jsonlite", "git2r") # git2r required for ve.build(use.git=TRUE)
)

# Check that VE_BUILD and VE_RUNTIME exist, create them if not
dir.create(Sys.getenv("VE_BUILD"), showWarnings = FALSE)
dir.create(Sys.getenv("VE_RUNTIME"), showWarnings = FALSE)

# copy .Renviron to VE_BUILD and VE_RUNTIME
file.copy(
    file.path(Sys.getenv("VE_HOME"), ".Renviron"),
    Sys.getenv("VE_BUILD")
)

file.copy(
    file.path(Sys.getenv("VE_HOME"), ".Renviron"),
    Sys.getenv("VE_RUNTIME")
)

ve.build(use.git=TRUE)


# Install ODOT_VE_Extras -------------------------------------------------------

# Check that we are installing in the right place
.libPaths()[1]

libs = Sys.getenv("R_LIBS_USER")  # Should be the same place used by ve.build
lib = strsplit(libs, ";")[[1]][1]
stopifnot(file.exists(lib), lib == .libPaths()[1])

# Add a dependency missing
install.packages("sn", lib=lib)

# Set the location of ODOT_VE_Extras
odot_ve_extras_dir = Sys.getenv("VE_HOME") |> 
  dirname() |>
  file.path("ODOT_VE_Extras")
stopifnot(dir.exists(odot_ve_extras_dir))

owd = getwd()
setwd(odot_ve_extras_dir)
mod_pkgs = Sys.glob("VE*")
message(
  'Module packages to install:\n\t',
  paste(mod_pkgs, collapse = '\n\t')
)

# Some packages are dependent on others, so install those second
mod_pkgs2 = c("VELandUseDLSKATS")

message("Installing ", length(mod_pkgs), " new modules")
install.packages(
  setdiff(mod_pkgs, mod_pkgs2), 
  lib = lib, 
  repos = NULL, 
  type = "source"
)

install.packages(mod_pkgs2, lib = lib, repos = NULL, type = "source")

setwd(owd)


# Install the VEStateVariants models ------------------------------------------

# Show available models
installModel()

# Install base as a test
installModel('VE-State', variant='base', confirm=FALSE)

# Install all the variants in package "VEStateVariants"
# Show available variants for one of the models
variant_df = installModel('VE-State', variant='')
variant_df

install_variants = variant_df$Variant[variant_df$Package == 'VEStateVariants']

for (variant in install_variants) {
  message("Installing variant: ", variant)
  tryCatch({
    installModel('VE-State', variant=variant, confirm=FALSE)
  }, error = function(e) {
    message(
      "Error in installing variant: ", 
      variant,
      "/n Error message: ",
      e$message
    )
  })
}

# If variant fails to install (e.g. odot-STS), fix problems then
# setwd(odot_ve_extras_dir)
# remove.packages("VEStateVariants", lib=lib)
# install.packages("VEStateVariants", lib=lib, repos=NULL, type="source")
# setwd(owd)
# installModel('VE-State', variant='odot-STS', confirm=FALSE)

# List installed models
openModel()
dir("models")

# Build the documents
# ve.build('docs') # Can't get this to work.

message("Setup complete.")
