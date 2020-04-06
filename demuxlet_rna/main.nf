
libraries = params.libraries

bams = []
qc = []
for (library in libraries) {
    bam = file("${params.pruned_bam_dir}/${library}-hg19.before-dedup.bam", checkIfExists: true)
	index = file("${params.pruned_bam_dir}/${library}-hg19.before-dedup.bam.bai", checkIfExists: true)
	qcfile = file("${params.qc_dir}/${library}-hg19.txt", checkIfExists: true)
	bams << [library, bam, index]
	qc << [library, qcfile]
}

// From RNA QC, select nuclei somewhat leniently to reduce the bam file size
// Then Prep bam to run demuxlet and further select singlets.


process select_nuclei {
	/* Removing completely junk nuclei here with min total reads or min UMIs helps reduce the bam
	 file size for further steps because demuxlet is very slow with large bam files
	 Also split selected nuclei for each library further into chunks of 2500/5000 nuclei with roughly same number of reads */
	publishDir "results/selected_nuclei"
	container params.general_container
	
	input:
	set val(library), path(qcfile) from Channel.fromList(qc)

	output:
	set val(library), path("${library}.selected_barcodes_*") into select_nuclei_out

	"""
    split_droplets.py --qc $qcfile --umi-threshold ${params.umi_threshold}  --mitochondrial-fraction 0.1 --nbarcodes 1000 --out-prefix ${library}.selected_barcodes
    """
}

bamc = Channel.fromList(bams)
filter_bam_in = select_nuclei_out.transpose().map{it -> [it[0], it[1].name.replaceFirst(~/$/, ''), it[1] ]}.combine(bams, by: 0)


process filter_bam {
	/* Removing completely junk nuclei here with min total reads or min UMIs helps reduce the bam
	 file size for further steps 
	 This process though seems to not take much memory while running, looks like it writes bam at once. 
	 So that's when it needs more memory */
	publishDir "${params.results}/filter-bam"
	errorStrategy 'retry'
	maxRetries 2
	cpus 10
	time { 10.hour * task.attempt }
	memory { 8.GB * task.attempt }
	container params.general_container
	
	input:
	set val(library), val(library_nuclei), path(selected_nuclei), path(bam), path(bamindex) from filter_bam_in

	output:
	set val(library_nuclei), path("${library_nuclei}.filtered.bam"), path("${library_nuclei}.filtered.bam.bai") into filter_bam_out

	"""
    subset-bam --bam $bam --bam-tag CB --cell-barcodes ${selected_nuclei} \
     --cores 10 --log-level info --out-bam ${library_nuclei}.filtered.bam;
    samtools index ${library_nuclei}.filtered.bam
    """
}

filter_bam_out.into { demuxlet_batch_in; demuxlet_full_in }

process prep_vcf {
	/*For RNA, select vcf to contain gencode basic transcripts (intron + exon),
	 blacklist regions removed, MAF 5% in the samples of the respective batch. */
	publishDir "${params.results}/vcf"
	container params.general_container
	
	input:
	path(full_vcf) from Channel.fromPath(params.full_vcf)
	path(selected_regions) from Channel.fromPath(params.selected_regions)
	path(sample_list) from Channel.fromPath(params.sample_list)

	output:
	path("genotypes.maf05.selected_regions.batch.recode.vcf") into prep_vcf_out

	"""
    vcftools --gzvcf ${full_vcf} --maf 0.05 --bed ${selected_regions} --keep ${sample_list} --recode --out genotypes.maf05.selected_regions.batch  
    """

}

process demuxlet_batch {
	/* Run Demuxlet using GT filed and supplying the UMI tag and droplet barcode tag*/
	errorStrategy 'retry'
	maxRetries 2
	time { 36.hour * task.attempt }
	memory { 8.GB * task.attempt }
	publishDir "${params.results}/demuxlet"
	container params.demuxlet_container
	
	input:
	set val(library_nuclei), path(bam), path(bam_index), path(vcf) from demuxlet_batch_in.combine(prep_vcf_out)
	
	output:
	path("${library_nuclei}.batch.best") into demuxlet_out
	set val(library_nuclei), path("${library_nuclei}.batch.single"), path("${library_nuclei}.batch.sing2") into demuxlet_out_others

	"""
    demuxlet --sam $bam --tag-group CB  --tag-UMI UB --vcf ${vcf} --field GT --out ${library_nuclei}.batch 
    """

}


workflow.onComplete {
    if (workflow.success){
        subject = "Demuxlet execution complete"
    }
    else {
        subject = "Demuxlet execution error"
    }

    recipient = params.email

    ['mail', '-s', subject, recipient].execute() << """

    Pipeline execution summary
    ---------------------------
    Completed at: ${workflow.complete}
    Duration    : ${workflow.duration}
    Success     : ${workflow.success}
    workDir     : ${workflow.workDir}
    exit status : ${workflow.exitStatus}
    Error report: ${workflow.errorReport ?: '-'}
    """
}

