#!/usr/bin/env bash

#SBATCH --job-name=CountFastqReads
#SBATCH --time=01:00:00       # adjust as needed
#SBATCH --qos=vshort          # adjust as needed
#SBATCH --mem=4G              # adjust if your files are huge
#SBATCH --cpus-per-task=1
#SBATCH --output=%x_%j.out    # %x = job-name, %j = job-id
#SBATCH --error=%x_%j.err

set -euo pipefail

########################
#  Usage & arguments   #
########################
usage() {
  cat <<EOF
Usage: $0 -p FASTQ_DIR -e EXTENSION [-o OUTPUT_TSV]
  -p   Full path to directory containing *_1.\$EXTENSION files
  -e   Fastq file extension: fastq, fastq.gz, or fq.gz
       (no leading dot)
  -o   (optional) Name of the output TSV [default: reads_counts.tsv]
EOF
  exit 1
}

FASTQ_DIR=""
FASTQ_EXT="" 
OUTPUT_FILE="reads_counts.tsv"  # default

while getopts ":p:e:o:" opt; do
  case $opt in
    p) FASTQ_DIR="$OPTARG" ;;
    e) FASTQ_EXT="${OPTARG#.}" ;;  # strip any leading dot
    o) OUTPUT_FILE="$OPTARG" ;;
    *) usage ;;
  esac
done

# check required args
if [[ -z "$FASTQ_DIR" || -z "$FASTQ_EXT" ]]; then
  echo "ERROR: -p and -e are required." >&2
  exit 1
fi

# validate that -e is one of the three allowed extensions
if [[ ! "$FASTQ_EXT" =~ ^(fastq|fastq\.gz|fq\.gz)$ ]]; then
  echo "ERROR: Unsupported extension '$FASTQ_EXT'."
  echo "Valid choices are: fastq, fastq.gz, fq.gz"
  exit 1
fi

# verify fastq dir
if [[ ! -d "$FASTQ_DIR" ]]; then
  echo "ERROR: directory '$FASTQ_DIR' not found." >&2
  exit 1
fi

# choose decompression
if [[ "$FASTQ_EXT" == *.gz ]]; then
  DECOMPRESS="zcat"
else
  DECOMPRESS="cat"
fi

# Record start time
start_time=$(date +%s)
echo "Job started at: $(date)"

echo "Counting reads in ${FASTQ_DIR} (*_1.${FASTQ_EXT}) -> ${OUTPUT_FILE}"
# initialize output (with header)
printf "sample\treads\n" > "$OUTPUT_FILE"

# loop through all *_1.$EXTENSION
shopt -s nullglob
for fq1 in "${FASTQ_DIR}"/*_1."$FASTQ_EXT"; do
  sample=$(basename "$fq1" "_1.${FASTQ_EXT}")
  total_lines=$($DECOMPRESS "$fq1" | wc -l)
  reads=$(( total_lines / 4 ))
  printf "%s\t%s\n" "$sample" "$reads" >> "$OUTPUT_FILE"
done

# Record end time
end_time=$(date +%s)
echo "Job finished at: $(date)"

# Compute elapsed time
elapsed=$(( end_time - start_time ))
days=$(( elapsed / 86400 ))
hours=$(( elapsed / 3600 ))
mins=$(( (elapsed % 3600) / 60 ))
secs=$(( elapsed % 60 ))

echo "Total elapsed time: ${days}d ${hours}h ${mins}m ${secs}s"
echo "Done. Results written to $(realpath "$OUTPUT_FILE")"