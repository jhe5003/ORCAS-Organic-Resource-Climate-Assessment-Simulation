# compost function.
# Functions
#   compostTreatmentPathway(Feedstock, GlobalFactors, debug = F)
#       returns data.frame of factor vs. outputs, labeled with row and col names
#
################# Treatment Functions
compostTreatmentPathway <- function(Feedstock, GlobalFactors, debug = F)
{
  Compost_dieseLlpert<-3
  #Boldrin,2009
  CompostPercentCdegraded<-0.58
  #Boldrin,2009
  Compost_degradedC_CH4<-0.02
  #Boldrin,2009
  Compost_N2OperN<-0.015
  Compost_storage_factor<-0.00
# Additional decay beyond AD degradation tests due to organisms and fungi
  Compost_mass_reduction=0.4
  Compost_spread_diesellpert<-0.4
  Compost_N_remaining<-0.4
  Compost_NAvailabiltiy_Factor<-0.4
  xportToField<-60
  Peatdisplacementfactor<-1
  EF_Peat_kgCO2eperton<--970
# Hauling of the waste to the compost facility not included at this time
# step 1: Compost operation
  EMCompostoperation<-Compost_dieseLlpert*
    (GlobalFactors$DieselprovisionkgCO2eperL+GlobalFactors$DieselcombustionkgCO2eperL)
  if(debug) {print(paste("EMCompostoperation", (EMCompostoperation)))}
  
# step 2: Biological emissions
   EMCompost_CH4<-CompostPercentCdegraded*Compost_degradedC_CH4*Feedstock$InitialC*
     GlobalFactors$CtoCH4*GlobalFactors$GWPCH4
   EMCompost_N2O=Feedstock$Nperton*Compost_N2OperN*GlobalFactors$N20N_to_N20*
     GlobalFactors$GWPN20
   if(debug) {print(paste("EMCompost_CH4", (EMCompost_CH4),"EMCompost_N2O",(EMCompost_N2O)))}
   
  
#Step 3 Carbon storage
    CStorage<-Feedstock$InitialC*(1-(Feedstock$fdeg+Compost_storage_factor))
    #Assuming that the same amount is stored long term as AD degradability test
    if(debug) {print(paste("CStorage", (CStorage)))}
    EMCstorage<-CStorage*-44/12
    if(debug) {print(paste("EMCstorage", (EMCstorage)))}
    
#Step 4 Compost application
    Compost_mass<- 1000*Compost_mass_reduction
    EMspread           <- 1.5 * xportToField/20
    if(debug) print(paste("EMspread ",EMspread))
    Nremaining<-Feedstock$Nperton*Compost_N_remaining
    EMN20_LandApp_direct         <- Nremaining * GlobalFactors$LandApplication_EF1 *
      GlobalFactors$N20N_to_N20 * GlobalFactors$GWPN20 / 1000
    if(debug) print(paste("EMN20_LandApp_direct ",EMN20_LandApp_direct))
    EMN20_LandApp_indirect       <- Nremaining * GlobalFactors$LandApplication_FracGasM * 
      GlobalFactors$IPCC_EF4 * GlobalFactors$N20N_to_N20 * GlobalFactors$GWPN20 / 1000
    if(debug) print(paste("EMN20_LandApp_indirect ",EMN20_LandApp_indirect))
    EMN20_LandApp    <- EMN20_LandApp_direct + EMN20_LandApp_indirect
    if(debug) print(paste("EMN20_LandApp ",EMN20_LandApp))
    EMLandApp <- EMspread + EMN20_LandApp
    if(debug) print(paste("EMLandApp ",EMLandApp))
    
    # Step 4: Displaced fertilizer kgCO2e/MT
    Nremaining      <- Nremaining - 
      Nremaining * GlobalFactors$LandApplication_EF1 -
      Nremaining * 0.2
    effectiveNapplied <- Nremaining * 
      Compost_NAvailabiltiy_Factor
    avoidedNfert    <- GlobalFactors$LA_DisplacedFertilizer_Production_Factor *
      effectiveNapplied/1000
    avoidedInorganicFertdirectandIndirect <- GlobalFactors$LA_DisplacedFertilizer_Direct_Indirect *
      effectiveNapplied/1000
    EM_displacedFertilizer <- avoidedNfert + avoidedInorganicFertdirectandIndirect
    if(debug) print(paste("displacedFertilizer ",EM_displacedFertilizer))
    
    # Step 5: Displaced peat kgCO2e/Mt
   EM_displaced_Peat<-Peatdisplacementfactor*Compost_mass*EF_Peat_kgCO2eperton
    
}
    
