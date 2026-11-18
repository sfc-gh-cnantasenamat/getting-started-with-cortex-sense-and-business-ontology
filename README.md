# Getting Started with Cortex Sense and Business Ontology

Companion code for the developer guide "Getting Started with Cortex Sense and Business Ontology". Cortex Sense and Business Ontology are in Private Preview, so you need an account where both are enabled.

## What is here

| Path | Purpose |
| --- | --- |
| `setup_sense_ontology.sh` | One-shot setup: builds the database, ontology, agents and eval files |
| `sql/01_setup.sql` to `sql/09_agents.sql` | The same setup as nine SQL steps you can run one at a time |
| `eval/run_eval.py` | Runs the 30-question eval against the four agents and scores it |
| `eval/questions.csv` | 30 questions: 10 governed, 10 discovery, 10 control |
| `eval/results.json` | Results from the reference run |
| `assets/` | Architecture and workflow diagrams |

## Eval arms

All four arms use the same bare semantic view.

| Arm | Agent | Adds |
| --- | --- | --- |
| A | BARE_AGENT | Nothing |
| B | ONTOLOGY_AGENT | Business Ontology search |
| C | SENSE_AGENT | Cortex Sense over the tables |
| D | SENSE_ONTOLOGY_AGENT | Business Ontology and Cortex Sense |

## Reference results (correct out of 60)

| Arm | Governed | Discovery | Control | Total |
| --- | --- | --- | --- | --- |
| A | 12/20 | 0/20 | 20/20 | 32/60 |
| B | 20/20 | 0/20 | 20/20 | 40/60 |
| C | 14/20 | 20/20 | 20/20 | 54/60 |
| D | 20/20 | 20/20 | 20/20 | 60/60 |

One run, one author, one LLM judge. Treat it as an illustration, not a benchmark.

## Usage

Set `SNOWFLAKE_CONNECTION_NAME` to a connection with a role that can create databases, then follow the guide. `SENSE_ONTOLOGY_SCHEMA` overrides the schema the eval reads.
