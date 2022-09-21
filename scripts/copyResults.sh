#!/bin/bash
# Set some default values:
DIR=unset
BATCH=unset


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
  echo "Usage: [ -d or --dir path/to/results ] [ -b or --batch batchNumber ]"
  echo "Example: ./copyResults.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --batch 52"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'CopyingResultsToLocalWorkstation' -o "d:b:" --long "dir:,batch:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --dir ) DIR="$2" ; shift 2 ;;
    -b | --batch ) BATCH="$2" ; shift 2 ;;
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


if [[ $DIR != unset && $BATCH != unset ]]       # Forces the user to input both parameters
then
	mkdir -p Batch$BATCH						# Creates a directory in the local workstation

	# Copies the following folders
  sshpass -p ?+6aW#Xk=u2dRjpc scp -r -P 2222 ritmadmin@192.168.20.13:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_pangolin_process ./Batch$BATCH
	sshpass -p ?+6aW#Xk=u2dRjpc scp -r -P 2222 ritmadmin@192.168.20.13:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_renameFasta ./Batch$BATCH
	sshpass -p ?+6aW#Xk=u2dRjpc scp -r -P 2222 ritmadmin@192.168.20.13:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_process_csv ./Batch$BATCH
	sshpass -p ?+6aW#Xk=u2dRjpc scp -r -P 2222 ritmadmin@192.168.20.13:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_makeMeta ./Batch$BATCH
	sshpass -p ?+6aW#Xk=u2dRjpc scp -r -P 2222 ritmadmin@192.168.20.13:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_concatenate_process ./Batch$BATCH
	sshpass -p ?+6aW#Xk=u2dRjpc scp -r -P 2222 ritmadmin@192.168.20.13:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_bammix_process ./Batch$BATCH
  sshpass -p ?+6aW#Xk=u2dRjpc scp -r -P 2222 ritmadmin@192.168.20.13:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/postArtic ./Batch$BATCH
else
	usage
fi
