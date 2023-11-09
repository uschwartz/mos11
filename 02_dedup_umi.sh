AnalysisDir=/Volumes/PromisePegasus/_Service_/S003_20210924_Export-AraThal/
cd $AnalysisDir

nextflow run script/221130_finalRun_FC2/nf_umi_dedup/ \
        --bamPath $AnalysisDir/221130_finalRun_FC2/alignment \
        --outPath $AnalysisDir/221130_finalRun_FC2/alignment \
        -w work_UMI -resume
