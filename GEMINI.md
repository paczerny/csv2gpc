# Project: csv2gpc

A collection of Ruby scripts for converting bank statement CSV exports into the GPC (ABO) format, commonly used by accounting software in the Czech Republic (e.g., ABRA Flexi).

## Project Overview

The project provides tools to bridge the gap between bank CSV exports and accounting software that requires the GPC/ABO format. It supports several major Czech banks.

### Main Technologies
- **Ruby**: The primary language for conversion logic.
- **CSV Library**: Used for parsing bank exports.
- **Digest/SHA256**: Used for generating unique record identifiers.
- **iconv**: (Via shell script) for handling character encoding (CP1250 to UTF-8).

## Key Scripts and Tools

### `csv2gpc.rb`
The main conversion script for CSV files.
- **Supported Banks:** CSOB, KB (Komerční banka), Moneta, Raiffeisenbank.
- **Manual Configuration Required:** Before running, you must edit the "USER SETUP" section in the script to:
    1.  Select the bank format (e.g., `field_ids = Moneta`).
    2.  Set the account name (`nazev_uctu`).
    3.  Set the account number (`cislo_uctu`).
- **Usage:** `ruby csv2gpc.rb <input_file.csv> <output_file.gpc>`

### `csv2gpc.sh`
A shell wrapper that handles encoding conversion.
- **Purpose:** Converts input from CP1250 (common in Czech Windows environments) to UTF-8, runs `csv2gpc.rb`, and then converts the resulting GPC back to CP1250.
- **Usage:** `./csv2gpc.sh <filename.csv>` (Generates `<filename>.gpc`).
- **Limitation:** Does not support filenames with spaces.

## Development Conventions

- **Encoding:** The Ruby scripts themselves expect UTF-8 input. Use the shell wrapper if your source files are in CP1250.
- **GPC Format:** Adheres to the ABO format (130 characters per line).
- **Date Format:** Typically expects `DD.MM.YYYY` in input CSVs.
- **Hashes:** Each record is assigned a unique hash based on its details to help identify duplicates during import.

## Building and Running

### Prerequisites
- Ruby installed on the system.
- `iconv` utility (usually present on Linux/macOS) for the shell script.

### Running Tests
There are no formal test suites (e.g., RSpec/Minitest). Verification is typically done by running the scripts against sample CSV files and checking the resulting `.gpc` output.

## TODO / Known Issues
- The scripts often use hardcoded "USER SETUP" values; consider moving these to command-line arguments or a config file.
- `csv2gpc.sh` limitation regarding filenames with spaces.
