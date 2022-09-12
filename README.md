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
        ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/test_transfer/$SEQ \
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


### 2. Running the pipeline.
  Run the bash script using the following command `./runArtic.sh --dir path/to/seqdata --barcode barcode.csv`. Example: </br>
```
./runArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --barcode batch42069_barcodes.csv
```

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
PARSED_ARGUMENTS=$(getopt -a -n 'runningArticNextflow' -o "d:s:" --long "dir:,barcode:" -- "$@")
VALID_ARGUMENTS=$?
if [ "$VALID_ARGUMENTS" != "0" ]; then
  usage
fi

eval set -- "$PARSED_ARGUMENTS"
while :
do
  case "$1" in
    -d | --dir ) DIR="$2" ; shift 2 ;;
    -s | --barcode ) BAR="$2" ; shift 2 ;;
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

prefix=$(echo $DIR | awk -F "/" '{print $3}')   # Takes the 3rd input as the prefix 


if [[ $DIR != unset && $BAR != unset ]]        # Forces the user to input both parameters
then

  # Copies the barcode file to the HPC1 directory
  sshpass -p PASSWORD scp -P 2222 $BAR USER@IPADDRESS:/data/geco_proj_dir/raw/RITM/$DIR/

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
    --outdir /data/geco_proj_dir/analysis/RITM/$DIR"_results_2nd" \
    --directory /data/geco_proj_dir/raw/RITM/$DIR \
    --redcap_local_ids /data/geco_proj_dir/raw/RITM/$DIR/$BAR

EOF

else
  usage
fi
```
</details>


### 3. Copying results to local workstation
