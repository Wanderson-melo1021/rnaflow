#include "logger.h"
#include "utils.h"

int main(void) {

    log_message("Starting rnaflow pipeline");

    log_message("Checking required tools");

    if (check_command("command -v perl >/dev/null 2>&1", "ERROR: perl not found")) return 1;
    if (check_command("command -v prefetch >/dev/null 2>&1", "ERROR: prefetch not found")) return 1;
    if (check_command("command -v fasterq-dump >/dev/null 2>&1", "ERROR: fasterq-dump not found")) return 1;
    if (check_command("command -v pigz >/dev/null 2>&1", "ERROR: pigz not found")) return 1;
    if (check_command("command -v zcat >/dev/null 2>&1", "ERROR: zcat not found")) return 1;

    log_message("Validating input samplesheet");

    if (run_command(
        "perl scripts/perl/00_validate_samplesheet.pl config/samplesheet.tsv",
        "ERROR: samplesheet validation failed"
    )) return 1;

    log_message("Preparing metadata (SE/PE detection)");

    if (run_command(
        "perl scripts/perl/01_prepare_run_table.pl config/samplesheet.tsv data/metadata/prjna1064040_runinfo.csv data/metadata/prepared_samplesheet.tsv",
        "ERROR: metadata preparation failed."
    )) return 1;

    log_message("Running data acquisition");

    if (run_command(
        "bash scripts/bash/02_data_acquisition.sh",
        "ERROR: data acquisition failed."
    )) return 1;

    log_message("Pipeline finished successfully");

    return 0;
}
