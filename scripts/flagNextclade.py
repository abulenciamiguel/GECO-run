import pandas as pd
pd.options.mode.chained_assignment = None  # default='warn'
import csv
import argparse

parser = argparse.ArgumentParser(description='Flagging samples using Nextclade output')
parser.add_argument("--dir", required=True, type=str, help="directory where the nextclade.tsv is located")


args = parser.parse_args()

result = args.dir



# Uploading the Nextclade results
nextclade_df = pd.read_csv(result+"/postArtic/nextclade/result/nextclade.tsv", sep='\t')


################################################
# Chunk: Alignment error
# Flagging samples with error in reads alignment
errors = -(pd.isnull(nextclade_df['errors']))
rows_withErrors = nextclade_df[errors]
seqName_withErrors = rows_withErrors[['seqName', 'errors']]
# Checks if there are flagged samples and prints accordingly
if len(seqName_withErrors) > 0:
	print("\n\n\n(1/8)  Samples with flagged errors")
	print(seqName_withErrors)
else:
	print("\n\n\n(1/8)	There are no samples flagged for alignment errors!")
# Saves the dataframe
seqName_withErrors.to_csv(result+'/flagged_Errors.csv', encoding='utf-8', index=False, header=True)



################################################
# Chunk: Mixed sites
# Drops NaN entry in the mixedSites column
nonBlank_mixedSites = -(pd.isnull(nextclade_df['qc.mixedSites.status']))
nonBlank_mixedSites_df = nextclade_df[nonBlank_mixedSites]
# Flagging mixed sites with 'not good' entry
chosen_param_mixedSites = nonBlank_mixedSites_df[(nonBlank_mixedSites_df['qc.mixedSites.status'] != "good")]
seqName_mixedSites = chosen_param_mixedSites[['seqName', 'qc.mixedSites.totalMixedSites']]
# Checks if there are flagged samples and prints accordingly
if len(seqName_mixedSites) > 0:
	print("\n\n\n(2/8)  Samples with flagged mixed sites")
	print(seqName_mixedSites)
else:
	print("\n\n\n(2/8)  There are no samples flagged for mixed sites!")
# Saves the dataframe
seqName_mixedSites.to_csv(result+'/flagged_mixedSites.csv', encoding='utf-8', index=False, header=True)







################################################
# Chunk: Private mutations
# Drops NaN entry in the privateMutations column
nonBlank_privateMutations = -(pd.isnull(nextclade_df['qc.privateMutations.status']))
nonBlank_privateMutations_df = nextclade_df[nonBlank_privateMutations]
# Flags private mutations with 'not good' entry
flagged_privateMutations = nonBlank_privateMutations_df[(nonBlank_privateMutations_df['qc.privateMutations.status'] != "good")]
# Selects the labeled and unlabeled substitution columns for the flagged samples
seqName_privateMutations = flagged_privateMutations[['seqName', 'privateNucMutations.labeledSubstitutions', 'privateNucMutations.unlabeledSubstitutions']]
# Renames the columns accordingly
seqName_privateMutations.rename(columns = {'privateNucMutations.labeledSubstitutions':'labeledSubs', 'privateNucMutations.unlabeledSubstitutions':'unlabeledSubs'}, inplace = True)

# Checks if there are flagged samples and prints accordingly
if len(seqName_privateMutations) > 0:
	print("\n\n\n(3/8)  Samples with flagged private mutations")
	print(seqName_privateMutations)
else:
	print("\n\n\n(3/8)  There are no samples flagged for private mutations!")

# Saves the dataframe
seqName_privateMutations.to_csv(result+'/flagged_privateMutations.csv', encoding='utf-8', index=False, header=True)




################################################
# Chunk: SNP clusters
# Drops NaN entry in the snpClusters column
nonBlank_snpClusters = -(pd.isnull(nextclade_df['qc.snpClusters.status']))
nonBlank_snpClusters_df = nextclade_df[nonBlank_snpClusters]
# Flagging SNP clusters with 'not good' entry
chosen_param_snpClusters = nonBlank_snpClusters_df[(nonBlank_snpClusters_df['qc.snpClusters.status'] != "good")]
seqName_snpClusters = chosen_param_snpClusters[['seqName', 'qc.snpClusters.totalSNPs']]
# Checks if there are flagged samples and prints accordingly
if len(seqName_snpClusters) > 0:
	print("\n\n\n(4/8)  Samples with SNP clusters")
	print(seqName_snpClusters)
else:
	print("\n\n\n(4/8)  There are no samples flagged for SNP clusters!")
# Saves the dataframe
seqName_snpClusters.to_csv(result+'/flagged_snpClusters.csv', encoding='utf-8', index=False, header=True)




