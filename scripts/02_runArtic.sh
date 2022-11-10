#!/bin/bash
# Set some default values:
DIR=unset
BAR=unset
hpc_userIP=USER@IP
hpcPASS=PASSWORD

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
  echo "Usage: [ -d or --dir path/to/seqdata ] [ -b or --barcode barcode.csv ]"
  echo "Example: ./02_runArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 -barcode batch42069_barcodes.csv"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'runningArticNextflow' -o "d:b:" --long "dir:,barcode:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --dir ) DIR="$2" ; shift 2 ;;
    -b | --barcode ) BAR="$2" ; shift 2 ;;
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

prefix=$(echo $DIR | awk -F "/" '{print $NF}')   # Takes the 3rd or last input as the prefix 


if [[ $DIR != unset && $BAR != unset ]]        # Forces the user to input both parameters
then

  # Copies the barcode file to the HPC1 directory
  sshpass -p $hpcPASS scp -P 2222 $BAR hpc_userIP:/data/geco_proj_dir/raw/RITM/

  # Saves the sequencing summary file in a variable
  seqsum_file=$(sshpass -p $hpcPASS ssh -p 2222 -T hpc_userIP "ls -1 /data/geco_proj_dir/raw/RITM/$DIR/sequencing_summary_*txt")

  # Runs the artic-nf
  sshpass -p $hpcPASS ssh -p 2222 -T hpc_userIP <<EOF

    source /data/apps/miniconda3/bin/activate nextflow_conda_sandbox
    cd /apps/ncov2019-artic-nf_automated_two/ncov2019-artic-nf-GECO

    nextflow run /apps/ncov2019-artic-nf_automated_two/ncov2019-artic-nf-GECO \
    -profile conda \
    --nanopolish \
    --prefix $prefix \
    --basecalled_fastq /data/geco_proj_dir/raw/RITM/$DIR/fastq_pass \
    --fast5_pass /data/geco_proj_dir/raw/RITM/$DIR/fast5_pass \
    --sequencing_summary $seqsum_file \
    --outdir /data/geco_proj_dir/analysis/RITM/$DIR"_results" \
    --directory /data/geco_proj_dir/raw/RITM/$DIR \
    --redcap_local_ids /data/geco_proj_dir/raw/RITM/$BAR

EOF

else
  usage
fi
