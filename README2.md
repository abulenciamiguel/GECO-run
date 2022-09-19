# How to run *ncov2019-artic-nf*

### 1. Copying files from **GridIon** to **Storage** and **HPC1**.
  Run the script `transfer.sh` using the following command `./transfer.sh --sequence NameOfTheFolder`. </br>
  - The source folder is found in **GridIon**'s `/data`. </br>
  - The target directory in **Storage** is `/storage/ONT_Runs/drag_and_drop`. </br>
  - The target directory in **HPC1** is `/data/geco_proj_dir/raw/RITM`. </br>

**Note:** Have `sshpass` installed using `sudo apt-get install sshpass`. Change the `PASSWORD` and the corresponding `USER@IPADDRESS` to `ssh`. 


### 2. Running the `artic-nf` pipeline.
  Run the script `runArtic.sh` using the following command `./runArtic.sh --dir path/to/seqdata --barcode barcode.csv`. Example: </br>
```
./runArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --barcode batch42069_barcodes.csv
```

**Note:** Have `sshpass` installed using `sudo apt-get install sshpass`. Change the `PASSWORD` and the corresponding `USER@IPADDRESS` to `ssh`. 


### 3. Copying results to local workstation
  Run the script `copyResults.sh` using the following command `./copyResults.sh --dir path/to/results --batch number`. Example: </br>
```
./copyResults.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --batch 53
```

**Note:** Have `sshpass` installed using `sudo apt-get install sshpass`. Change the `PASSWORD` and the corresponding `USER@IPADDRESS` to `ssh`.


### 4. Inspecting the results
**In case of Repeat Samples** </br>
If you have a sample that was already sequenced from the previous batch, consider it as a *repeat sample*. Change the entry of that sample in the `redcap_repeat_instance` column of the `redcap_meta_analysis.csv` located in the `articNcovNanopore_prepRedcap_makeMeta` folder. You can do this using the following sample command: </br>

  
  
### Testing
