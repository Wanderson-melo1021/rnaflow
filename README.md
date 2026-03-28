# rnaflow

## Overview

rnaflow is a modular RNA-seq workflow designed for datasets associated with public SRA run accessions. The project implements a structured pipeline that begins from a tabular samplesheet, validates metadata, prepares execution logic, retrieves sequencing data, and performs downstream RNA-seq processing.

The orchestration layer is implemented in C, providing strict control over execution flow, error handling, and logging. Bash is used as a minimal launcher, while Perl is employed for metadata validation and preparation. Downstream analytical steps will be integrated using standard bioinformatics tools, along with Python and R for statistical analysis and reporting.

This workflow is explicitly designed around alignment-based RNA-seq analysis and does not rely on pseudoalignment strategies.

---

## Objectives

- Build a reproducible RNA-seq pipeline starting from SRR accessions
- Implement a structured orchestration layer using C
- Enforce strict metadata validation and preparation
- Support both single-end (SE) and paired-end (PE) sequencing data
- Integrate modular components for QC, alignment, quantification, and analysis
- Maintain a lightweight design suitable for limited computational environments

---

## Architecture

The pipeline is organized into distinct functional layers:

- **Bash**  
  Thin entry point used only to launch the pipeline

- **C (core orchestrator)**  
  Controls execution flow, checks dependencies, calls modules, and handles errors

- **Perl**  
  Performs metadata validation and preparation

- **Python / R (planned)**  
  Will handle downstream statistical analysis and reporting

- **External tools**  
  SRA Toolkit and, later, QC, alignment, and quantification software

- pigz

- curl
---

## Pipeline Design

The workflow follows a staged structure:

00_input_validation  
01_fetch_project_metadata  
02_metadata_preparation  
03_data_acquisition  
04_fastq_inspection (planned)  
05_qc_and_trimming (planned)  
06_alignment (planned)  
07_quantification (planned)  
08_statistical_analysis (planned)  
09_reporting (planned)

---

## Current implementation includes:

- Input validation
- C-based orchestration
- Project structure and build system

---

## Project Structure

```
.
├── config
│   └── samplesheet.tsv
├── data
│   ├── fastq
│   │   ├── pe
│   │   └── se
│   │       ├── SRR390728_1.fastq.gz
│   │       └── SRR390728_2.fastq.gz
│   ├── metadata
│   │   └── prepared_samplesheet.tsv
│   ├── processed
│   ├── reference
│   └── sra
│       └── raw_accessions
│           └── SRR390728
├── docs
├── Makefile
├── README.md
├── results
│   ├── alignments
│   ├── counts
│   ├── logs
│   │   └── pipeline.log
│   ├── plots
│   ├── qc
│   ├── reports
│   └── trimmed
└── scripts
    ├── bash
    │   └── run_pipeline.sh
    ├── c
    │   ├── bin
    │   ├── include
    │   │   ├── logger.h
    │   │   └── utils.h
    │   └── src
    │       ├── logger.c
    │       ├── main.c
    │       └── utils.c
    ├── perl
    │   ├── 00_validate_samplesheet.pl
    │   └── 01_prepare_run_table.pl
    ├── python
    └── r
```

---

## Input format

The pipeline expects a tab-separated file:

config/samplesheet.tsv

Required columns:

sample_id	condition	replicate	srr	bioproject	strandedness

Example:

sample_id	condition	replicate	srr	bioproject	strandedness
GSM8014143	control	1	SRR27532983	PRJNA1064040	unstranded
GSM8014142	control	2	SRR27532984	PRJNA1064040	unstranded
GSM8014141	treated	1	SRR27532985	PRJNA1064040	unstranded
GSM8014140	treated	2	SRR27532986	PRJNA1064040	unstranded

---

## Metadata Preparation

The pipeline automatically retrieves metadata from the NCBI SRA using the BioProject accession provided in the input samplesheet.

The downloaded RunInfo file is used to determine sequencing layout:

- PAIRED → PE
- SINGLE → SE

This information is merged with the user-provided samplesheet to generate:

data/metadata/prepared_samplesheet.tsv

This approach ensures that execution metadata is derived from authoritative sources rather than inferred heuristically.

---

## FASTQ Inspection (Planned)

A custom inspection module will evaluate raw FASTQ files before downstream QC tools. The following metrics will be computed:

- total number of reads
- read length distribution
- mean read length
- number of reads containing ambiguous bases (N)
- approximate GC content
- consistency between sequence and quality string lengths

---

## Requirements

- GCC (C compiler)
- Make
- Perl
- Bash
- SRA Toolkit (`prefetch`, `fasterq-dump`)
- pigz
- curl

Future modules will require:

- FastQC
- alignment software (e.g., HISAT2)
- feature counting tools
- R and Python environments

---

## Build and Execution

Compile the pipeline:

```bash
make
```

Compile and run:

```bash
make run
```

Clean compiled binaries:

```bash
make clean
```

Alternatively, run via Bash launcher:

> ./scripts/bash/run_pipeline.sh

---

## Current Status

Implemented:

- project structure
- Makefile build system
- C-based orchestrator
- Perl-based validation and metadata parsing
- automatic download of BioProject metadata
- SE/PE detection from RunInfo
- data acquisition with SRA Toolkit
- immediate FASTQ compression with pigz
- conditional cleanup of SRA files

In progress:

- FASTQ inspection module
- QC and trimming integration

---

## Design Principles

strict separation between input and derived metadata
modular pipeline structure
early validation and failure handling
reproducibility and traceability
minimal reliance on hidden automation
explicit control of workflow execution

---

## Data Acquisition

Sequencing data are retrieved using the SRA Toolkit:

- `prefetch` downloads SRA accessions
- `fasterq-dump` converts them to FASTQ format

FASTQ files are processed sample-by-sample to control disk usage.

Immediately after conversion:

- files are compressed using `pigz`
- compressed FASTQ files are minimally validated
- SRA files are removed only after successful validation

This strategy reduces disk usage and prevents data loss due to premature cleanup.

---


## Future Improvements

automatic SE/PE detection from SRA metadata
structured logging to file
parallel execution support
integration with alignment and quantification tools
automated report generation
full reproducibility through configuration files

---

## Design Considerations

- metadata are retrieved automatically from public repositories
- disk usage is controlled through immediate compression and cleanup
- pipeline execution is strictly validated at each step
- modular architecture allows independent extension of each stage

---
