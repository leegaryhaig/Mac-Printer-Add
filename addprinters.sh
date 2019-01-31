#!/bin/bash
# Simple script to automatically add printers from the print server
# to a mac.
# Created on: Feb 13, 2015
# By: Michael Talbott
# Edited on: Jan 4th, 2019
# By: Gary Lee

# Shell should only have these Functions:
# 1. Add PRINTER
# 2. Check Printer options
# 3. Check For errors
# 4. Try to Resolve errors
# 5. Print Test Page
# 6. Show list of printers

# Global Variables that maintains its existence throughout the program:
# 1. PPD path
# 2. testprint path
# 3. Keychain
# 4. Errorlog path
# 5. Printer Lists

# use AUTH=negotiate for kerberos
# AUTH=negotiate
# default to AUTH=none so the user is prompted for creds
AUTH=none
PPDPATH="/Library/Printers/PPDs/Contents/Resources/"
TESTPRINT="/usr/share/cups/data/testprint"
KEYCHAIN='/library/keychains/'
ERRORLOG='/private/var/log/cups/error_log'

# Array length: echo "${#ArrayName[@]}"
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


list(){
  echo PRINTER GROUPS
  printf "first\nsecond\nthird\nehs\nfacilities\nosr\npurchasing\ntech_dev\ncb_altman\ncb_liu\ncb_sharma\ndi_kronenberg\ndi_linden\ndi_schoenberger\ndi_vonherrath\nflow\nib_hedrick\nir_croft\nir_newmeyer\nrnai\nsge_rao\nvd_crotty\nvd_sette\nvd_shresta\nvivarium"
}

testPrint(){
  lp -d "$1" -o media="letter" $TESTPRINT
}

# This function will display the print options available to each printer.
printerOptions(){
  PRINTER="$1"
  PPD="$2"
  lpoptions \
      -p "$1" \
      -l
}

checkError(){
  grep 'Authentication' $ERRORLOG | check=$?
  if [[ "$check" -eq 0 ]]; then
    echo There is an Authentication Error...Attempting to resolve.
    echo Clearing AD_IRT_P6035cdn queue
    cancel -a "AD_IRT_P6035cdn"
    security find-internet-password -l 'print'
    #security delete-internet-password -l 'print'

  elif [[ "$check -eq 1" ]]; then
    echo No Error found....
  else
    echo Error Occured.

  fi
}


addPrinter(){
  PRINTER="$1"
  PPD="$2"

  echo "$#"
  # If only 2 arguments are supplied don't include printer options
  if [[ "$#" -eq 2 ]]; then
    echo adding "$1"

    lpadmin \
       -p "$1" \
       -v "smb://print/$PRINTER" \
       -P "$2" \
       -E \
       -o printer-is-shared=false \
       -o auth-info-required="$AUTH" \

    cupsdisable
    cupsenable "$1" -E
    cupsaccept "$1"

    testPrint

    sudo killall -HUP cupsd

    checkError


  # If 3 arguments are supplied, include the 3rd as printer options
  elif [[ "$#" -eq 3 ]]; then
    echo adding "$1"

    lpadmin \
       -p "$1" \
       -v "smb://print/$PRINTER" \
       -P "$2" \
       -E \
       -o printer-is-shared=false \
       -o auth-info-required="$AUTH" \
       "$3"

    cupsdisable
    cupsenable "$1" -E
    cupsaccept "$1"

    sudo killall -HUP cupsd

    testPrint

    checkError

  fi
}


##################
if [[ "$1" = "list" ]]; then
    list
elif [[ "$#" -eq 1 ]]; then
    printerGroup=${1}[@]
    echo ${!printerGroup}

fi

