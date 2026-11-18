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

-- =====================================================================
-- Business Ontology demo, 03: SAP schema, cloned data, reference (code) tables
-- Built objects live in SAP; the source tables stay untouched in RAW.
-- =====================================================================
USE DATABASE SENSE_ONTOLOGY_QS;

CREATE SCHEMA IF NOT EXISTS SENSE_ONTOLOGY_QS.SAP
  COMMENT = 'Business Ontology demo: domain SVs (bare/enriched), governed BON, fair 3-agent benchmark';
USE SCHEMA SENSE_ONTOLOGY_QS.SAP;

-- Zero-copy clone of the SAP source tables from RAW.
-- PREREQUISITE: run 01_setup.sql and 02_raw_data.sql first;
-- they create RAW and load the synthetic SAP data this script clones.
EXECUTE IMMEDIATE $$
DECLARE
  missing_source EXCEPTION (-20001, 'RAW.LFA1 not found. Run sql/01_setup.sql and sql/02_raw_data.sql first.');
BEGIN
  IF (NOT EXISTS (SELECT 1 FROM SENSE_ONTOLOGY_QS.INFORMATION_SCHEMA.TABLES
                  WHERE TABLE_SCHEMA = 'RAW' AND TABLE_NAME = 'LFA1')) THEN
    RAISE missing_source;
  END IF;
  RETURN 'RAW source tables found';
END;
$$;

EXECUTE IMMEDIATE $$
DECLARE
  t ARRAY DEFAULT ARRAY_CONSTRUCT('LFA1','LFA2','LFB1','MARA','EKPO','LIKP','T001W','T320',
                                  'STPO','QALS','BSEG','COEP','VBAP','KONV','QUAL_MATRIX');
  i INTEGER DEFAULT 0;
  n VARCHAR;
BEGIN
  FOR i IN 0 TO ARRAY_SIZE(t)-1 DO
    n := t[i];
    EXECUTE IMMEDIATE 'CREATE OR REPLACE TABLE SENSE_ONTOLOGY_QS.SAP.' || n ||
                      ' CLONE SENSE_ONTOLOGY_QS.RAW.' || n;
  END FOR;
  RETURN 'cloned ' || ARRAY_SIZE(t);
END;
$$;

-- Reference (code) tables: BON holds one term per code field that points here.
-- New codes arrive via normal ETL into these tables; BON only changes when a rule changes.
CREATE OR REPLACE TABLE T077K (
  KTOKK VARCHAR(10) PRIMARY KEY COMMENT 'Vendor account group code',
  TXT30 VARCHAR(60) COMMENT 'Account group description',
  EXCLUDE_FROM_ACTIVE_COUNT BOOLEAN COMMENT 'TRUE if vendors in this group are excluded from the active supplier count'
) COMMENT = 'Vendor account group reference (code table)' AS
SELECT * FROM VALUES ('ZSTR','Strategic partner',FALSE),('ZSTD','Standard vendor',FALSE),('ZPRB','Probationary vendor',TRUE);

CREATE OR REPLACE TABLE T023T (
  MATKL VARCHAR(5) PRIMARY KEY COMMENT 'Material group code',
  WGBEZ VARCHAR(60) COMMENT 'Material group description'
) COMMENT = 'Material group texts (code table)' AS
SELECT * FROM VALUES ('043','Electronics'),('044','Chemicals'),('045','Metals'),('046','Packaging'),('047','Raw Materials'),('048','Assembly');

