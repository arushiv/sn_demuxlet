## NextFlow pipeline for RNA Demuxlet in demuxlet_rna; ATAC demuxlet in demuxlet_atac

1. Container general.simg or demuxlet1.sif carry the software to run different processes.
2. RNA Demuxlet requires pruned bam files and qc files from the RNA workflow as input.
3. ATAC Demuxlet requires pruned bam files and qc files from the ATAC workflow as input.
4. nextflow.config has the main config parameters usually same across runs such as executor, container paths etc.
5. Update paths in library-config.json file with information about the individual libraries. 
6. run.sh includes the run command.
