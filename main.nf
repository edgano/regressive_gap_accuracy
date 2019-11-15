




params.alignments = "${baseDir}/data/test/*.aln"
params.score = "${baseDir}/data/test/*.tc"
params.output = "${baseDir}/results/"


// Channels containing sequences
if ( params.alignments ) {
  Channel
  .fromPath(params.alignments)
  .map { item -> [ item.baseName, item] }
  .view()
  .set { aln }
}

// Channels containing sequences
if ( params.score ) {
  Channel
  .fromPath(params.score)
  .map { item -> [ item.baseName, item] }
  .view()
  .set { scoreCh }
}

process getAlnGaps {
    tag "${id}"
    publishDir "${params.output}/numberGaps", mode: 'copy', overwrite: true        //TODO diff folder for diff outChannel

    input:
      set val(id), file(aln) from aln

    output:
     set val(id), file("*.avgGap"), file("*.totGap") into gapsOut

    script:
    """
#!/usr/bin/env python

from Bio import SeqIO
from decimal import *
import os

gap = '-'
globalGap = 0
avgGap = 0
auxGap = 0

totGapName= "${id}.totGap"
avgGapName= "${id}.avgGap"
totGapFile= open(totGapName,"w+")
avgGapFile= open(avgGapName,"w+")

record = list(SeqIO.parse("${aln}", "fasta"))

for sequence in record:
    ## print(sequence.seq)
    auxGap = sequence.seq.count(gap)
    globalGap += auxGap

avgGap = Decimal(globalGap) / Decimal(len(record))
print "NumSeq: ",len(record)," GlobalGap: ",globalGap," AVG_Gap:",round(avgGap,3)

totGapFile.write(str(globalGap))
avgGapFile.write(str(round(avgGap,3)))

totGapFile.close()
avgGapFile.close()
    """
}
scoreCh
  .cross (gapsOut)
  .map { it -> [it[0][0], it[0][1], it[1][1], it[1][2]] }
  .set { score_gaps }

process relationScoreGap {
    tag "${id}"
    publishDir "${params.output}/tc_gap", mode: 'copy', overwrite: true        //TODO diff folder for diff outChannel

    input:
      set val(id), file(score), file(avgGap),file(totGap) from score_gaps

    output:
     set val(id), file("*.TcAvgReg"), file("*.TcTotReg") into regressionOut

    script:
    """
    echo "TC_Score - AVG_Gap" >> ${id}.TcAvgReg
    cat ${score} >> ${id}.TcAvgReg
    printf " - " >> ${id}.TcAvgReg 
    cat ${avgGap} >> ${id}.TcAvgReg 

    echo "TC_Score - TOT_Gap" >> ${id}.TcTotReg
    cat ${score} >> ${id}.TcTotReg
    printf " - " >> ${id}.TcTotReg 
    cat ${totGap} >> ${id}.TcTotReg 
    """
}