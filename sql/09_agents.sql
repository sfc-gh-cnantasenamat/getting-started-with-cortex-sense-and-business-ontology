-- Copyright 2026 Snowflake Inc.
-- SPDX-License-Identifier: Apache-2.0
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.BARE_AGENT
  COMMENT = 'Quickstart arm A: bare procurement semantic view only'
  FROM SPECIFICATION $$
models:
  orchestration: auto
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
  orchestration: |
    Use query_procurement for every data question. It queries one semantic view
    over vendors, materials, purchase orders, shipments, carriers and inspections.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
$$;

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.ONTOLOGY_AGENT
  COMMENT = 'Quickstart arm B: bare semantic view plus Business Ontology search'
  FROM SPECIFICATION $$
models:
  orchestration: auto
experimental:
  EnableSnowscopeBusinessOntologySearch: true
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
    When you used a governed Business Ontology definition, name the term.
  orchestration: |
    Before querying data, call business_ontology to look up the governed
    definition of each business term in the question. When the ontology names a
    canonical metric, use its formula rather than a similarly named variant, and
    follow any policy that applies to it. Then use query_procurement to compute it.
    If the question only asks what something means, answer from the ontology.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
  - tool_spec:
      type: snowscope_search
      name: business_ontology
      description: Governed business definitions for procurement - canonical metrics and their formulas, scoped variants, business policies, and code meanings.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
  business_ontology:
    corpus: businessOntology
$$;

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.SENSE_AGENT
  COMMENT = 'Quickstart arm C: bare semantic view plus Cortex Sense context'
  FROM SPECIFICATION $$
models:
  orchestration: auto
experimental:
  AgenticAnalystAllowArbitrarySQL: true
  FallbackWarehouse: SENSE_ONTOLOGY_QS_WH
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
  orchestration: |
    Before querying data, call procurement_context to retrieve what Cortex Sense
    learned about these tables: how they join, which columns matter, and the
    queries people already run. Use it to choose tables and write SQL. Then use
    query_procurement for questions the semantic view covers.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
  - tool_spec:
      type: cortex_sense
      name: procurement_context
      description: Usage-derived context for the SAP procurement tables - joins, key columns, and example queries people already run.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
  procurement_context:
    context_name: SENSE_ONTOLOGY_QS.SAP.SENSE_QS_TABLES
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
$$;

CREATE OR REPLACE AGENT SENSE_ONTOLOGY_QS.SAP.SENSE_ONTOLOGY_AGENT
  COMMENT = 'Quickstart arm D: bare semantic view plus Cortex Sense and Business Ontology'
  FROM SPECIFICATION $$
models:
  orchestration: auto
experimental:
  EnableSnowscopeBusinessOntologySearch: true
  AgenticAnalystAllowArbitrarySQL: true
  FallbackWarehouse: SENSE_ONTOLOGY_QS_WH
orchestration:
  budget:
    seconds: 150
    tokens: 40000
instructions:
  response: |
    You are an analytics assistant for SAP procurement data.
    Answer precisely. State the final answer as a clear number or list first,
    then briefly explain how it was computed and which data was used.
    Never write your planning or reasoning notes in the response; write only the final answer.
    When you used a governed Business Ontology definition, name the term.
  orchestration: |
    Before querying data, call business_ontology to look up the governed
    definition of each business term in the question, and call procurement_context
    to retrieve how the tables join and which queries people already run. When the
    ontology names a canonical metric, use its formula rather than a similarly
    named variant, and follow any policy that applies to it. Then use
    query_procurement for questions the semantic view covers.
tools:
  - tool_spec:
      type: cortex_analyst_text_to_sql
      name: query_procurement
      description: Procurement data - vendors, materials, purchase orders, shipments, carriers, inspections.
  - tool_spec:
      type: snowscope_search
      name: business_ontology
      description: Governed business definitions for procurement - canonical metrics and their formulas, scoped variants, business policies, and code meanings.
  - tool_spec:
      type: cortex_sense
      name: procurement_context
      description: Usage-derived context for the SAP procurement tables - joins, key columns, and example queries people already run.
tool_resources:
  query_procurement:
    semantic_view: SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
  business_ontology:
    corpus: businessOntology
  procurement_context:
    context_name: SENSE_ONTOLOGY_QS.SAP.SENSE_QS_FULL
    execution_environment: {type: warehouse, warehouse: SENSE_ONTOLOGY_QS_WH, query_timeout: 120}
$$;
