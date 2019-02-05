#!/bin/bash
# Simple script to automatically add printers from the print server
# Created on: Jan 4th, 2019
# By: Gary Lee

# use AUTH=negotiate for kerberos
# AUTH=negotiate
# default to AUTH=none so the user is prompted for creds
AUTH='negotiate'
PPDPATH="/Library/Printers/PPDs/Contents/Resources"
TESTPRINT="/usr/share/cups/data/testprint"
KEYCHAIN='/library/keychains/'
ERRORLOG='/private/var/log/cups/error_log'

irt=("AD_IRT_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD")
first=("1st_Floor_Mail_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD" "-o Option17=DF730 Option21=True Option19=Third")
second=("2nd_Floor_Copy_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD" "-o Option17=DF730 Option21=True Option19=False") # Good
third=("3rd_Floor_Accounting_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD" "-o Option17=DF730 Option21=True Option19=False")
executive=("3rd_Floor_Exec_Copier_6551ci" "$PPDPATH/Kyocera TASKalfa 6551ci.PPD" "-o Option17=DF770 Option21=True" )
ehs=("AD_EHS_Copier_M3550idn" "$PPDPATH/Kyocera ECOSYS M3550idn.PPD")
facilities=("AD_Facilities_3015dn" "$PPDPATH/hp LaserJet 3015.gz" "-o InputSlot=Tray2")
osr=("AD_OSR_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD")
purchasing=("AD_Purchasing_M3550idn" "$PPDPATH/Kyocera ECOSYS M3550idn.PPD")
tech_dev=("AD_TechDev_P3015dn" "$PPDPATH/hp LaserJet 3015.gz")
cb_altman=("CB_Altman_4050tn" "$PPDPATH/HP LaserJet 4050 Series.gz")
cb_liu=("CB_Liu_CP3525" "$PPDPATH/HP Color LaserJet CP3525.gz")
cb_sharma=("CB_Sharma_FS-4200DN" "$PPDPATH/Kyocera FS-4200DN.ppd")
di_kronenberg=("DI_Kronenberg_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD")
di_linden=("DI_Linden_CP2025dn" "$PPDPATH/HP Color LaserJet CP2020 Series.gz")
di_schoenberger=("DI_Schoenberger_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD")
di_vonherrath=("DI_VonHerrath_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD")
flow=("Flow_Office_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD")
ib_hedrick=("IB_Hedrick_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD")
ir_croft=("IR_Croft_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD")
ir_newmeyer=("IR_Newmeyer_m551dn" "$PPDPATH/HP LaserJet 500 color M551.gz")
rnai=("RNAi_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD")
sge_rao=("SGE_Rao_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD")
vd_crotty=("VD_Crotty_M451dn" "$PPDPATH/HP LJ 300-400 color M351-M451.gz")
vd_sette=("VD_Sette_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD")
vd_shresta=("VD_Shresta_3700dtn")
vivarium=("AD_Vivarium_M3550idn" "$PPDPATH/Kyocera ECOSYS M3550idn.ppd")
#addPrinter "DI_Private_Miller_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD" # Good
#addPrinter "DI_Schoenberger_M553dn" "$PPDPATH/HP Color LaserJet M553.gz" # Good
#addPrinter "VD_Sette_P3015" "$PPDPATH/HP Color LaserJet 3000.gz"
#addPrinter "VD_Sette_Private_April_FS-4200DN" "$PPDPATH/Kyocera FS-4200DN.ppd"


# Assigns the array elements to variables
printerName=${1}[0]
ppdFile=${1}[1]
printOptions=${1}[2]

list(){
  echo PRINTER GROUPS
  printf "first\nsecond\nthird\nehs\nfacilities\nosr\npurchasing\ntech_dev\ncb_altman\ncb_liu\ncb_sharma\ndi_kronenberg\ndi_linden\ndi_schoenberger\ndi_vonherrath\nflow\nib_hedrick\nir_croft\nir_newmeyer\nrnai\nsge_rao\nvd_crotty\nvd_sette\nvd_shresta\nvivarium"
}

addPrinter(){
  printerName=${1}
  ppdFile=${2}
  printerOptions=${3}
  # If only 2 arguments are supplied don't include printer options
  if [[ "$#" -eq 2 ]]; then
    echo adding ${printerName}
    echo ppdFile ${ppdFile}
    echo printerOptions ${printerOptions}

    lpadmin \
       -p ${printerName} \
       -v "smb://print/$printerName" \
       -P "${ppdFile}" \
       -E \
       -o printer-is-shared=false \
       -o auth-info-required=${AUTH} \

    cupsdisable
    cupsenable ${printerName} -E
    cupsaccept ${printerName}
    # sends test print page
    lp -d ${printerName} -o media="letter" ${TESTPRINT}
    sudo killall -HUP cupsd
    #checkError

  # If 3 arguments are supplied, include the 3rd as printer options
  elif [[ "$#" -eq 3 ]]; then
    echo adding ${printerName}

    lpadmin \
       -p ${printerName} \
       -v "smb://print/${printerName}" \
       -P "${ppdFile}" \
       -E \
       -o printer-is-shared=false \
       -o auth-info-required=${AUTH} \
       ${printerOptions}

    cupsdisable
    cupsenable ${printerName} -E
    cupsaccept ${printerName}
    sudo killall -HUP cupsd
    # sends test print page
    lp -d ${printerName} -o media="letter" ${TESTPRINT}
    #checkError
  fi
}

# This function will display the print options available to each printer.
ppdSettings(){
  printerName=${1}
  lpoptions \
      -p ${printerName} \
      -l
}

checkError(){
  grep 'Authentication' ${ERRORLOG} | check=$?
  if [[ ${check} -eq 0 ]]; then
    echo There is an Authentication Error...Attempting to resolve.
    echo Clearing AD_IRT_P6035cdn queue
    cancel -a "AD_IRT_P6035cdn"
    # if keychain found then delete keychain
    security find-internet-password -l 'print'
    security delete-internet-password -l 'print'
  elif [[ "${check} -eq 1" ]]; then
    echo No Error found....
  else
    echo Error Occured.
  fi
}


############################################################
if [[ ${1} = "list" ]]; then
  list
elif [[ "$#" -eq 1 ]]; then
  if [[ -z "${!options}" ]]; then
    addPrinter "${!printerName}" "${!ppdFile}"
  else
    addPrinter "${!printerName}" "${!ppdFile}" "${!printOptions}"
  fi
elif [[ "$#" -eq 2 && ${2} = "options" ]]; then
  ppdSettings "${!printerName}"

fi
