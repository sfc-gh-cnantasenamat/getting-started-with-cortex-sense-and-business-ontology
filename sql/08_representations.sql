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

SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Supplier', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.LFA1", "objectName": "LFA1"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Material', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.MARA", "objectName": "MARA"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Purchase Order', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.EKPO", "objectName": "EKPO"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Shipment', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.LIKP", "objectName": "LIKP"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Carrier', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.LFA2", "objectName": "LFA2"}', 'REPRESENTS');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Vendor Account Group', '{"refType": "TABLE", "fqn": "SENSE_ONTOLOGY_QS.SAP.T077K", "objectName": "T077K"}', 'REFERENCE_DATA');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Supplier Count', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Vendor Record Count', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.On-Time Delivery Rate', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Carrier Reported On-Time Rate', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
SELECT SYSTEM$CREATE_GLOSSARY_ASSOCIATION('Sense Quickstart Procurement.Procurement Spend', '{"refType": "SEMANTIC_VIEW", "fqn": "SENSE_ONTOLOGY_QS.SAP.PROCUREMENT_BARE_SV", "objectName": "PROCUREMENT_BARE_SV"}', 'RELATED_SEMANTIC_VIEW');
