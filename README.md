# How to run *ncov2019-artic-nf*
**Note:** Have `sshpass` installed using `sudo apt-get install sshpass`. 

### 1. Copying files from `GridIon` to `Storage` and `HPC1`.
  Run the script `transfer.sh` using the following command `./transfer.sh --sequence NameOfTheFolder`. </br>
  Example:
  ```
  ./transfer.sh --sequence sarscov2_geco_run52
  ```
  - The source folder is found in **GridIon**'s `/data`. </br>
  - The target directory in **Storage** is `/storage/ONT_Runs/drag_and_drop`. </br>
  - The target directory in **HPC1** is `/data/geco_proj_dir/raw/RITM`. </br>



### 2. Running the `artic-nf` pipeline.
- Run the script `runArtic.sh` using the following command `./runArtic.sh --dir path/to/data --barcode barcode.csv`. </br>
  Example: </br>
  ```
  ./runArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --barcode batch52_barcodes.csv
  ```
- Run the script `runPostArtic.sh` using the following command `./runPostArtic.sh --dir path/to/data`. </br>
  Example: </br>
  ```
  ./runPostArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9
  ```



### 3. Copying results to local workstation
  Run the script `copyResults.sh` using the following command `./copyResults.sh --dir path/to/data --batch number`. Make sure that the batch number is not yet present in your local directory. </br>
  Example: </br>
```
./copyResults.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --batch 52
```



### 4. Inspecting the results
**In case of Repeat Samples** </br>
If you have a sample that was already sequenced from the previous batch, consider it as a *repeat sample*. Change the entry of that sample in the `redcap_repeat_instance` column of the `redcap_meta_analysis.csv` located in the `articNcovNanopore_prepRedcap_makeMeta` folder. You can do this using the following sample command: </br>

  
  
### Testing
