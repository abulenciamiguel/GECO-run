import pandas as pd
import csv
import argparse

parser = argparse.ArgumentParser(description='Flagging samples with different lineage assignments, i.e., Nextclade vs UShER')
parser.add_argument("--dir", required=True, type=str, help="directory where the results are located")


args = parser.parse_args()


result = args.dir

# Importing files as dataframe
nextclade_file = pd.read_csv(result+"/postArtic/nextclade/result/nextclade.tsv", sep='\t')
usher_file = pd.read_csv(result+"/postArtic/usher/result/clades.txt", sep='\t')

# Selecting only relevant columns
nextclade_df = nextclade_file[['seqName', 'clade', 'Nextclade_pango']]
usher_df = usher_file[['NC_045512v2', '19A', 'B']]
# Changing the column names in UShER file
usher_df.rename(columns = {'NC_045512v2':'seqName', '19A':'clade', 'B':'Nextclade_pango'}, inplace = True)

# Sorting rows based on seqName
nextclade_sorted = nextclade_df.sort_values(by=['seqName'], ascending=True)
usher_sorted = usher_df.sort_values(by=['seqName'], ascending=True)


# Concatenating the two dataframes then drops the duplicate rows (i.e., assigned to similar lineages)
diff_df = pd.concat([nextclade_sorted,usher_sorted]).drop_duplicates(keep=False)


flagged = len(diff_df)/2

if flagged == 0:
	print("All samples have the same lineage assignment using Nextclade and UShER")
else:
	print("There are", int(flagged), "flagged samples!\n")
	print("Check the following samples in Nextclade and UShER results!")
	print(diff_df)
# Saving the sample assigned to different lineages to a csv file
diff_df.to_csv(result+'/flagged_Lineage.csv', encoding='utf-8', index=False, header=False)
