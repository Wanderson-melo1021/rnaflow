#!/usr/bin/env bash
set -euo pipefail

PREPARED_SAMPLESHEET="data/metadata/prepared_samplesheet.tsv"

SRA_DIR="data/sra/raw_accessions"
FASTQ_SE_DIR="data/fastq/se"
FASTQ_PE_DIR="data/fastq/pe"
TMP_DIR="data/tmp"

mkdir -p "${SRA_DIR}" "${FASTQ_SE_DIR}" "${FASTQ_PE_DIR}" "${TMP_DIR}"

validate_fastq_gz() {
    local fq="$1"

    [[ -f "$fq" ]] || {
        echo "[ERROR] Missing file: $fq"
        return 1
    }

    [[ -s "$fq" ]] || {
        echo "[ERROR] Empty file: $fq"
        return 1
    }

    pigz -t "$fq" || {
        echo "[ERROR] Corrupted gzip: $fq"
        return 1
    }

    zcat "$fq" | awk 'END { if (NR % 4 != 0) exit 1 }' || {
        echo "[ERROR] Invalid FASTQ structure (line count not multiple of 4): $fq"
        return 1
    }

    return 0
}

count_reads_fastq_gz() {
    local fq="$1"
    zcat "$fq" | awk 'END { print NR / 4 }'
}

echo "[INFO] Starting data acquisition"

{
    read -r header

    while IFS=$'\t' read -r sample condition replicate srr bioproject layout strand
    do
        echo "[INFO] Processing sample=${sample} srr=${srr} layout=${layout}"

        rm -rf "${TMP_DIR:?}"/*
        mkdir -p "${TMP_DIR}"

        if [[ "${layout}" == "PE" ]]; then
            r1_gz="${FASTQ_PE_DIR}/${sample}_R1.fastq.gz"
            r2_gz="${FASTQ_PE_DIR}/${sample}_R2.fastq.gz"

            if [[ -f "$r1_gz" && -f "$r2_gz" ]]; then
                echo "[INFO] Existing paired FASTQ detected for ${sample}. Validating before skip."

                validate_fastq_gz "$r1_gz"
                validate_fastq_gz "$r2_gz"

                r1_reads=$(count_reads_fastq_gz "$r1_gz")
                r2_reads=$(count_reads_fastq_gz "$r2_gz")

                [[ "$r1_reads" -eq "$r2_reads" ]] || {
                    echo "[ERROR] Existing paired FASTQ files have mismatched read counts for ${sample}: R1=${r1_reads}, R2=${r2_reads}"
                    exit 1
                }

                echo "[INFO] Existing paired FASTQ valid for ${sample}, skipping"
                continue
            fi

            if [[ -f "$r1_gz" || -f "$r2_gz" ]]; then
                echo "[WARNING] Partial paired output detected for ${sample}. Removing incomplete files before reprocessing."
                rm -f "$r1_gz" "$r2_gz"
            fi

        elif [[ "${layout}" == "SE" ]]; then
            se_gz="${FASTQ_SE_DIR}/${sample}.fastq.gz"

            if [[ -f "$se_gz" ]]; then
                echo "[INFO] Existing single-end FASTQ detected for ${sample}. Validating before skip."

                validate_fastq_gz "$se_gz"

                echo "[INFO] Existing single-end FASTQ valid for ${sample}, skipping"
                continue
            fi
        else
            echo "[ERROR] Unknown layout '${layout}' for ${sample}"
            exit 1
        fi

        if [[ ! -f "${SRA_DIR}/${srr}/${srr}.sra" ]]; then
            echo "[INFO] Running prefetch for ${srr}"
            prefetch "${srr}" --output-directory "${SRA_DIR}"
        else
            echo "[INFO] SRA already present for ${srr}, skipping prefetch"
        fi

        if [[ "${layout}" == "PE" ]]; then
            echo "[INFO] Running fasterq-dump for paired-end sample ${sample}"
            fasterq-dump "${SRA_DIR}/${srr}" \
                --split-files \
                --threads 4 \
                --temp "${TMP_DIR}" \
                -O "${FASTQ_PE_DIR}"

            if [[ -f "${FASTQ_PE_DIR}/${srr}_1.fastq" && -f "${FASTQ_PE_DIR}/${srr}_2.fastq" ]]; then
                mv "${FASTQ_PE_DIR}/${srr}_1.fastq" "${FASTQ_PE_DIR}/${sample}_R1.fastq"
                mv "${FASTQ_PE_DIR}/${srr}_2.fastq" "${FASTQ_PE_DIR}/${sample}_R2.fastq"

                echo "[INFO] Compressing R1"
                pigz -p 4 "${FASTQ_PE_DIR}/${sample}_R1.fastq"

                echo "[INFO] Compressing R2"
                pigz -p 4 "${FASTQ_PE_DIR}/${sample}_R2.fastq"

                r1_gz="${FASTQ_PE_DIR}/${sample}_R1.fastq.gz"
                r2_gz="${FASTQ_PE_DIR}/${sample}_R2.fastq.gz"

                echo "[INFO] Validating compressed FASTQ files"
                validate_fastq_gz "$r1_gz"
                validate_fastq_gz "$r2_gz"

                r1_reads=$(count_reads_fastq_gz "$r1_gz")
                r2_reads=$(count_reads_fastq_gz "$r2_gz")

                [[ "$r1_reads" -eq "$r2_reads" ]] || {
                    echo "[ERROR] Paired FASTQ files have mismatched read counts for ${sample}: R1=${r1_reads}, R2=${r2_reads}"
                    exit 1
                }

                echo "[INFO] Validation OK for ${sample}"

                echo "[INFO] Removing local SRA files for ${srr}"
                rm -rf "${SRA_DIR:?}/${srr}"

                echo "[INFO] Sample ${sample} completed successfully"
            else
                echo "[ERROR] Expected paired FASTQ files were not generated for ${srr}"
                exit 1
            fi

        elif [[ "${layout}" == "SE" ]]; then
            echo "[INFO] Running fasterq-dump for single-end sample ${sample}"
            fasterq-dump "${SRA_DIR}/${srr}" \
                --threads 4 \
                --temp "${TMP_DIR}" \
                -O "${FASTQ_SE_DIR}"

            if [[ -f "${FASTQ_SE_DIR}/${srr}.fastq" ]]; then
                mv "${FASTQ_SE_DIR}/${srr}.fastq" "${FASTQ_SE_DIR}/${sample}.fastq"

                echo "[INFO] Compressing FASTQ"
                pigz -p 4 "${FASTQ_SE_DIR}/${sample}.fastq"

                se_gz="${FASTQ_SE_DIR}/${sample}.fastq.gz"

                echo "[INFO] Validating compressed FASTQ file"
                validate_fastq_gz "$se_gz"

                echo "[INFO] Validation OK for ${sample}"

                echo "[INFO] Removing local SRA files for ${srr}"
                rm -rf "${SRA_DIR:?}/${srr}"

                echo "[INFO] Sample ${sample} completed successfully"
            else
                echo "[ERROR] Expected single-end FASTQ file was not generated for ${srr}"
                exit 1
            fi
        fi

        rm -rf "${TMP_DIR:?}"/*
        mkdir -p "${TMP_DIR}"
    done
} < "${PREPARED_SAMPLESHEET}"

echo "[INFO] Data acquisition finished"
