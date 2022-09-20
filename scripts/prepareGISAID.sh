#!/bin/bash
# Set some default values:
META=unset


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
  echo "Usage: [ -m or --meta path/to/gisaid_metadata.tar.xz ]"
  echo "Example: ./extractPHGISAID.sh --meta Batch54/metadata_tsv_2022_09_17.tar.xz"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'extracting PH samples from GISAID metadata' -o "m:" --long "meta:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -m | --meta ) META="$2" ; shift 2 ;;
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


if [[ $META != unset ]]        # Forces the user to input both parameters
then
  echo "Copying $META to HPC1" \
  && sshpass -p PASSWORD_HPC scp -r -P 2222 $META USER_HPC@IPADDRESS_HPC:/data/geco_proj_dir/gisaid_download \
  && echo "Done copying $META" \
  && sshpass -p PASSWORD_HPC ssh -p 2222 -T USER_HPC@IPADDRESS_HPC <<EOF
    echo "Activating redcap2gisaid environment"
    source /data/apps/miniconda3/bin/activate redcap2gisaid
    echo "Extracting GISAID metadata"
    bash /data/geco_proj_dir/gisaid_download/extract_ph_metadata.sh \
    && cd /data/geco_proj_dir/auto_redcap2gisaid \
    && echo "Preparing file format for submission" \
    && python prepare_submission_now.py
EOF
else
  usage
fi
