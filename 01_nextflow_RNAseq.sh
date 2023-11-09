#### Run data
AnalysisDir=/Volumes/PromisePegasus/_Service_/S003_20210924_Export-AraThal/

cd $AnalysisDir

############################## main ############################################

nextflow run ~/00_scripts/nextflow/RNAseq/main.nf  \
	--fastqPath $AnalysisDir/data/221130_finalRun_FC2/UMI \
	--outPath $AnalysisDir/221130_finalRun_FC2 \
	--STARidxPath ~/Annotation/TAIR_10/STARidx_ERCC \
	--gtfPath ~/Annotation/TAIR_10/nextflow \
    --strandness forward \
	--gtfFile protein_coding_and_lincRNA.gtf
