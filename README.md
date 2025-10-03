# Useful SLURM Scripts for Genomics
A small collection of reusable Bash scripts to simplify common tasks in genomics workflows, all designed for easy submission to SLURM.

## Count Reads in FASTQ Files

Count the number of sequencing reads in paired-end FASTQ files. 
```sh
./count_fastq_reads.sh -h

Usage: ./count_fastq_reads.sh -p FASTQ_DIR -e EXTENSION [-o OUTPUT_TSV]
  -p   Full path to directory containing *_1.$EXTENSION files
  -e   Fastq file extension: fastq, fastq.gz, or fq.gz
       (no leading dot)
  -o   (optional) Name of the output TSV [default: reads_counts.tsv]
```

Supports files ending in `*_1.fastq`, `*_1.fastq.gz`, or `*_1.fq.gz`.

Usage:

```sh
sbatch count_fastq_reads.sh -p /path/to/fastq -e fq.gz -o Your_Name_Counts.tsv
```

---

# Requirements

- **Bash** (>= 4.0)  
- **zcat** (for gzipped FASTQ)  
- **SLURM** (optional, for `sbatch` submissions)  

# Installation

```bash
git clone https://github.com/Ni-Ar/slurm_scripts.git
cd slurm_scripts
chmod +x count_fastq_reads.sh
```