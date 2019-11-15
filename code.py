#!/usr/bin/env python

from Bio import SeqIO
from decimal import *
import os

gap = '-'
globalGap = 0
avgGap = 0
auxGap = 0

## get Filename
inputFile = "./data/test/seatoxin.dpa_1000.CLUSTALO.with.CLUSTALO.tree.aln"
base=os.path.basename(inputFile)
index_of_dot = base.index('.')
file_name_without_extension = base[:index_of_dot]
##

totGapName= file_name_without_extension+".totGap"
avgGapName= file_name_without_extension+".avgGap"
totGapFile= open(totGapName,"w+")
avgGapFile= open(avgGapName,"w+")

record = list(SeqIO.parse(inputFile, "fasta"))

for sequence in record:
    ## print(sequence.seq)
    auxGap = sequence.seq.count(gap)
    globalGap += auxGap

print(file_name_without_extension)
avgGap = Decimal(globalGap) / Decimal(len(record))
print "NumSeq: ",len(record),"\nGlobalGap: ",globalGap,"\nAVG_Gap:",round(avgGap,3)

totGapFile.write(str(globalGap))
avgGapFile.write(str(round(avgGap,3)))

totGapFile.close()
avgGapFile.close()