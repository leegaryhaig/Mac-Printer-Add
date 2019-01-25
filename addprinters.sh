#!/bin/bash
# Simple script to automatically add printers from the print server
# to a mac.
# Created on: Feb 13, 2015
# By: Michael Talbott
# Edited on: Jan 4th, 2019
# By: Gary Lee

# Still needs printers pointed to proper ppd files to finish script.

# get a list of printers from the print server like so (if you gots the tool installed):
# smbclient -U mtalbott -W LIAI_AD -L PRINT

PPDPATH="/Library/Printers/PPDs/Contents/Resources/"
TESTPRINT="/usr/share/cups/data/testprint"
KEYCHAIN='/library/keychains/'


# use AUTH=negotiate for kerberos
# AUTH=negotiate

# default to AUTH=none so the user is prompted for creds
AUTH=none


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

    lp -d "$1" -o media="letter" $TESTPRINT

    sudo killall -HUP cupsd


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

    lp -d "$1" -o media="letter" $TESTPRINT


  fi
}

# Error Log Location /private/var/log/cups/error_log.txt

# Delete specific printer q
#lprm "[printername]"

# KEYCHAIN
#security find-internet-password -l 'print'
#securiy delete-internet-password -l 'print'


"""if error log contains 'authentication required'
then clear the 'print' keychain, '[computer_name]' keychain if it exists
clear the error_log, print q and rerun addPrinter()'"""


 printerOptions(){
     PRINTER="$1"
     PPD="$2"

     lpoptions \
         -p "$1" \
         -l
 }

list(){
  echo PRINTER GROUPS
  printf "first\nsecond\nthird\naccounting\nehs\nfacilities\nosr\npurchasing\ntech_dev\ncb_altman\ncb_liu\ncb_sharma\ndi_kronenberg\ndi_linden\ndi_schoenberger\ndi_vonherrath\nflow\nib_hedrick\nir_croft\nir_newmeyer\nrnai\nsge_rao\nvd_crotty\nvd_sette\nvd_shresta\nvivarium"
}


irt(){
  # Here's the example. Call addPrinter and use the printername as 1st argument and PPD file as second.
  # Use the $PPDPATH variable as a shortcut to mac os's standard path for ppd files
  # Third argument is optional for printer specific options like duplexer options, etc.
  #printerOptions "AD_IRT_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD"
  addPrinter "AD_IRT_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD" # Good
}


first(){
  addPrinter "1st_Floor_Mail_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD" "-o Option17=DF730 Option21=True Option19=False" # Good
  #printerOptions "1st_Floor_Mail_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD"
}


second(){
  addPrinter "2nd_Floor_Copy_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD" "-o Option17=DF730 Option21=True Option19=False" # Good
}


third(){
  addPrinter "3rd_Floor_Accounting_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD" "-o Option17=DF730 Option21=True Option19=False" # Good
  addPrinter "3rd_Floor_Exec_Copier_6551ci" "$PPDPATH/Kyocera TASKalfa 6551ci.PPD" "-o Option17=DF770 Option21=True" # Good
}


accounting(){
  addPrinter "3rd_Floor_Accounting_6052ci" "$PPDPATH/Kyocera TASKalfa 6052ci.PPD" "-o Option17=DF730 Option21=True" # Good
  addPrinter "3rd_Floor_Exec_Copier_6551ci" "$PPDPATH/Kyocera TASKalfa 6551ci.PPD" "-o Option17=DF770 Option21=True" # Good
}


ehs(){
  addPrinter "AD_EHS_Copier_M3550idn" "$PPDPATH/Kyocera ECOSYS M3550idn.PPD" # Good
}


facilities(){
  printerOptions "AD_Facilities_3015dn" "$PPDPATH/hp LaserJet 3015.gz"
  addPrinter "AD_Facilities_3015dn" "$PPDPATH/hp LaserJet 3015.gz" "-o InputSlot=Tray2"
}


osr(){
  addPrinter "AD_OSR_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD" # Good
}


purchasing(){
  addPrinter "AD_Purchasing_M3550idn" "$PPDPATH/Kyocera ECOSYS M3550idn.PPD" # Good
}


tech_dev(){
  addPrinter "AD_TechDev_P3015dn" "$PPDPATH/hp LaserJet 3015.gz" # Good
}


cb_altman(){
  addPrinter "CB_Altman_4050tn" "$PPDPATH/HP LaserJet 4050 Series.gz" # Good
  addPrinter "CB_Altman_Private_M451" "$PPDPATH/HP LJ 300-400 color M351-M451.gz" # Idle
}


cb_liu(){
  addPrinter "CB_Liu_CP3525" "$PPDPATH/HP Color LaserJet CP3525.gz" # Idle
}


cb_sharma(){
  addPrinter "CB_Sharma_FS-4200DN" "$PPDPATH/Kyocera FS-4200DN.ppd" # Good
  addPrinter "CB_Sharma_Phaser_6500" "$PPDPATH/RICOH Aficio MP 6500.gz" # Idle
}


di_kronenberg(){
  addPrinter "DI_Kronenberg_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD" # Good
}


di_linden(){
  addPrinter "DI_Linden_CP2025dn" "$PPDPATH/HP Color LaserJet CP2020 Series.gz" # Error State
}


di_schoenberger(){
  addPrinter "DI_Private_Miller_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD" # Good
  addPrinter "DI_Schoenberger_M553dn" "$PPDPATH/HP Color LaserJet M553.gz" # Good
  addPrinter "DI_Schoenberger_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD" # Good
}

di_vonherrath(){
  addPrinter "DI_VonHerrath_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD" # Good
}


flow(){
  addPrinter "Flow_Office_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD" # Good
}

ib_hedrick(){
  addPrinter "IB_Hedrick_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD" # Good
}

ir_croft(){
  addPrinter "IR_Croft_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD" # Good
}

ir_newmeyer(){
  addPrinter "IR_Newmeyer_m551dn" "$PPDPATH/HP LaserJet 500 color M551.gz" # Good
}


rnai(){
  addPrinter "RNAi_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD" # Good
}

sge_rao(){
  addPrinter "SGE_Rao_P6035cdn" "$PPDPATH/Kyocera ECOSYS P6035cdn.PPD" # Good
}

vd_crotty(){
  addPrinter "VD_Crotty_M451dn" "$PPDPATH/HP LJ 300-400 color M351-M451.gz" # Good
}

vd_sette(){
  #addPrinter "VD_Sette_P3015" "$PPDPATH/HP Color LaserJet 3000.gz"
  addPrinter "VD_Sette_P6130cdn" "$PPDPATH/Kyocera ECOSYS P6130cdn.PPD" # Error State
  #addPrinter "VD_Sette_Private_April_FS-4200DN" "$PPDPATH/Kyocera FS-4200DN.ppd"
}

vd_shresta(){
  addPrinter "VD_Shresta_3700dtn" # Not sure
}

vivarium(){
  addPrinter "AD_Vivarium_M3550idn" "$PPDPATH/Kyocera ECOSYS M3550idn.ppd" # Good
}

#  #addPrinter "VD_Sette_Private_April_FS-4200DN" "$PPDPATH/Kyocera FS-4200DN.ppd"
#}


# Just run the function we tell it as an argument to this script
# i.e.
# ./addPrinters IRT

"$1"
