#!/usr/bin/env nextflow


params.alignments = "${baseDir}/data/test/seatoxin.*.tree.aln"
params.score = "${baseDir}/data/test/seatoxin.*.tc"
params.output = "${baseDir}/results/"

// Channels containing the genome Fasta file
if ( params.alignments ) {
  Channel
  .fromPath(params.alignments)
  .map { item -> [ item.baseName, item] }
  .set { alignments }
}

// Channels containing the genome Fasta file
if ( params.score ) {
  Channel
  .fromPath(params.score)
  .map { item -> [ item.baseName, item] }
  .view()
  .set { score }
}

process countGaps{
    tag "${id}"
    publishDir "${params.output}/gapsNumber", mode: 'copy', overwrite: true

    input:
      set val(id), file(seqs) from alignments

    output:
      val(id) into gaps

    script:
    """
    g++ ${baseDir}/script.cpp
    ${baseDir}/a.out ${seqs}
    """
}