

params.alignments = "${baseDir}/data/test/*.aln"
params.score = "${baseDir}/data/test/*.tc"
params.output = "${baseDir}/results/"


// Channels containing sequences
if ( params.alignments ) {
  Channel
  .fromPath(params.alignments)
  .map { item -> [ item.baseName, item] }
  //.view()
  .set { aln }
}

// Channels containing sequences
if ( params.score ) {
  Channel
  .fromPath(params.score)
  .map { item -> [ item.baseName, item] }
  //.view()
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
     set val(id), file("*.TcAvgReg"), file("*.TcTotReg"), file("merge.txt") into regressionOut
     set val(id), file("merge.txt") into combineOut

    script:
      """
      ## echo ${id} val(aligner), val(tree), val(score), val(totGap), val(avgGap)
      IFS='.'
      read -ra ADDR <<< "${id}"       # str is read into an array as tokens separated by IFS
      for i in "\${ADDR[@]}"; do      # access each element of array
        echo "\$i"
      done

      family=\${ADDR[0]}
      aligner=\${ADDR[2]}
      tree=\${ADDR[4]}

      ###                                   ###
      ## save the data in the correct format ##
      ###                                   ###
      # echo "\$family - \$aligner - \$tree"
      printf "%s " "\$family \$aligner \$tree " >> merge.txt
      cat ${score} >> merge.txt
      printf " " >> merge.txt
      cat ${totGap} >> merge.txt
      printf " " >> merge.txt
      cat ${avgGap} >> merge.txt
      printf "" >> merge.txt

      ## save the data in individual files
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

combineOut
  .collectFile(name:'result.txt', newLine: true, storeDir:'/home/edgar/CBCRG/regressive_gap_accuracy/test')
  { value,file -> file }
  .println{ it.text }
