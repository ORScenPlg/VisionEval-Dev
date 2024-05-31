# List models available

openModel()

# VE-State-base --------------------------------------------------------------
m = openModel("VE-State-base")
m$run()  #  Successful in 127 minutes


# VE-State-odot-STS ---------------------------------------------------------
# TODO: Fix VETravelDemand module needed in run script
# Should we use VETravelDemandMM or VETravelDemandWFH?
m2 = openModel("VE-State-odot-STS")
m2$run()  


# VE-State-odot-wfh-sld-dl -------------------------------------------------
m3 = openModel("VE-State-odot-wfh-sld-dl")
m3$run("save")  # Successful in ~180 minutes


# VE-State-odotmm-AP22 ------------------------------------------------------
# TODO: Aditya can advise 
# Check for recent push by Aditya in ODOT branch that may have fixed the error?
# Maybe something in the car service
# May need to pull in a commit from somewhere else
m4 = openModel("VE-State-odotmm-AP22")
m4$run()  # Errored after 38 minutes in Error in names(HhUrbanRoadDvmt_Ma) <- Ma : 
  # 'names' attribute [9] must be the same length as the vector [0]


# VE-State-odotmm-AP22-wfh -------------------------------------------------
# TODO: Fix by specifying model years 2010, 2050
m5 = openModel("VE-State-odotmm-AP22-wfh")
m5$run()  


# VE-State-odotmm-dl --------------------------------------------------------
m6 = openModel("VE-State-odotmm-dl")
m6$run()  # Successful in 156 minutes (many warnings)


# VE-State-odotWFH-STS ------------------------------------------------------
m7 = openModel("VE-State-odotWFH-STS")
m7$run() 
