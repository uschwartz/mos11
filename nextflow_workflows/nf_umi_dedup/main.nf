#!/usr/bin/env nextflow
nextflow.enable.dsl = 2

Channel.fromPath("${params.bamPath}/${params.exprName}").
        map{ file -> tuple(file.simpleName, file)}.set{bam_files}

Channel.fromPath("${params.bamPath}/${params.exprIdxName}").
        map{ file -> tuple(file.simpleName, file)}.set{bam_idx_files}

process idx{
        input:
        tuple val(nameID),file(bam)

        output:
        tuple val(nameID),file(bam),file("*.bai")

        script:
        """
        samtools index $bam
        """

}



process UMI_dedup{
        memory '30 GB'
        container 'fredhutch/umi_tools:1.0.1'
        publishDir "${params.outPath}/UMI/bam", mode: 'copy', pattern: "*.bam"
        publishDir "${params.outPath}/UMI/", mode: 'copy', pattern: "**.tsv"

        input:
        tuple val(nameID),path(bam), path(bamIdx)

        output:
        file("*.bam")
        file("**.tsv")

        script:
        """
        mkdir stats
        umi_tools dedup  -I $bam \
        --output-stats="stats/"$nameID"_deduplicated" \
         -S $nameID"_umi.bam"
        """
}


process preDeDup_stats{
        publishDir "${params.outPath}/UMI/dedup_Stats", mode: 'copy'

        input:
        tuple val(nameID),path(bam), path(bamIdx)

        output:
        file("preDeDup_*.txt")

        script:
        """
        samtools view -c $bam >"preDeDup_"$nameID".txt"
        """
}

process postDeDup_stats{
        publishDir "${params.outPath}/UMI/dedup_Stats", mode: 'copy'

        input:
        tuple val(nameID),file(bam)

        output:
        file("postDeDup_*.txt")

        script:
        """
        samtools view -c $bam >"postDeDup_"$nameID".txt"
        """
}

process dupRadar{
        publishDir "${params.outPath}/UMI/dupRadar/${nameID}", mode: 'copy'

	input:
	tuple val(nameID),file(bam)


	output:
        file "*{pdf,txt}"


        script:

	"""
        dupRadar_script.R $bam "/Users/admin/Annotation/TAIR_10/nextflow/protein_coding.gtf" 1 FALSE
	"""
}

process chrStats{
        publishDir "${params.outPath}/UMI/chrStats/", mode: 'copy'

	input:
	tuple val(nameID),file(bam)


	output:
        file "*.txt"


        script:

	"""
        samtools index $bam
        samtools idxstats $bam >$nameID'.txt'

	"""
}


process countReads{
        publishDir "${params.outPath}/UMI/counts/", mode: 'copy'

	input:
	file(bams)


	output:
        file "*.txt*"


        script:
	"""
        featureCounts -T 10 -s 1  \
        -a /Users/admin/Annotation/TAIR_10/nextflow/protein_coding_and_lincRNA.gtf \
        -o count_table.txt $bams &>count_info.txt

	"""
}

process multiQC{
        publishDir "${params.outPath}/UMI/countsQC/", mode: 'copy'

	input:
	file ('featureCounts/*')


        output:
	file "*multiqc_report.html"
        file "*_data"


        script:
	"""
        multiqc .

	"""
}

workflow{
        idx(bam_files)
        UMI_dedup(idx.out)
        preDeDup_stats(idx.out)
        UMI_dedup.out[0].map{ file -> tuple(file.simpleName, file)}.set{UMI_out}
        postDeDup_stats(UMI_out)
        dupRadar(UMI_out)
        chrStats(UMI_out)
        countReads(UMI_dedup.out[0].collect())
        multiQC(countReads.out.collect().ifEmpty([]))
}
