process RENAME {
    tag "$meta.id"
    label 'process_low'

    conda "${moduleDir}/environment.yml"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/fastx_toolkit:0.0.13--0':
        'biocontainers/fastx_toolkit:0.0.13--0' }"

    input:
    tuple val(meta), path(reads)
    val options

    output:
    tuple val(meta), path("*.fastq.gz"), emit: renamed
    path "versions.yml"                , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"

    if (options.single_end) {
        """
        zcat ${reads[0]} | fastx_renamer -z -n COUNT -o ${meta.id}_renamed.fastq.gz
        """
    }
    else {
        """
        zcat ${reads[0]} | fastx_renamer -z -n COUNT -o ${meta.id}_R1_renamed.fastq.gz
        zcat ${reads[1]} | fastx_renamer -z -n COUNT -o ${meta.id}_R2_renamed.fastq.gz


    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        rename: \$(samtools --version |& sed '1!d ; s/samtools //')
    END_VERSIONS
    """
    }
}