-- Procurement semantic view: tables, keys, joins and labels only. No metrics, synonyms or business rules.
CREATE OR REPLACE SEMANTIC VIEW PROCUREMENT_BARE_SV
TABLES (
  LFA1 AS SENSE_ONTOLOGY_QS.SAP.LFA1 PRIMARY KEY (LIFNR) COMMENT = 'Vendor master data',
  T077K AS SENSE_ONTOLOGY_QS.SAP.T077K PRIMARY KEY (KTOKK) COMMENT = 'Vendor account groups',
  LFB1 AS SENSE_ONTOLOGY_QS.SAP.LFB1 PRIMARY KEY (LIFNR, VKONT) COMMENT = 'Vendor contract data',
  MARA AS SENSE_ONTOLOGY_QS.SAP.MARA PRIMARY KEY (MATNR) COMMENT = 'Material master data',
  T023T AS SENSE_ONTOLOGY_QS.SAP.T023T PRIMARY KEY (MATKL) COMMENT = 'Material group texts',
  EKPO AS SENSE_ONTOLOGY_QS.SAP.EKPO PRIMARY KEY (EBELN, EBELP) COMMENT = 'Purchasing document items',
  T001W AS SENSE_ONTOLOGY_QS.SAP.T001W PRIMARY KEY (WERKS) COMMENT = 'Plant data',
  LIKP AS SENSE_ONTOLOGY_QS.SAP.LIKP PRIMARY KEY (TKNUM) COMMENT = 'Shipment data',
  LFA2 AS SENSE_ONTOLOGY_QS.SAP.LFA2 PRIMARY KEY (TDLNR) COMMENT = 'Forwarding agent data',
  QALS AS SENSE_ONTOLOGY_QS.SAP.QALS PRIMARY KEY (PRUEFLOS) COMMENT = 'Inspection lot data',
  STPO AS SENSE_ONTOLOGY_QS.SAP.STPO PRIMARY KEY (STLNR, IDNRK) COMMENT = 'BOM items'
)
RELATIONSHIPS (
  LFA1 (KTOKK) REFERENCES T077K,
  MARA (MATKL) REFERENCES T023T,
  LFB1 (LIFNR) REFERENCES LFA1,
  EKPO (LIFNR) REFERENCES LFA1,
  EKPO (MATNR) REFERENCES MARA,
  EKPO (WERKS) REFERENCES T001W,
  LIKP (TDLNR) REFERENCES LFA2,
  LIKP (WERKS_DST) REFERENCES T001W,
  QALS (MATNR) REFERENCES MARA,
  STPO (IDNRK) REFERENCES MARA
)
FACTS (
  MARA.STPRS AS STPRS COMMENT = 'Standard price',
  EKPO.NETWR AS NETWR COMMENT = 'Net order value',
  EKPO.MENGE AS MENGE COMMENT = 'Purchase order quantity',
  LIKP.MENGE AS MENGE COMMENT = 'Delivery quantity',
  LIKP.FRTCO AS FRTCO COMMENT = 'Freight cost',
  LFA2.OTRAT AS OTRAT COMMENT = 'Carrier on-time ratio',
  LFA2.LZEIT AS LZEIT COMMENT = 'Transit time',
  QALS.QAESSION AS QAESSION COMMENT = 'Defect rate',
  LFB1.JWERT AS JWERT COMMENT = 'Annual contract value',
  STPO.MENGE AS MENGE COMMENT = 'Component quantity',
  STPO.STUFE AS STUFE COMMENT = 'BOM level'
)
DIMENSIONS (
  LFA1.LIFNR AS LIFNR COMMENT = 'Vendor number', LFA1.NAME1 AS NAME1 COMMENT = 'Vendor name', LFA1.ORT01 AS ORT01 COMMENT = 'City', LFA1.LAND1 AS LAND1 COMMENT = 'Country code', LFA1.KTOKK AS KTOKK COMMENT = 'Account group', LFA1.ZTERM AS ZTERM COMMENT = 'Payment terms key',
  T077K.KTOKK AS KTOKK COMMENT = 'Account group', T077K.TXT30 AS TXT30 COMMENT = 'Description', T077K.EXCLUDE_FROM_ACTIVE_COUNT AS EXCLUDE_FROM_ACTIVE_COUNT COMMENT = 'Exclude flag',
  LFB1.VKONT AS VKONT COMMENT = 'Contract account', LFB1.VTART AS VTART COMMENT = 'Contract type', LFB1.DTEND AS DTEND COMMENT = 'Validity end date',
  MARA.MATNR AS MATNR COMMENT = 'Material number', MARA.MAKTX AS MAKTX COMMENT = 'Material description', MARA.MATKL AS MATKL COMMENT = 'Material group',
  T023T.WGBEZ AS WGBEZ COMMENT = 'Material group description',
  EKPO.EBELN AS EBELN COMMENT = 'Purchasing document number', EKPO.EBELP AS EBELP COMMENT = 'Item number', EKPO.LIFNR AS LIFNR COMMENT = 'Vendor number', EKPO.MATNR AS MATNR COMMENT = 'Material number', EKPO.WERKS AS WERKS COMMENT = 'Plant', EKPO.STATU AS STATU COMMENT = 'Status', EKPO.BEDAT AS BEDAT COMMENT = 'Purchasing document date',
  T001W.WERKS AS WERKS COMMENT = 'Plant', T001W.NAME1 AS NAME1 COMMENT = 'Name', T001W.REGIO AS REGIO COMMENT = 'Region',
  LIKP.TKNUM AS TKNUM COMMENT = 'Shipment number', LIKP.TDLNR AS TDLNR COMMENT = 'Forwarding agent', LIKP.MATNR AS MATNR COMMENT = 'Material number', LIKP.STATU AS STATU COMMENT = 'Delivery status', LIKP.LFDAT AS LFDAT COMMENT = 'Delivery date', LIKP.WADAT AS WADAT COMMENT = 'Goods issue date', LIKP.WERKS_DST AS WERKS_DST COMMENT = 'Destination plant',
  LFA2.TDLNR AS TDLNR COMMENT = 'Forwarding agent', LFA2.NAME1 AS NAME1 COMMENT = 'Name', LFA2.VSART AS VSART COMMENT = 'Shipping type',
  QALS.PRUEFLOS AS PRUEFLOS COMMENT = 'Inspection lot', QALS.MATNR AS MATNR COMMENT = 'Material number', QALS.VCODE AS VCODE COMMENT = 'Usage decision code',
  STPO.STLNR AS STLNR COMMENT = 'Bill of material', STPO.IDNRK AS IDNRK COMMENT = 'BOM component'
)
COMMENT = 'SAP procurement data: vendors, materials, purchase orders, shipments, carriers, inspections, BOM';
