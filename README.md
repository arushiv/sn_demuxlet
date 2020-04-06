## NextFlow pipeline for RNA Demuxlet in demuxlet_rna; ATAC demuxlet in demuxlet_atac

The Demuxlet workflows take as input pruned bam files from the snRNA or snATAC workflows, along with QC metrics. Bam files are split into chunks of 1000 nuclei to expedite the Demuxlet run (can change this in the main.nf). Vcf files are prepped by selecting SNPs to be tested and samples to be kept. This might need to be updated according to your needs.  
1. Containers general and demuxlet carry the software to run different processes.
2. RNA Demuxlet requires pruned bam files and qc files from the [RNA workflow](https://github.com/porchard/snRNAseq-NextFlow)  as input. One way to do this is to provide the directory paths of the snRNA pruned bam directory and the list of library names so the workflow fetches bam files of the form "${pruned_bam_dir_path}/${library}-hg19.before-dedup.bam".  
3. ATAC Demuxlet requires pruned bam files and qc files from the [ATAC workflow](https://github.com/porchard/snATACseq-NextFlow) as input. One way to do this is to provide the directory paths of the snATAC pruned bam directory and the list of library names so the workflow fetches bam files of the form "${params.pruned_bam_dir}/${library}-hg19.pruned.bam".
4. nextflow.config has the main config parameters that are usually same across runs such as executor, container paths etc. Edit these to suit your system.
5. Update paths in library-config.json file with information about the individual libraries. 
6. run.sh includes the run command.
