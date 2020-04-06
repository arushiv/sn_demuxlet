## NextFlow pipeline for RNA Demuxlet in demuxlet_rna; ATAC demuxlet in demuxlet_atac

1. Container general.simg or demuxlet1.sif carry the software to run different processes.
2. RNA Demuxlet requires pruned bam files and qc files from the [https://github.com/porchard/snRNAseq-NextFlow RNA workflow] as input. One way to do this is to provide the directory paths of the snRNA pruned bam directory and the list of library names so the workflow fetches bam files of the form "${pruned_bam_dir_path}/${library}-hg19.before-dedup.bam".  
3. ATAC Demuxlet requires pruned bam files and qc files from the [https://github.com/porchard/snATACseq-NextFlow ATAC workflow] as input. One way to do this is to provide the directory paths of the snATAC pruned bam directory and the list of library names so the workflow fetches bam files of the form "${params.pruned_bam_dir}/${library}-hg19.pruned.bam".
4. nextflow.config has the main config parameters usually same across runs such as executor, container paths etc. Edit these to suit your system.
5. Update paths in library-config.json file with information about the individual libraries. 
6. run.sh includes the run command.
