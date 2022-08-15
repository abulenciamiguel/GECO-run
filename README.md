## How to run *ncov2019-artic-nf*

Files must be copied first to **storage** before transferring them to **hpc1**.

<details>
  <summary>List of files</summary>

 > 1.  *articNcovNanopore_prepRedcap_bammix_process* </br>
      • contains *csv* and *pdf* files with details on the proportion of base calls per position </br>
 > 2.  *articNcovNanopore_prepRedcap_concatenate_process* </br>
      • contains the concatenated consensus genomes of all samples </br>
 > 3.  *articNcovNanopore_prepRedcap_makeMeta* </br>
      • contains *Redcap* metadata </br>
 > 4.  *articNcovNanopore_prepRedcap_process_csv* </br>
      • contains the **Nextclade** and **Pangolin** lineage assignment of all samples </br>
 > 5.  *articNcovNanopore_prepRedcap_renameFasta* </br>
      • contains the consensus genomes of individual samples and scripts for uploading to Redcap.

</details>


To transfer the copied file from the **storage** to the **hpc1**, you have to tunnel first to the **storage** using the following command then enter the password:
```
ssh -p 22 ritmadmin@192.168.20.10
```

Locate the copied files in the following directory to be able to transfer them.

```
cd /storage/ONT_Runs
```



### The main workflow. What does the *main.nf* do?

1.  Lines 18-21 check for an input ***help***. If it is present, it will print the nextflow Help.
2.  Lines 23-26 check if the user mistyped ***profile***. If the user did, it will warn that it should be ***-profile*** instead of *profile*.
3.  Lines 28-60 checks for a workflow input. It could be any of the following: ***illumina***, ***nanopolish***, and ***medaka***. If there is no workflow input, a warning will be printed.
    <details>
      <summary>Details</summary>

      > •  For the ***illumina*** workflow, it will check for the directory containing the fastq or CRAM files. It will also check for both the bed file and reference genome. </br>
      > •  For the ***nanopolish*** workflow, it will check for the directory containing basecalled fastq files, fast5 files, and sequencing summary. It will also output a warning if bed file and reference genome are used as inputs. These two files are only used in illumina workflow. </br>
      > •  For the ***medaka*** workflow, it requires the basecalled fastq files. </br>
    </details>

4.  adasd
