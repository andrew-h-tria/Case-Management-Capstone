# Public Health Case Management & Triage System
**Collaborative Project: Andrew & Alex**

## 1. Project Overview & Business Goals
This solution addresses the challenges faced by public health agencies in managing high volumes of service requests. It standardizes intake, automates prioritization, and integrates with external systems to provide a single, authoritative system of record.

### Key Business Goals:
* **Multi-Channel Intake:** Consistent data capture via Phone, Web, and Email.
* **Automated Triage:** Automatic routing and SLA assignment based on service categories.
* **Data Enrichment:** Real-time retrieval of external provider data to assist agents.
* **Auditability:** Complete lifecycle tracking of every case action for compliance.

## 2. Technical Architecture (The SFDX Package)
The project utilizes **Source-Driven Development (SFDX)**, modularizing all metadata within the `force-app` directory.

### Data Model
* **Core Hub:** The `Case` object acts as the primary record.
* **Case_Activity__c:** Tracks lifecycle events (Intake, Routing, Approval, Resolution).
* **Case_Provider__c:** Persists external data results for long-term reporting.
![Project Data Model](ERD.png)



### Integration Layer
* **Service Classes:** `Case_ExternalProviderService` handles REST callouts to the Retool API.
* **Security:** Connectivity is managed via **Named Credentials** and **External Credentials**.
* **Error Handling:** Centralized `Case_ErrorHandler` logs exceptions directly to the Case Timeline.

## 3. Security & Compliance
* **OWD:** `Case` is set to **Private** to protect sensitive citizen data.
* **Access Control:** `Case_Agent` and `Case_Supervisor` Permission Sets manage object and Field-Level Security (FLS).
* **Apex Enforcement:** All SOQL/DML uses `WITH USER_MODE` and `Schema` checks to ensure security settings are respected.

## 4. DevOps & Deployment
* **Version Control:** Managed via GitHub for collaborative development.
* **Package Deployment:** 1. Authorize Org.
    2. Deploy Connectivity (Named Credentials).
    3. Deploy Source: `sf project deploy start`.

---

## 5. End-to-End User Journey (Walkthrough)
Below is the standard workflow for a "Medical Service Request":

### Step 1: Intake (The Agent)
* **Action:** Agent opens the **Case Intake Screen Flow**.
* **Selection:** They select the Citizen (Contact), set **Category** to `Medical`, and **Priority** to `High`.
* **System Result:** The system automatically sets the **SLA Target** to +24 hours and creates an "Intake Created" Activity record.

### Step 2: Triage & Approval (The Supervisor)
* **Action:** Because the case is `Medical` and `High` priority, it enters an **Approval Process**.
* **Selection:** The Supervisor reviews the case and clicks **Approve**.
* **System Result:** The Case Status updates to `In Triage` and an "Approval Granted" event appears on the Timeline.

### Step 3: Provider Enrichment (The Agent)
* **Action:** Agent clicks the **"Find Providers"** LWC on the Case record.
* **Selection:** They click **"Find Providers"** to fetch external data, then click **"Select"** on the best-ranked provider.
* **System Result:** The Case Status moves to `In Progress`, the Provider record is linked, and a "Provider Selected" activity is logged.

### Step 4: Resolution & Closure
* **Action:** Agent documents the resolution and moves the Status to `Resolved`.
* **Final Step:** Only a **Supervisor** can move the Case to `Closed`, ensuring a final compliance check."