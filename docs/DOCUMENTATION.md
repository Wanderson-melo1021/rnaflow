# RNAFLOW Documentation

## 1. Overview

RNAFLOW is a modular RNA-seq pipeline designed for reproducible and efficient data processing, using a systems-level architecture.

The pipeline integrates external tools and custom modules while maintaining strict control over execution flow.

---

## 2. Pipeline Workflow

### Step 1 — Validation

* Language: Perl
* Script: `00_validate_samplesheet.pl`
* Ensures schema correctness and input integrity

### Step 2 — Metadata Preparation

* Language: Perl
* Script: `01_prepare_run_table.pl`
* Integrates RunInfo metadata
* Determines layout (SE/PE)

### Step 3 — Data Acquisition

* Language: Bash
* Tools:

  * prefetch
  * fasterq-dump
  * pigz
* Features:

  * sample-by-sample processing
  * immediate compression
  * temporary directory cleanup

### Step 4 — Quality Control (qcflow)

* Language: C
* External module
* Capabilities:

  * FASTQ / FASTQ.GZ parsing
  * SE and PE support
  * per-base metrics
  * GC and N content
  * length distribution

### Step 5 — Reporting

* Language: R
* Triggered via:

  * `--report --report-script`
* Generates:

  * plots (PNG)
  * HTML report

---

## 3. Data Flow

```text
samplesheet.tsv
   ↓
validation (Perl)
   ↓
metadata integration
   ↓
SRA download
   ↓
FASTQ generation
   ↓
compression (pigz)
   ↓
QC (qcflow)
   ↓
report (R)
```

---

## 4. File Formats

### Input

* TSV (samplesheet)
* SRA

### Intermediate

* FASTQ
* FASTQ.GZ

### Output

* TSV (metrics)
* PNG (plots)
* HTML (report)

---

## 5. Error Handling

RNAFLOW enforces strict failure conditions:

* missing files → pipeline stops
* corrupted gzip → pipeline stops
* invalid schema → pipeline stops
* QC failure → pipeline stops

---

## 6. Design Principles

* modularity
* reproducibility
* minimal hidden state
* explicit dependencies
* language specialization per task

---

## 7. Integration Model

RNAFLOW does not embed modules internally.

Instead, it integrates external tools via:

* PATH resolution
* CLI arguments
* environment variables

Example:

```bash
QCFLOW_BIN=/path/to/qcflow
QCFLOW_R_SCRIPT=/path/to/script.R
```

---

## 8. Future Modules

### trimflow

* quality trimming
* adapter trimming
* PE synchronization

### alignment

* STAR / HISAT2 integration

### quantification

* featureCounts / HTSeq

---

## 9. Versioning

* v0.1 → acquisition only
* v0.2 → acquisition + QC integration
* future → trimming + alignment

---

## 10. Notes

RNAFLOW is intended both as:

* a functional pipeline
* a systems-level experiment in bioinformatics architecture

