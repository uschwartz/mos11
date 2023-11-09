AnalysisDir="/Volumes/PromisePegasus/_Service_/S003_20210924_Export-AraThal/221130_pool_FC1_FC2/final2_GC_and_length/HeatShockGC"

cd $AnalysisDir

for i in *.bed; do
  base=${i%.*}
  echo $base

  bedtools nuc -s -fi ~/Annotation/TAIR_10/genome.fa \
   -bed $i > "GC_content_"$base".tsv"

done
