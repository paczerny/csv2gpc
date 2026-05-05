# Project: csv2gpc

A collection of Ruby scripts for converting bank statement CSV exports into the GPC (ABO) format, commonly used by accounting software in the Czech Republic (e.g., ABRA Flexi).

## Project Overview

The project provides tools to bridge the gap between bank CSV exports and accounting software that requires the GPC/ABO format. It supports several major Czech banks.

### Main Technologies
- **Ruby**: The primary language for conversion logic.
- **CSV Library**: Used for parsing bank exports.
- **Digest/SHA256**: Used for generating unique record identifiers.
- **YAML**: For externalized configuration of bank formats and account details.

## Key Scripts and Tools

### `csv2gpc.rb`
The main conversion script for CSV files.
- **Supported Banks:** CSOB, KB (Komerční banka), Moneta, Raiffeisenbank.
- **Configuration:** Reads from `config.yml` (or an optional path as 3rd argument).
- **Encoding Handling:** Natively handles input and output encodings (e.g., CP1250, UTF-8) as specified in the configuration.
- **Usage:** `ruby csv2gpc.rb <input_file.csv> <output_file.gpc> [config.yml]`

## Development Conventions

- **Encoding:** Configurable via `config.yml` (`input_encoding` and `output_encoding`).
- **GPC Format:** Adheres to the ABO format (130 characters per line).
- **Date Format:** Typically expects `DD.MM.YYYY` in input CSVs.
- **Hashes:** Each record is assigned a unique hash based on its details to help identify duplicates during import.

## Building and Running

### Prerequisites
- Ruby installed on the system.

### Running Tests
Use the `run_tests.rb` script to verify the conversion logic against existing `.csv` and `.gpc` file pairs.
- **Usage:** `ruby run_tests.rb`

## TODO / Known Issues
- Currently limited to banks with existing mappings in `config.yml`.
