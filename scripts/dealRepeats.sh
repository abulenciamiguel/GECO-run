#!/bin/bash
# Set some default values:
DIR_INPUT=unset
FILE_REPEAT=unset

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
  echo "Usage:  [ -d or --dir_input firstLevelDirectory ] [ -f or --file_repeat fileContainingTheInstances ]"
  echo "Example: ./dealRepeats.sh --dir_input Batch53 --file_repeat repeats.csv"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'replacingInstanceNumber' -o "d:f:" --long "dir_input:,file_repeat:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --dir_input ) DIR_INPUT="$2" ; shift 2 ;;
    -f | --file_repeat ) FILE_REPEAT="$2" ; shift 2 ;;
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

if [[ $DIR_INPUT != unset && $FILE_REPEAT != unset ]]       # Forces the user to input both parameters
then
  # removes the Windows-like CRLF line endings
  cat $FILE_REPEAT | tr -d '\r' > $FILE_REPEAT"_edited.txt"
  while IFS= read -r line
    do
      echo "Dealing with repeat sample $line............................"

      # Changing the instance number to 2
      sed -i "s/$line,sequence,1/$line,sequence,2/g" $DIR_INPUT/articNcovNanopore_prepRedcap_makeMeta/*.redcap_meta_sequence.csv
      sed -i "s/$line,analysis,1/$line,analysis,2/g" $DIR_INPUT/articNcovNanopore_prepRedcap_process_csv/meta_analysis.csv

      # Moving the fasta file of repeat samples to new folder
      mkdir -p $DIR_INPUT/repeatsFasta
      mv $DIR_INPUT/articNcovNanopore_prepRedcap_renameFasta/PH-RITM-$line.fasta $DIR_INPUT/repeatsFasta
    done < $FILE_REPEAT"_edited.txt"
else
  usage
fi
