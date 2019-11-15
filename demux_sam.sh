#!/bin/bash


samtools sort -@ 30 -n -o ./HMV35AFXY_sort.bam /gpfs/HOME/apop/raw_data_demux/HMV35AFXY_1_20190701B_20190702.bam

# Указываем индексы (I501 значит index 501. 

I502="GCCTCTAT"
I503="AGGATAGG"
I701="ATTACTCG"
I702="TCCGGAGA"
I703="CGCTCATT"

INFILE="HMV35AFXY_sort.bam"
# Сортированый файл прогоняем через grep
# Получаем 3 файла демультиплексированных, в которых оба рида
samtools view $INFILE | grep -A 1 -E "B2:Z:.*$I502.*BC:Z:.*$I702|B2:Z:.*$I702.*BC:Z:.*$I502" > L5.sam
samtools view $INFILE | grep -A 1 -E "B2:Z:.*$I502.*BC:Z:.*$I703|B2:Z:.*$I703.*BC:Z:.*$I502" > L6.sam
samtools view $INFILE | grep -A 1 -E "B2:Z:.*$I503.*BC:Z:.*$I701|B2:Z:.*$I701.*BC:Z:.*$I503" > L7.sam

# Получаем файл только с 1-ым ридом, в котором есть тэги. Так можно посмотреть на кривые индексы. Для дебагинга.
# samtools view $INFILE | grep -v -E "B2:Z:.*$I502.*BC:Z:.*$I702|B2:Z:.*$I702.*BC:Z:.*$I502|B2:Z:.*$I502.*BC:Z:.*$I703|B2:Z:.*$I703.*BC:Z:.*$I502|B2:Z:.*$I503.*BC:Z:.*$I701|B2:Z:.*$I701.*BC:Z:.*$I503"  | grep "BC:Z" > negative.sam

# grep вставляет символы -- в файлы, что мешает конвертации в bam
# Это решается удалением строчек, у которых в начале -- и больше ничего
sed '/^--/ d' L5.sam > L5_fixed.sam
sed '/^--/ d' L6.sam > L6_fixed.sam
sed '/^--/ d' L7.sam > L7_fixed.sam
sed '/^--/ d' negative.sam > negative_fixed.sam

#rm L1.sam L2.sam L4.sam

samtools view -@ 30 -Sb  L5_fixed.sam  >  L5.bam
samtools view -@ 30 -Sb  L6_fixed.sam  >  L6.bam
samtools view -@ 30 -Sb  L7_fixed.sam  >  L7.bam
samtools view -@ 30 -Sb  negative_fixed.sam  >  negative.bam

#rm L1_fixed.sam L2_fixed.sam L4_fixed.sam

samtools sort -@ 30 -n -o L5_sort.bam  L5.bam
samtools sort -@ 30 -n -o L6_sort.bam  L6.bam
samtools sort -@ 30 -n -o L7_sort.bam  L7.bam

samtools fastq -n -t -i -@ 16 --barcode-tag BC -T B2,Q2 -c 9 -1 L5_R1.fastq.gz -2 L5_R2.fastq.gz L5_sort.bam
samtools fastq -n -t -i -@ 16 --barcode-tag BC -T B2,Q2 -c 9 -1 L6_R1.fastq.gz -2 L6_R2.fastq.gz L6_sort.bam
samtools fastq -n -t -i -@ 16 --barcode-tag BC -T B2,Q2 -c 9 -1 L7_R1.fastq.gz -2 L7_R2.fastq.gz L7_sort.bam
