import pandas as pd
import csv
import argparse

parser = argparse.ArgumentParser(description='Flagging samples using Nextclade output')
parser.add_argument("--dir", required=True, type=str, help="directory where the nextclade.tsv is located")


args = parser.parse_args()


result = args.dir


nextclade_df = pd.read_csv(result+"/postArtic/nextclade/result/nextclade.tsv", sep='\t')


errors = -(pd.isnull(nextclade_df['errors']))
rows_withErrors = nextclade_df[errors]
seqName_withErrors = rows_withErrors[['seqName']]
print("Samples with flagged errors!")
print(seqName_withErrors)
seqName_withErrors.to_csv(result+'/flagged_Errors.csv', encoding='utf-8', index=False, header=False)


nonBlank_coverage = -(pd.isnull(nextclade_df['coverage']))
nonBlankCoverage_df = nextclade_df[nonBlank_coverage]
lowCoverage = nonBlankCoverage_df[(nonBlankCoverage_df['coverage'] < 0.70)]
seqName_withlowCoverage = lowCoverage[['seqName']]
print("\n\n\nSamples with % coverage < 0.70!")
print(seqName_withlowCoverage)
seqName_withlowCoverage.to_csv(result+'/flagged_Coverage.csv', encoding='utf-8', index=False, header=False)


params = ["mixedSites", "privateMutations", "snpClusters", "frameShifts", "stopCodons"]
for i in params:
	nonBlank = -(pd.isnull(nextclade_df['qc.'+i+'.status']))
	nonBlank_df = nextclade_df[nonBlank]
	chosen_param = nonBlank_df[(nonBlank_df['qc.'+i+'.status'] != "good")]
	seqName = chosen_param[['seqName']]
	print("\n\n\nSamples with flagged "+i)
	print(seqName)
	seqName.to_csv(result+'/flagged_'+i+'.csv', encoding='utf-8', index=False, header=False)
