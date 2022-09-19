# How to run *ncov2019-artic-nf*

### 1. Copying files from **GridIon** to **Storage** and **HPC1**.
  Run the bash script using the following command `./transfer.sh --sequence NameOfTheFolder`. </br>
  - The source folder is found in **GridIon**'s `/data`. </br>
  - The target directory in **Storage** is `/storage/ONT_Runs/drag_and_drop`. </br>
  - The target directory in **HPC1** is `/data/geco_proj_dir/raw/RITM`. </br>

**Note:** Have `sshpass` installed using `sudo apt-get install sshpass`. Change the `PASSWORD` and the corresponding `USER@IPADDRESS` to `ssh`. 

  <details>
    <summary>transfer.sh</summary>

  ```bash
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

if [[ $SEQ == unset ]]      # Forces the user to input something
then
    usage
else                        # Copies the file to storage and saving stderr to a file
    sshpass -p gridPASSWORD ssh -T gridUSER@gridIPADDRESS <<EOF
      rsync -aPvz --info=progress2 -e 'sshpass -p storagePASSWORD ssh -p 22' \
      /data/"$SEQ" \
      storageUSER@storageIPADDRESS:/storage/ONT_Runs/drag_and_drop/test_transfer/ 2> /data/err_grid2stor.txt
EOF
    # Copies the stderr to local machine for checking
    sshpass -p gridPASSWORD ssh -T gridUSER@gridIPADDRESS "cat /data/err_grid2stor.txt" > err_grid2stor.txt

    # Saves the stderr in a variable. 0 means there was no error from the copying to storage
    ERROR_grid2stor=$(wc -c err_grid2stor.txt)
  
    if [[ $ERROR_grid2stor != "0 err_grid2stor.txt" ]]
    then          # Warns if there was an error in copying from GridIon to Storage 
        echo "********************************************************"
        printf "\n"
        echo "May ERROR, lods."
        printf "\n"
        echo "Di makita ang source folder sa GridIon."
        printf "\n"
        echo "Check the folder name."
        printf "\n\n"
    else        # Creates symbolic link from Storage to HPC1
      sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS <<EOF
        ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/test_transfer/$SEQ \
        /data/geco_proj_dir/raw/RITM/$SEQ 2> /data/geco_proj_dir/raw/RITM/err_stor2hpc1.txt
EOF
      # Copies the stderr of symbolic link creation to local machine for checking
      sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS "cat /data/geco_proj_dir/raw/RITM/err_stor2hpc1.txt" > err_stor2hpc1.txt
  
      # Saves the stderr in a variable. 0 means there was no error in the creation of symbolic link.
      ERROR_stor2hpc1=$(wc -c err_stor2hpc1.txt)
  
      if [[ $ERROR_stor2hpc1 != "0 err_stor2hpc1.txt" ]]
      then      # Warns if there is an identical folder in the HPC1 then replaces it with a new one.
        echo "********************************************************"
        echo "ERROR, lods! JOKE! JOKE! JOKE! Bawasan ang coffee consumption. "
        echo "Identical folder is present in HPC1. I'm replacing it with the new one."
        echo "All is good, boss amo. Splendid! Awesome! Congratulations!"
        echo "********************************************************"
        printf "\n\n"
        sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS "rm /data/geco_proj_dir/raw/RITM/$SEQ"
        sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS <<EOF
        ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/$SEQ \
        /data/geco_proj_dir/raw/RITM/$SEQ
EOF
      else  # If all is good.
        echo "Okay ka, Kokey!"
        echo "Splendid! Awesome! Congratulations!"
      fi
    fi
fi
```

  </details>


### 2. Running the `artic-nf` pipeline.
  Run the bash script using the following command `./runArtic.sh --dir path/to/seqdata --barcode barcode.csv`. Example: </br>
```
./runArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --barcode batch42069_barcodes.csv
```

**Note:** Have `sshpass` installed using `sudo apt-get install sshpass`. Change the `PASSWORD` and the corresponding `USER@IPADDRESS` to `ssh`. 

  <details>
    <summary>runArtic.sh</summary>
  
  
```bash
#!/bin/bash
# Set some default values:
DIR=unset
BAR=unset


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
  echo "Example: ./runArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 -barcode batch42069_barcodes.csv"
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
  sshpass -p PASSWORD scp -P 2222 $BAR USER@IPADDRESS:/data/geco_proj_dir/raw/RITM/

  # Saves the sequencing summary file in a variable
  seqsum_file=$(sshpass -p PASSWORD ssh -p 2222 -T USER@IPADDRESS "ls -1 /data/geco_proj_dir/raw/RITM/$DIR/sequencing_summary_*txt")

  # Runs the artic-nf
  sshpass -p PASSWORD ssh -p 2222 -T USER@IPADDRESS <<EOF

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
```
</details>

#### Run `Nextclade` and `UShER` for lineage assignment as post-artic analysis.

  <details>
    <summary>runPostArtic.sh</summary>
  
  
```bash
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
  sshpass -p PASSWORD ssh -p 2222 -T USER@IPADDRESS <<EOF

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
    wget -O - "https://raw.githubusercontent.com/W-L/ProblematicSites_SARS-CoV2/master/problematic_sites_sarsCov2.vcf" > \
    postArtic/usher/problematic_sites_sarsCov2.vcf

    # Converts fasta to vcf with correction for the problematic sites
    faToVcf -maskSites=postArtic/usher/problematic_sites_sarsCov2.vcf \
    postArtic/usher/myAlignedSequences.fa \
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

```
</details>


### 3. Copying results to local workstation
  Run the bash script using the following command `./copyResults.sh --dir path/to/results --batch number`. Example: </br>
