#!/bin/bash
# Set some default values:
DIR=unset


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
  echo "Usage: [ -d or --dir path/to/results ]"
  echo "Example: ./runPostArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'running Nextclade and UShER' -o "d:" --long "dir:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --dir ) DIR="$2" ; shift 2 ;;
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



if [[ $DIR != unset ]]        # Forces the user to input both parameters
then
  # Runs the artic-nf
  sshpass -p PASSWORD_HPC ssh -p 2222 -T USER_HPC@IPADDRESS_HPC <<EOF

    # Activates postArtic environment
    source /data/apps/miniconda3/bin/activate postArtic

    cd /data/geco_proj_dir/analysis/RITM/$DIR"_results"/

    # NEXTCLADE Chunk
    mkdir -p postArtic/nextclade

    # Downloads updated sars-cov-2 dataset
    nextclade dataset get --name 'sars-cov-2' --output-dir 'postArtic/nextclade/'

    # Runs the nextclade

    nextclade run \
    --input-dataset 'postArtic/nextclade' \
    --output-tsv 'postArtic/nextclade/result/nextclade.tsv' \
    --output-tree 'postArtic/nextclade/result/tree.json' \
    articNcovNanopore_prepRedcap_concatenate_process/all_sequences.fasta


    # USHER Chunk
    mkdir -p postArtic/usher

    # Downloads the updated sars-cov-2 dataset
    wget -O - "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=nuccore&id=NC_045512.2&rettype=fasta" | \
    sed '1 s/^.*$/>NC_045512v2/' > postArtic/usher/NC_045512v2.fa

    # Alignment
    unset MAFFT_BINARIES # Done if there is a problem in the configuration of the shell

    mafft --thread 20 --auto --keeplength --addfragments \
    articNcovNanopore_prepRedcap_concatenate_process/all_sequences.fasta \
    postArtic/usher/NC_045512v2.fa > postArtic/usher/myAlignedSequences.fa

    # Downloads the problematic sites in ref genome
    # wget -O - "https://raw.githubusercontent.com/W-L/ProblematicSites_SARS-CoV2/master/problematic_sites_sarsCov2.vcf" > \
    # postArtic/usher/problematic_sites_sarsCov2.vcf

    # Converts fasta to vcf with correction for the problematic sites
    # faToVcf -maskSites=postArtic/usher/problematic_sites_sarsCov2.vcf \
    # postArtic/usher/myAlignedSequences.fa \
    # postArtic/usher/myAlignedSequences.vcf

    faToVcf postArtic/usher/myAlignedSequences.fa \
    postArtic/usher/myAlignedSequences.vcf

    # Downloads the latest global lineages
    wget -O - "http://hgdownload.soe.ucsc.edu/goldenPath/wuhCor1/UShER_SARS-CoV-2/public-latest.all.masked.pb.gz" | \
    gunzip -c > postArtic/usher/public-latest.all.masked.pb

    # Runs usher for lineage assignment
    usher -i postArtic/usher/public-latest.all.masked.pb \
    -v postArtic/usher/myAlignedSequences.vcf -u -d postArtic/usher/result

EOF

else
  usage
fi
