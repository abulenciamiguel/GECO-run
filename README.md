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




if [[ $SEQ != unset ]]
then
    sshpass -p gridPASSWORD ssh -T gridUSER@gridIPADDRESS <<EOF
      rsync -aPvz --info=progress2 -e 'sshpass -p hpc1PASSWORD ssh -p 22' \
      /data/"$SEQ" \
      storageUSER@storageIPADDRESS:/storage/ONT_Runs/drag_and_drop/test_transfer/ 2> /data/err_grid2stor.txt
EOF
  
    sshpass -p gridPASSWORD ssh -T gridUSER@gridIPADDRESS "cat /data/err_grid2stor.txt" > err_grid2stor.txt


ERROR_grid2stor=$(wc -c err_grid2stor.txt)
  if [[ $ERROR_grid2stor != "0 err_grid2stor.txt" ]]
  then
      echo "********************************************************"
      printf "\n"
      echo "May ERROR, lods."
      printf "\n"
      echo "Di makita ang source folder sa GridIon."
      printf "\n"
      echo "Check the folder name."
      printf "\n\n"
    else
      sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS <<EOF
        ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/test_transfer/$SEQ \
        /data/geco_proj_dir/raw/RITM/$SEQ 2> /data/geco_proj_dir/raw/RITM/err_stor2hpc1.txt
EOF
      sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS "cat /data/geco_proj_dir/raw/RITM/err_stor2hpc1.txt" > err_stor2hpc1.txt
    
      ERROR_stor2hpc1=$(wc -c err_stor2hpc1.txt)
      if [[ $ERROR_stor2hpc1 != "0 err_stor2hpc1.txt" ]]
      then
        echo "********************************************************"
        echo "ERROR, lods! JOKE! JOKE! JOKE! Bawasan ang coffee consumption. "
        echo "Identical folder is present in HPC1. Replacing it with the new one."
        echo "All is good. You got this, my bossman!"
        echo "********************************************************"
        printf "\n\n"
        sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS "rm /data/geco_proj_dir/raw/RITM/$SEQ"
        sshpass -p hpc1PASSWORD ssh -p 2222 -T hpcUSER@hpcIPADDRESS <<EOF
        ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/test_transfer/$SEQ \
        /data/geco_proj_dir/raw/RITM/$SEQ
EOF
      else
        echo "Okay ka, Kokey!"
      fi
    fi
else
    usage
fi

rm err_grid2stor.txt
rm err_stor2hpc1.txt

```

  </details>


### 2. Running the pipeline.
