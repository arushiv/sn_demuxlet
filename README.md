## NextFlow pipeline for RNA Demuxlet in demuxlet_rna; ATAC demuxlet in demuxlet_atac

The Demuxlet workflows take as input pruned bam files along with the QC metrics generated from the snRNA or snATAC workflows. Bam files are split into chunks of 1000 nuclei to expedite the Demuxlet run (can change this in the main.nf). Vcf files are prepped by selecting SNPs to be tested and samples to be kept. For RNA I've used gencode v19 gene introns+exons - ENCODE blacklist regions (this bed file is in the data folder). For ATAC I've used gencode introns+exons - ENCODE blacklist regions + ATAC-seq peaks in the bulk/previously available snATAC cell types from the tissue of interest. This might need to be updated according to your needs.  
1. Containers general and demuxlet carry the software to run different processes.
2. RNA Demuxlet requires pruned bam files and qc files from the [RNA workflow](https://github.com/porchard/snRNAseq-NextFlow)  as input. One way to do this is to provide the directory paths of the snRNA pruned bam directory and the list of library names so the workflow fetches bam files of the form `${pruned_bam_dir_path}/${library}-hg19.before-dedup.bam`.  
3. ATAC Demuxlet requires pruned bam files and qc files from the [ATAC workflow](https://github.com/porchard/snATACseq-NextFlow) as input. One way to do this is to provide the directory paths of the snATAC pruned bam directory and the list of library names so the workflow fetches bam files of the form `${params.pruned_bam_dir}/${library}-hg19.pruned.bam`.
4. Edit the `nextflow.config` that has the config parameters such as executor, container paths etc. to suit your system.
5. Update the `library-config.json` file with information about the individual libraries. 
6. `run.sh` includes an example run command.
