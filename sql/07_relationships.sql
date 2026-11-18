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

SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Purchase Order','Sense Quickstart Procurement.Supplier','RELATED_TO');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Purchase Order','Sense Quickstart Procurement.Material','RELATED_TO');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Carrier','Sense Quickstart Procurement.Shipment','RELATED_TO');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Supplier Count','Sense Quickstart Procurement.Supplier','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Supplier Count','Sense Quickstart Procurement.Vendor Record Count','HAS_VARIANT');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.On-Time Delivery Rate','Sense Quickstart Procurement.Shipment','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.On-Time Delivery Rate','Sense Quickstart Procurement.Carrier Reported On-Time Rate','HAS_VARIANT');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Carrier Reported On-Time Rate','Sense Quickstart Procurement.Carrier','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Procurement Spend','Sense Quickstart Procurement.Purchase Order','MEASURES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Vendor Account Group','Sense Quickstart Procurement.Supplier','CLASSIFIES');
SELECT SYSTEM$CREATE_GLOSSARY_RELATIONSHIP('Sense Quickstart Procurement.Probationary Vendor Exclusion','Sense Quickstart Procurement.Supplier Count','APPLIES_TO');
