# RNAFLOW v0.2

## Highlights

* Integration of qcflow as external QC module
* Full FASTQ processing pipeline
* Automatic QC report generation (HTML + plots)
* Improved modular architecture

## Added

* qcflow integration step
* QC output structure
* report generation via Rscript
* configurable external script execution

## Improved

* pipeline robustness
* logging and execution flow
* disk-efficient processing

## Notes

This release marks the transition from a data acquisition pipeline to a functional RNA-seq preprocessing pipeline with integrated quality control.

## Dependencies

* qcflow >= v0.1-alpha
* SRA Toolkit
* pigz
* Rscript (optional)

## Next

* trimflow module
* alignment integration
* benchmarking

