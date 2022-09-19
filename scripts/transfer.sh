#!/bin/bash
# Set some default values:
SEQ=unset


#==================================================================================
# Chunk 1
# The warning and instruction on how to structure the command for correct syntax.
usage()
{
  echo "********************************************************"
  printf "\n"
  echo "P A R A N G      M A Y     M A L I,     L O D I C A K E !!!!"
  printf "\n"
  echo "S T E P   1:      C H I L L.     Y O U  G O T  T H I S.    I  B E L I E V E  I N  Y O U."
  printf "\n"
  echo "Usage: [ -s or --sequence "FolderName" ]"
  echo "Example: ./transfer.sh --sequence sarscov_geco_run42069"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'dataTransfer' -o "s:" --long "sequence:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -s | --sequence ) SEQ="$2" ; shift 2 ;;
    # -- means the end of the arguments; drop this, and break out of the while loop
    --) shift; break ;;
    # If invalid options were passed, then getopt should have reported an error,
    # which we checked as VALID_ARGUMENTS when getopt was called...
    *)
       usage ;;
  esac
done
#==================================================================================

#==================================================================================
# Chunk 3

if [[ $SEQ == unset ]]        # Forces the user to input something
then
  usage
else                          # Copies the file to storage and saving stderr to a file
  sshpass -p PASSWORD_GRID ssh -T USER_GRID@IPADDRESS_GRID <<EOF
    rsync -aPvz --info=progress2 -e 'sshpass -p PASSWORD_STORAGE ssh -p 22' \
    /data/"$SEQ" \
    USER_STORAGE@IPADDRESS_STORAGE:/storage/ONT_Runs/drag_and_drop/ 2> /data/err_grid2stor.txt

EOF
  # Copies the stderr to local machine for checking
  sshpass -p PASSWORD_GRID ssh -T USER_GRID@IPADDRESS_GRID "cat /data/err_grid2stor.txt" > err_grid2stor.txt


  # Saves the stderr in a variable. 0 means there was no error from the copying to storage
  ERROR_grid2stor=$(wc -c err_grid2stor.txt)

  if [[ $ERROR_grid2stor != "0 err_grid2stor.txt" ]]
  then                        # Warns if there was an error in copying from GridIon to Storage
    echo "********************************************************"
    printf "\n"
    echo "May ERROR, lods."
    printf "\n"
    echo "Check the folder name or err_grid2stor.txt."
    printf "\n\n"


  else                        # Creates symbolic link from Storage to HPC1
    sshpass -p PASSWORD_HPC ssh -p 2222 -T USER_HPC@IPADDRESS_HPC <<EOF
    ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/$SEQ \
    /data/geco_proj_dir/raw/RITM/$SEQ 2> /data/geco_proj_dir/raw/RITM/err_stor2hpc1.txt
EOF
    # Copies the stderr of symbolic link creation to local machine for checking
    sshpass -p PASSWORD_HPC ssh -p 2222 -T USER_HPC@IPADDRESS_HPC "cat /data/geco_proj_dir/raw/RITM/err_stor2hpc1.txt" > err_stor2hpc1.txt
    
    # Saves the stderr in a variable. 0 means there was no error in the creation of symbolic link.
    ERROR_stor2hpc1=$(wc -c err_stor2hpc1.txt)

    if [[ $ERROR_stor2hpc1 != "0 err_stor2hpc1.txt" ]]
    then    # Warns if there is an identical folder in the HPC1 then replaces it with a new one.
      echo "********************************************************"
      echo "ERROR, lods! JOKE! JOKE! JOKE! Bawasan ang coffee consumption. "
      echo "Identical folder is present in HPC1. I'm replacing it with the new one."
      echo "All is good, boss amo! Splendid! Awesome! Congratulations!"
      echo "********************************************************"
      printf "\n\n"
      sshpass -p PASSWORD_HPC ssh -p 2222 -T USER_HPC@IPADDRESS_HPC "rm /data/geco_proj_dir/raw/RITM/$SEQ"
      sshpass -p PASSWORD_HPC ssh -p 2222 -T USER_HPC@IPADDRESS_HPC <<EOF
      ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/$SEQ \
      /data/geco_proj_dir/raw/RITM/$SEQ
EOF
    else    # If all is good.
      echo "Okay ka, Kokey!"
      echo "Splendid! Awesome! Congratulations!"
    fi
  fi
fi
