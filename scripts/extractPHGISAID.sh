#!/bin/bash
# Set some default values:
OUT=unset
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
  echo "Usage: [ -o or --out path/to/results ] [ -m or --meta gisaid_metadata.tar.xz ]"
  echo "Example: ./extractPHGISAID.sh --out Batch54 --meta metadata_tsv_2022_09_17.tar.xz"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'extracting PH samples from GISAID metadata' -o "o:m:" --long "out:,meta:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -o | --out ) OUT="$2" ; shift 2 ;;
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


if [[ $OUT != unset && $META != unset ]]        # Forces the user to input both parameters
then
  tar -xJOvf $OUT/$META metadata.tsv \
  | grep "hCoV-19/Philippines/" \
  | awk 'BEGIN{print "Virus name\tType\tAccession ID\tCollection date\tLocation\tAdditional location information\tSequence length\tHost\tPatient age\tGender\tClade\tPango lineage\tPangolin version\tVariant\tAA Substitutions\tSubmission date\tIs reference?\tIs complete?\tIs high coverage?\tIs low coverage?\tN-Content\tGC-Content"}; {print $0}' \
  > $OUT/extractedMetadata_PH.tsv
else
  usage
fi
