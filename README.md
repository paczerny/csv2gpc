# csv2gpc

Ruby scripts for converting bank statement CSV exports into the GPC (ABO) format, compatible with accounting software like ABRA Flexi.

## Features

- Supports major Czech banks: **CSOB, KB, Moneta, Raiffeisenbank**.
- Generates GPC (ABO) files with unique record hashes.
- Handles character encoding conversion (e.g., CP1250 to UTF-8) natively via Ruby and configuration.

## Usage

### CSV to GPC Conversion

1.  **Configure the script:** Open `config.yml` and set your bank, account name, account number, and encodings (input/output).
2.  **Run the conversion:**
    ```bash
    ruby csv2gpc.rb input_file.csv output_file.gpc
    ```

## Prerequisites

- Ruby

## Documentation

For more detailed technical information, see [GEMINI.md](./GEMINI.md).
