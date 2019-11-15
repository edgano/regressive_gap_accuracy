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