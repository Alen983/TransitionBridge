# TransitionBridge

A Salesforce application that helps schools and transition coordinators guide students—especially those with IEPs—from school to adult services, benefits, and community programs.

## Overview

TransitionBridge centralizes student transition planning in one place. Counselors and case workers can track students, manage program referrals, monitor deadlines, and escalate issues when gaps or risks are identified. Built-in agent actions support automated workflows for gap analysis, referral drafting, follow-ups, and escalation routing.

## Features

- **Student intake** — Lightning Web Component form to register students with school, grade status, IEP flag, and guardian contact details
- **Program & referral management** — Track programs, enrollments, and referral status across agencies
- **Deadline tracking** — Monitor transition milestones and age-based deadlines per student
- **Gap identification** — Detect missing referrals, incomplete data, and timeline risks
- **Escalation workflow** — Route urgent cases to Benefits Counselors or Case Workers queues
- **Agent action logging** — Audit trail of automated actions taken on behalf of each student

## Data Model

| Object | Purpose |
|--------|---------|
| `Student__c` | Core student profile and transition status |
| `Program__c` | Adult services and benefits programs |
| `Program_Enrollment__c` | Student referrals and enrollment status |
| `Deadline_Milestone__c` | Key transition dates and milestones |
| `IEP_Transition_Goal__c` | IEP transition goals and targets |
| `Accommodation_Record__c` | Student accommodations history |
| `Escalation_Log__c` | Escalated cases and resolution notes |
| `Agent_Action_Log__c` | Log of agent-driven actions per student |

## Agent Actions

Invocable Apex actions (category: **TransitionBridge**) for use with Salesforce Agentforce or Flow:

| Action | Description |
|--------|-------------|
| Find Student | Look up a student record |
| Identify Transition Gaps | Flag missing referrals, data conflicts, and timeline risks |
| Query Deadlines | Retrieve upcoming deadlines for a student |
| Draft Referral | Create a program enrollment referral |
| Follow-Up Nudge | Generate follow-up tasks for stalled referrals |
| Escalate | Create an escalation and assign to the appropriate queue |

## Tech Stack

- **Platform:** Salesforce Lightning (API v67.0)
- **UI:** Lightning Web Components, custom Lightning app
- **Backend:** Apex (`@InvocableMethod`, `@AuraEnabled`)
- **Deployment:** Salesforce CLI (`sf project deploy`)

## Project Structure

```
force-app/main/default/   # Salesforce metadata (objects, classes, LWC, etc.)
manifest/                 # Deployment package manifests
scripts/apex/             # Anonymous Apex scripts for sample data and testing
sfdx-project.json         # Salesforce DX project configuration
```

## Getting Started

### Prerequisites

- [Salesforce CLI](https://developer.salesforce.com/tools/salesforcecli) installed
- A Salesforce org (Developer, Sandbox, or Scratch Org)

### Deploy

```bash
sf project deploy start --source-dir force-app
```

### Load sample data

Run the scripts in `scripts/apex/` via the Developer Console or CLI:

```bash
sf apex run --file scripts/apex/loadSampleData.apex
```

### Assign permissions

Assign the **TransitionBridge User** permission set to users who need access to the app.

## License

MIT — see [LICENSE](LICENSE).