################################################
# Chunk: Frameshifts
# Drops NaN entry in the frameShifts column
nonBlank_frameShifts = -(pd.isnull(nextclade_df['qc.frameShifts.status']))
nonBlank_frameShifts_df = nextclade_df[nonBlank_frameShifts]
# Flagging frameshifts with 'not good' entry
chosen_param_frameShifts = nonBlank_frameShifts_df[(nonBlank_frameShifts_df['qc.frameShifts.status'] != "good")]
seqName_frameShifts = chosen_param_frameShifts[['seqName', 'qc.frameShifts.frameShifts']]
# Checks if there are flagged samples and prints accordingly
if len(seqName_frameShifts) > 0:
	print("\n\n\n(5/8)  Samples with Frameshifts")
	print(seqName_frameShifts)
else:
	print("\n\n\n(5/8)  There are no samples flagged for Frameshifts!")
# Saves the dataframe
seqName_frameShifts.to_csv(result+'/flagged_frameShifts.csv', encoding='utf-8', index=False, header=True)




################################################
# Chunk: Stop codons
# Drops NaN entry in the stopCodons column
nonBlank_stopCodons = -(pd.isnull(nextclade_df['qc.stopCodons.status']))
nonBlank_stopCodons_df = nextclade_df[nonBlank_stopCodons]
# Flagging frameshifts with 'not good' entry
chosen_param_stopCodons = nonBlank_stopCodons_df[(nonBlank_stopCodons_df['qc.stopCodons.status'] != "good")]
seqName_stopCodons = chosen_param_stopCodons[['seqName', 'qc.stopCodons.stopCodons']]
# Checks if there are flagged samples and prints accordingly
if len(seqName_stopCodons) > 0:
	print("\n\n\n(6/8)  Samples with stop codons")
	print(seqName_stopCodons)
else:
	print("\n\n\n(6/8)  There are no samples flagged for stop codons!")
# Saves the dataframe
seqName_stopCodons.to_csv(result+'/flagged_stopCodons.csv', encoding='utf-8', index=False, header=True)






################################################
# Chunk: Low coverage (Nextclade)
# Drops NaN entry in the coverage column
nonBlank_coverage = -(pd.isnull(nextclade_df['coverage']))
nonBlankCoverage_df = nextclade_df[nonBlank_coverage]
# print(nonBlankCoverage_df)
lowCoverage = nonBlankCoverage_df[(nonBlankCoverage_df['coverage'] < 0.70)]
seqName_withlowCoverage = lowCoverage[['seqName', 'coverage']]

# Checks if there are flagged samples and prints accordingly
if len(seqName_withlowCoverage) > 0:
	print("\n\n\n(7/8)  Samples with % coverage < 0.70 in Nextclade")
	print(seqName_withlowCoverage)
else:
	print("\n\n\n(7/8)  There are no samples with % coverage < 0.70 in Nextclade!")

# Saves the dataframe
seqName_withlowCoverage.to_csv(result+'/flagged_Coverage_Nextclade.csv', encoding='utf-8', index=False, header=True)



################################################
# Chunk: Low coverage (Pangolin)
# Imports Pangoling result
pango = pd.read_csv(result+"/articNcovNanopore_prepRedcap_pangolin_process/lineage_report.csv")
# Selects the needed columns
pango_df = pango[['taxon', 'lineage', 'qc_notes']]
# Splits the 'qc_notes' to get the proportion of ambiguous bases
pango_df[['QC', 'AmbigProportion']] = pango_df['qc_notes'].str.split(':', expand=True)
pango_split = pango_df[['taxon', 'lineage', 'AmbigProportion']]
# Changes the 'AmbigProportion' into float type 
pango_split['AmbigProportion'] = pango_split['AmbigProportion'].astype(float)
# Flags samples with more than 30 % ambiguous bases
lowCoverage_pango = pango_split[(pango_split['AmbigProportion'] > 0.30)]
seqName_withlowCoverage_pango = lowCoverage_pango[['taxon', 'AmbigProportion']]

# Checks if there are flagged samples and prints accordingly
if len(seqName_withlowCoverage_pango) > 0:
	print("\n\n\n(8/8)  Samples with % ambiguous bases > 30% in Pangolin")
	print(seqName_withlowCoverage_pango)
else:
	print("\n\n\n(8/8)  There are no samples with % ambiguous bases > 30% in Pangolin!\n\n")

# Saves the dataframe
seqName_withlowCoverage_pango.to_csv(result+'/flagged_Coverage_Pango.csv', encoding='utf-8', index=False, header=True)
