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
    echo "P A R A N G    M A Y   M A L I,   L O D I C A K E !!!!"
    printf "\n"
    echo "S T E P   1:    C H I L L.   Y O U  G O T  T H I S.  I  B E L I E V E  I N  Y O U."
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
    echo "nice"

    printf "\n\n"
    echo "********************************************************"
    printf "\n"  
    echo "ssh-ing to GridIon"
    printf "\n"
    echo "********************************************************"
    printf "\n\n"


    sshpass -p PASSWORD ssh -T USER@IPADDRESS <<EOF

    printf "\n\n"
    echo "********************************************************"
    printf "\n"  
    echo "Copying $SEQ to the storage!"
    printf "\n"
    echo "********************************************************"
    printf "\n\n"

    rsync -aPvz --info=progress2 -e 'sshpass -p PASSWORD ssh -p 22' \
    /data/"$SEQ" \
    USER@IPADDRESS:/storage/ONT_Runs/drag_and_drop/
EOF
  

    printf "\n\n"
    echo "********************************************************"
    printf "\n"  
    echo "ssh-ing to HPC1"
    printf "\n"
    echo "********************************************************"
    printf "\n\n"


    sshpass -p PASSWORD ssh -p 2222 -T IPADDRESS <<EOF

    printf "\n\n"
    echo "********************************************************"
    printf "\n"  
    echo "Creating symbolic link of $SEQ to HPC1!"
    printf "\n"
    echo "********************************************************"
    printf "\n\n"


    ln -s /data/nfs/storage/ONT_Runs/drag_and_drop/test_transfer/$SEQ \
    /data/geco_proj_dir/raw/RITM/$SEQ
EOF
    exit
else
    usage
fi

```

  </details>


