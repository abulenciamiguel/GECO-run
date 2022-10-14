# How to run *ncov2019-artic-nf*
**Note:** </br>
- Have `sshpass` installed using `sudo apt-get install sshpass`. 
- Prior to running the first script, have someone from `BDMU` access `GridIon` using `ssh` so that you can take the directory of the raw file. The format of the directory will be `Level1/Level2/Level3`. 
- Prepare a `csv` file containing the `barcodes` in the first column and local ID in the second one. See example [here](https://github.com/ufuomababatunde/GECO-run/blob/main/sampleFile/samplebarcodes.csv).
- If you have samples that have been resequenced, hereafter referred as `repeats`, prepare a `csv` file containing just the `number` of its `sample ID` as shown [here](https://github.com/ufuomababatunde/GECO-run/blob/main/sampleFile/samplerepeats.csv).
- Place the said `csv` files as well as the scripts in an easily accessible directory. For example, you can place them in `drive D` which can be accessed through the `Linux terminal` using
```
cd /mnt/d
```



### 1. Copying files from `GridIon` to `Storage` and `HPC1`.
  Assuming you are in `drive D`, run the following command `./01_transfer.sh --sequence Level1` where `Level1` corresponds to the first level of the copied directory.</br>
  Example:
  ```
  ./01_transfer.sh --sequence sarscov2_geco_run52
  ```
  - The source folder is found in **GridIon**'s `/data`. </br>
  - The target directory in **Storage** is `/storage/ONT_Runs/drag_and_drop`. </br>
  - The target directory in **HPC1** is `/data/geco_proj_dir/raw/RITM`. </br>



### 2. Running the `artic-nf` pipeline.
- Run the following command `./02_runArtic.sh --dir Level1/Level2/Level3 --barcode barcode.csv`. </br>
  Example: </br>
  ```
  ./02_runArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --barcode batch52_barcodes.csv
  ```



### 3. Run the additional `UShER`'s lineage assignment and `sc2rf`'s recombinant analysis
- Run the following command `./03_runPostArtic.sh --dir Level1/Level2/Level3`. </br>
  Example: </br>
  ```
  ./03_runPostArtic.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9
  ```



### 4. Copying results to local workstation
  Run the following command `./04_copyResults.sh --dir Level1/Level2/Level3 --batch number`. Make sure that the batch number is not yet present in your local directory. </br>
  Example: </br>
```
./copyResults.sh --dir sarscov2_geco_run52/sarscov2_geco_run52_09012022/20220901_0808_X5_FAT95592_ef9365b9 --batch 52
```



### 5. Uploading to REDCap
- **Dealing with repeat samples** (Skip if there is none)</br>
  Run script `dealRepeats.sh` to change the instance number in metadata and move the fasta file of the repeat samples. You need a file containing the sample number of the repeat samples in each line. `Batch52` corresponds to the directory where the results are found. </br>
  Example: </br>
  ```
  ./dealRepeats.sh --dir_input Batch52 --file_repeat repeats.csv
  ```

- **Uploading metadata for the `Sequence` and `Analysis` information** </br>
  *Step 1*: Go to the `GECO` page of RITM's [REDCap](https://geco.ritm-edc.net/) website. </br>
  *Step 2*: On the left panel under `Applications`, go to the `Data Import Tool`. </br>
  *Step 3*: Under `CSV import` tab, click `Choose File` button to upload the CSV file. </br>
  *Step 4 (`Sequence`)*: Upload the `redcap_meta_sequence.csv` file inside the `articNcovNanopore_prepRedcap_makeMeta` folder. </br>
  *Step 5 (`Analysis`)*: In the new page that loads up, upload the `meta_analysis.csv` file inside the `articNcovNanopore_prepRedcap_process_csv` folder. </br></br>


- **Uploading `fasta` files** </br>
  Run the following command: </br>
  ```
  conda run -n redcap_upload python uploadFastaREDCaP.py --api API_TOKEN --dir RESULT_DIRECTORY
  ```
  Example: </br>
  ```
  conda run -n redcap_upload python uploadFastaREDCaP.py --api OIPSDVBNsUF4S13FAS3FVSAF11345135 --dir Batch52
  ```
  For repeat samples, manually upload their `fasta` files. </br></br>
  
  

### 5. QC
- **Flagging lineage assignments** </br>
  Run the following command to flag samples </br>
  ```
  python flagLineage.py --dir Batch52
  ```
  
- **Flagging Nextclade results** </br>
  Run the following command to flag samples </br>
  ```
  python flagNextclade.py --dir Batch52
  ```
  
- **Verifying flagged samples**




### 6. Preparing for GISAID upload
- **Downloading updated metadata from GISAID**
    Download metadata from GISAID and save on the directory where you want it to be extracted. </br>
    For instance, if your results are in `Batch52`, place it in there.
- **Extracting PH samples** <br>
    Run the script `extractPHGISAID.sh` using the following command: `./extractPHGISAID.sh --out path/to/results --meta gisaid_metadata.tar.xz` </br>
    Example: </br>
    ```
    ./extractPHGISAID.sh --out Batch52 --meta metadata_tsv_2022_09_17.tar.xz
    ```
    Successful run will show the following on the terminal: </br>
    ```
    
    ```
- **Copying results to local computer**
    Run the script `copyResults_gisaid.sh` using the following command: `./copyResults_gisaid.sh --dir path/to/results` </br>
    Example: </br>
    ```
    ./copyResults.sh --dir Batch52
    ```
    The copied results can be found in the gisaidSubmission inside the set directory.
