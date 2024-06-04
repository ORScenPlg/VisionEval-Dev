
# Prerequisites 
# - Create a parent folder to hold the VisionEval repository, runtime, and build directories
# - Check out VisionEval-Dev as a sub-folder of the parent folder
# - Check out ODOT_VE_Extras in the same parent folder
# - Create a directory to hold the VisionEval runtime (output)
# - Create a directory to hold the VisionEval build

# The parent directory should have four sub-folders:
# VisionEval-Dev, ODOT_VE_Extras, VE_Builds, VE_Models

# Create a .Renviron file in the VisionEval-Dev folder with the following contents:
# VE_HOME is the path of VisionEval-Dev
# VE_BUILD is the path of VE_Builds
# VE_RUNTIME is the path of VE_Models

# NOTE: Be sure to *RESTART R* after setting up .Renviron
# It isn't enough to run readRenviron() or Sys.setenv() because
# VisionEval needs to do additional setup when .Rprofile is loaded. 

# Install some packages for VSCode
# git2r required for ve.build(use.git=TRUE)
install.packages(
    c("languageserver", "jsonlite", "git2r") 
)

# Check that VE_BUILD and VE_RUNTIME exist, create them if not
dir.create(Sys.getenv("VE_BUILD"), showWarnings = FALSE)
dir.create(Sys.getenv("VE_RUNTIME"), showWarnings = FALSE)

ve.build(use.git=TRUE)

# This is an example of what the .Renviron file should look like after ve.build
# 
# R_LIBS_USER=E:/odot-ve-state-qc/VE_Builds/built/ve-state-qc/%V/ve-lib;E:/odot-ve-state-qc/VE_Builds/dev/lib/%V
# VE_HOME=E:/odot-ve-state-qc/VisionEval-Dev
# VE_RUNTIME=E:/odot-ve-state-qc/VE_Models
# VE_BUILD=E:/odot-ve-state-qc/VE_Builds


# Install the VEStateVariants models ------------------------------------------

# copy .Renviron to VE_BUILD and VE_RUNTIME so it doesn't matter where R is launched
file.copy(
    file.path(Sys.getenv("VE_HOME"), ".Renviron"),
    Sys.getenv("VE_BUILD")
)

file.copy(
    file.path(Sys.getenv("VE_HOME"), ".Renviron"),
    Sys.getenv("VE_RUNTIME")
)

stop("Restart R here so VisionEval recognizes R_LIBS_USER")


# Install ODOT_VE_Extras =======================================================

# Check that we are installing in the right place
.libPaths()[1]

libs = Sys.getenv("R_LIBS_USER")  # Should be the same place used by ve.build
lib = strsplit(libs, ";")[[1]][1]
stopifnot(file.exists(lib), lib == .libPaths()[1]) # Restart R if fails

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

# Tell git to ignore changes due to the package installation
# Local setting only - will not affect the repository
# Get the list of .rda files
rda_files = Sys.glob("*/data/*.rda")
md_files = Sys.glob("*/inst/module_docs/*.md")
png_files = Sys.glob("*/inst/module_docs/*.png")
files = c(rda_files, md_files, png_files)

# Loop over each file and run the git command
for (file in files) {
  system(paste("git update-index --assume-unchanged", file))
}

# Some packages are dependent on others, so install those second
mod_pkgs2 = c("VELandUseDLSKATS")

# Add a missing dependency
install.packages("sn", lib=lib)

message("Installing ", length(mod_pkgs), " new modules")
install.packages(
  setdiff(mod_pkgs, mod_pkgs2), 
  lib = lib, 
  repos = NULL, 
  type = "source"
)

install.packages(mod_pkgs2, lib = lib, repos = NULL, type = "source")

setwd(owd)
message("Working directory reset to: ", getwd())


# Install model variants =======================================================

setwd(Sys.getenv("VE_RUNTIME"))

# Show available models
installModel()

# Install base as a test
# installModel('VE-State', variant='base', confirm=FALSE)

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

# List installed models
openModel()
dir("models")

# Build the documents
# ve.build('docs') # Can't get this to work. (or else it is just very slow)

message("Setup complete.")

# Run model variants ==========================================================

# List models available

openModel()


# To reinstall a variant -------------------------------------------------------

reinstall = FALSE

if (reinstall) {

  variant = 'odotmm-AP22-wfh'
  # Set the location of ODOT_VE_Extras
  # Assuming it is in the same directory as VisionEval-Dev

  odot_ve_extras_dir = Sys.getenv("VE_HOME") |> 
    dirname() |>
    file.path("ODOT_VE_Extras")
  stopifnot(dir.exists(odot_ve_extras_dir))

  # Reinstall the VEStateVariants package
  lib = .libPaths()[1]
  
  setwd(odot_ve_extras_dir)
  remove.packages("VEStateVariants", lib=lib)
  setwd(odot_ve_extras_dir)
  install.packages("VEStateVariants", lib=lib, repos=NULL, type="source")
  
  setwd(Sys.getenv("VE_RUNTIME"))

  # Reinstall the model
  var_dir = file.path(
    Sys.getenv("VE_RUNTIME"), 
    "models", 
    paste0("VE-State-", variant)
  )
  unlink(var_dir, recursive=TRUE)
  installModel('VE-State', variant=variant, confirm=FALSE)

}


# VE-State-odot-STS ---------------------------------------------------------
m2 = openModel("VE-State-odot-STS")
m2$run()  


# VE-State-odot-wfh-sld-dl -------------------------------------------------
m3 = openModel("VE-State-odot-wfh-sld-dl")
m3$run("save")


# VE-State-odotmm-AP22 ------------------------------------------------------
m4 = openModel("VE-State-odotmm-AP22")
m4$run()  


# VE-State-odotmm-AP22-wfh -------------------------------------------------
m5 = openModel("VE-State-odotmm-AP22-wfh")
m5$run()  


# VE-State-odotmm-dl --------------------------------------------------------
m6 = openModel("VE-State-odotmm-dl")
m6$run()  


# VE-State-odotWFH-STS ------------------------------------------------------
m7 = openModel("VE-State-odotWFH-STS")
m7$run() 
