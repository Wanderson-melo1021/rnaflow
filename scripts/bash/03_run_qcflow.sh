#!/usr/bin/env bash
set -euo pipefail

PREPARED_SAMPLESHEET="data/metadata/prepared_samplesheet.tsv"

FASTQ_SE_DIR="data/fastq/se"
FASTQ_PE_DIR="data/fastq/pe"
QC_OUT_DIR="results/qc/raw"

QCFLOW_BIN="${QCFLOW_BIN:-qcflow}"
QCFLOW_R_SCRIPT="${QCFLOW_R_SCRIPT:-/home/wanderson/qcflow/R/qc_prereport.R}"

mkdir -p "${QC_OUT_DIR}"

echo "[INFO] Starting qcflow integration"

{
    read -r header

    while IFS=$'\t' read -r sample condition replicate srr bioproject layout strand
    do
        echo "[INFO] Running QC for sample=${sample} layout=${layout}"

        out_prefix="${QC_OUT_DIR}/${sample}"

        if [[ -f "${out_prefix}_prereport.html" ]]; then
            echo "[INFO] QC already done for ${sample}, skipping"
            continue
        fi

        if [[ "${layout}" == "PE" ]]; then
            r1="${FASTQ_PE_DIR}/${sample}_R1.fastq.gz"
            r2="${FASTQ_PE_DIR}/${sample}_R2.fastq.gz"

            [[ -f "$r1" ]] || { echo "[ERROR] Missing R1 file: $r1"; exit 1; }
            [[ -f "$r2" ]] || { echo "[ERROR] Missing R2 file: $r2"; exit 1; }

            "${QCFLOW_BIN}" qc \
                --in1 "$r1" \
                --in2 "$r2" \
                --out "$out_prefix" \
                --report \
                --report-script "$QCFLOW_R_SCRIPT"

        elif [[ "${layout}" == "SE" ]]; then
            fq="${FASTQ_SE_DIR}/${sample}.fastq.gz"

            [[ -f "$fq" ]] || { echo "[ERROR] Missing SE file: $fq"; exit 1; }

            "${QCFLOW_BIN}" qc \
                --in "$fq" \
                --out "$out_prefix" \
                --report \
                --report-script "$QCFLOW_R_SCRIPT"
        else
            echo "[ERROR] Unknown layout '${layout}' for sample ${sample}"
            exit 1
        fi

        echo "[INFO] QC completed for ${sample}"
    done
} < "${PREPARED_SAMPLESHEET}"

echo "[INFO] qcflow integration finished"