```
./copyResults.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --batch 53
```

**Note:** Have `sshpass` installed using `sudo apt-get install sshpass`. Change the `PASSWORD` and the corresponding `USER@IPADDRESS` to `ssh`.

  <details>
    <summary>copyResults.sh</summary>
  
  
```bash
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
PARSED_ARGUMENTS=$(getopt -a -n 'runningArticNextflow' -o "d:b:" --long "dir:,batch:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --dir ) DIR="$2" ; shift 2 ;;
    -s | --batch ) BATCH="$2" ; shift 2 ;;
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


if [[ $DIR != unset && $BATCH != unset ]]         # Forces the user to input both parameters
then
	mkdir -p Batch$BATCH                            # Creates a directory in the local workstation
  
  # Copies the following folders
  sshpass -p PASSWORD scp -r -P 2222 USER@IPADDRESS:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_renameFasta ./Batch$BATCH
  sshpass -p PASSWORD scp -r -P 2222 USER@IPADDRESS:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_process_csv ./Batch$BATCH
  sshpass -p PASSWORD scp -r -P 2222 USER@IPADDRESS:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_makeMeta ./Batch$BATCH
  sshpass -p PASSWORD scp -r -P 2222 USER@IPADDRESS:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_concatenate_process ./Batch$BATCH
  sshpass -p PASSWORD scp -r -P 2222 USER@IPADDRESS:/data/geco_proj_dir/analysis/RITM/$DIR"_results"/articNcovNanopore_prepRedcap_bammix_process ./Batch$BATCH
else
	usage
fi
```
</details>


### 4. Inspecting the results
**In case of Repeat Samples** </br>
If you have a sample that was already sequenced from the previous batch, consider it as a *repeat sample*. Change the entry of that sample in the `redcap_repeat_instance` column of the `redcap_meta_analysis.csv` located in the `articNcovNanopore_prepRedcap_makeMeta` folder. You can do this using the following sample command: </br>

```bash
./replaceInstance.sh --barcode 2194 --instance 2 --dir_input Batch53 --file_input 20220908_0847_X3_FAT96737_d97a9a19.redcap_meta_analysis
```

- `barcode` corresponds to the barcode of the repeat sample.
- `instance` corresponds to the number that this sample has been sequenced. If this is the 2nd time, place `2`.
- `dir_input` corresponds to the **first level** folder where the results are stored. In the example below, it is the **Batch53**.
```
      Batch53
	├── articNcovNanopore_prepRedcap_bammix_process
	├── articNcovNanopore_prepRedcap_concatenate_process
	├── articNcovNanopore_prepRedcap_process_csv
	├── articNcovNanopore_prepRedcap_renameFasta
	├── batch53_barcodes.csv
	└── articNcovNanopore_prepRedcap_makeMeta
		├── 20220908_0847_X3_FAT96737_d97a9a19.redcap_meta.csv
		├── 20220908_0847_X3_FAT96737_d97a9a19.redcap_meta_analysis.csv
		├── 20220908_0847_X3_FAT96737_d97a9a19.redcap_meta_case.csv
		├── 20220908_0847_X3_FAT96737_d97a9a19.redcap_meta_diagnostic.csv 
		└── 20220908_0847_X3_FAT96737_d97a9a19.redcap_meta_sequence.csv
```
- `file_input` corresponds to the file that contains the number of instances. If you are dealing with more than one repeat sample, use the output of the first run as the input of the succeeding runs. For example, the output of the first run with the input of `file_input` will be `file_input_REPLACED`. Hence, for the succeeding runs, the input will be `file_input_REPLACED` with an output of `file_input_REPLACED`. The input and output files of the succeeding runs will have the same name.


<details>
  <summary>replaceInstance.sh</summary>
  
  
```bash
#!/bin/bash
# Set some default values:
BARCODE=unset
INSTANCE=unset
DIR_INPUT=unset
FILE_INPUT=unset

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
  echo "Usage:  [ -b or --barcode barcodeOfTheRepeat ] [ -i or --instance instanceNumber ]"
  echo "        [ -d or --dir_input firstLevelDirectory ] [ -f or --file_input fileContainingTheInstances ]"
  echo "Example: ./replaceInstance.sh --barcode 2194 --instance 2 --dir_input Batch53 --file_input 20220908_0847_X3_FAT96737_d97a9a19.redcap_meta_analysis"
  printf "\n"
  echo "********************************************************"
  exit 2
}
#==================================================================================

#==================================================================================
# Chunk 2
# Parses the arguments entered in the command line
PARSED_ARGUMENTS=$(getopt -a -n 'replacingInstanceNumber' -o "b:i:d:f:" --long "barcode:,instance:,dir_input:,file_input:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -b | --barcode ) BARCODE="$2" ; shift 2 ;;
    -i | --instance ) INSTANCE="$2" ; shift 2 ;;
    -d | --dir_input ) DIR_INPUT="$2" ; shift 2 ;;
    -f | --file_input ) FILE_INPUT="$2" ; shift 2 ;;
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

if [[ $BARCODE != unset && $INSTANCE != unset && $DIR_INPUT != unset && $FILE_INPUT != unset ]]       # Forces the user to input both parameters
then
  sed 's/$BARCODE,analysis,1/$BARCODE,analysis,$INSTANCE/g' $DIR_INPUT/articNcovNanopore_prepRedcap_makeMeta/$FILE_INPUT".csv" > $DIR_INPUT/articNcovNanopore_prepRedcap_makeMeta/$FILE_INPUT"_REPLACED".csv
else
  usage
fi
```
  
</details>
  
  
### Testing
