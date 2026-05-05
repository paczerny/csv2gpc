# csv2gpc

Ruby scripts for converting bank statement CSV exports into the GPC (ABO) format, compatible with accounting software like ABRA Flexi.

## Features

- Supports major Czech banks: **CSOB, KB, Moneta, Raiffeisenbank**.
- Generates GPC (ABO) files with unique record hashes.
- Handles character encoding conversion (CP1250 to UTF-8) via shell wrapper.

## Usage

### CSV to GPC Conversion

1.  **Configure the script:** Open `csv2gpc.rb` and edit the `USER SETUP` section to set your bank, account name, and account number.
2.  **Run the conversion:**
    ```bash
    ruby csv2gpc.rb input_file.csv output_file.gpc
    ```

### Using the Shell Wrapper (Recommended for Windows CSVs)

If your CSV file is in CP1250 encoding:
```bash
./csv2gpc.sh input_file.csv
```
This will automatically handle the encoding conversion and generate `input_file.gpc`.

## Prerequisites

- Ruby
- `iconv` (for the shell script)

## Documentation

For more detailed technical information, see [GEMINI.md](./GEMINI.md).
