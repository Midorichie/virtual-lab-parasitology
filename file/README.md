```markdown
# Virtual Laboratory for Parasitology

A blockchain-based virtual laboratory system built on the Stacks blockchain for conducting and recording parasitology experiments.

## Quick Start

1. Install dependencies:
   ```bash
   curl --proto '=https' --tlsv1.2 -sSf https://sh.clarinet.tools | sh
   ```

2. Run tests:
   ```bash
   clarinet test
   ```

## Project Structure

- `contracts/`: Smart contracts
  - `experiments.clar`: Core experiment functionality
  - `laboratory.clar`: Access management
  - `data-storage.clar`: Data persistence

- `tests/`: Contract tests
  - `experiments_test.ts`
  - `laboratory_test.ts`
  - `data-storage_test.ts`

## Development

1. Make changes to contracts in `contracts/`
2. Write tests in `tests/`
3. Run `clarinet test` to verify changes

## License

MIT
```
