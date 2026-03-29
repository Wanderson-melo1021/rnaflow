# RNAFLOW

RNAFLOW is a modular RNA-seq pipeline designed with a strong focus on architectural clarity, reproducibility, and computational control.

Instead of relying primarily on high-level ecosystems, RNAFLOW explores a systems-oriented approach using lower-level languages such as C and Perl to orchestrate and process sequencing data.

---

## 🧠 Design Philosophy

RNAFLOW follows a strict separation of responsibilities:

* **C** → pipeline orchestration (core control layer)
* **Perl** → validation and metadata processing
* **Bash** → execution and file system operations
* **qcflow (C)** → FASTQ quality control
* **R (optional)** → QC report generation

---

## ⚙️ Features (v0.2)

* Structured samplesheet validation
* Automatic metadata integration (RunInfo parsing)
* SRA download (prefetch)
* FASTQ generation (fasterq-dump)
* Immediate compression (pigz)
* File integrity validation
* Sample-by-sample processing (disk-efficient)
* Integrated QC using **qcflow**
* Automatic QC report generation (HTML + plots)

---

## 📂 Project Structure

```text
rnaflow/
├── config/
├── data/
│   ├── fastq/
│   ├── metadata/
│   └── sra/
├── scripts/
│   ├── bash/
│   ├── perl/
│   └── c/
├── results/
│   └── qc/
└── Makefile
```

---

## 🔗 Dependencies

* qcflow (>= v0.1-alpha)
* perl
* bash
* SRA Toolkit (prefetch, fasterq-dump)
* pigz
* Rscript (optional, for reports)

Ensure `qcflow` is available in your `PATH`.

---

## 🚀 Usage

```bash
make run
```

Pipeline steps:

1. Validate samplesheet
2. Prepare metadata
3. Download sequencing data
4. Generate FASTQ files
5. Compress and validate outputs
6. Run QC (qcflow)
7. Generate reports

---

## 📊 Output

QC results:

```text
results/qc/raw/
```

Includes:

* summary statistics (`.summary.tsv`)
* per-base metrics
* length distribution
* PNG plots
* HTML reports

---

## 🧩 Architecture

RNAFLOW acts as an orchestration layer for modular tools:

* qcflow → quality control
* trimflow (planned) → trimming
* alignment modules (planned)

---

## 📌 Status

Current version: **v0.2**

---

## 🔮 Roadmap

* Trimflow integration (C-based trimming)
* Alignment module
* Quantification
* Benchmarking against standard pipelines
* Full reproducibility layer

---

## 🤝 Motivation

This project investigates whether modern RNA-seq pipelines can be implemented with high performance and structural clarity while minimizing dependence on high-level default ecosystems.

