# Three-Day To-Do Tracker App - Consolidated Documentation

## Table of Contents
1. [Introduction](#introduction)
2. [Core Functional Requirements](#core-functional-requirements)
3. [Special Handling Rules](#special-handling-rules)
4. [Wireframes](#wireframes)
5. [Frontend Components](#frontend-components)
6. [Backend Setup (Salesforce Objects)](#backend-setup-salesforce-objects)
7. [Reports & Analytics](#reports--analytics)
8. [Future Enhancements](#future-enhancements)
9. [Deployment Plan](#deployment-plan)
10. [Technical Development Approach](#technical-development-approach)
11. [Alternate Approach: LWC OSS Web App](#alternate-approach-lwc-oss-web-app)
12. [Conclusion](#conclusion)

---

## Introduction

The Three-Day To-Do Tracker App is a focused task management system designed to improve daily productivity. It simplifies personal and work task planning across three days — **Yesterday**, **Today**, and **Tomorrow**.

Key features include:

- Smart prioritization
- Task auto-migration
- Reminder-based alerting
- Task categorization
- Intelligent reporting
- offers future scalability.

## Core Functional Requirements

- View and manage tasks under Yesterday, Today, and Tomorrow blocks.
- Each task can have:
  - Title (mandatory)
  - Optional Tentative Time
  - Optional Priority (High / Medium / Low)
  - Optional Reminder
  - Optional Label (Work, Personal, etc.)
- Snooze: Postpone tasks to Tomorrow.
- Archive: Remove irrelevant tasks without deletion.
- Auto-Migration: Move incomplete Yesterday tasks automatically to Today at midnight.
- Priority Adjustment: Missed tasks receive higher priority on Today list.
- Reminder Tracking: Capture number of reminders triggered before completion.
- Missed Count Tracking: Record how often a task is missed before final completion.

## Special Handling Rules

- If no tentative time is set for a task, display as -- or N/A.
- Missed tasks are visually tagged.
- Capture actual task completion timestamps.
- Allow snoozing or archiving manually.

## Wireframes

=> TBA
Home Screen layout (Yesterday, Today, Tomorrow blocks)
Layout Updated with Archive Button, Missing Time Handling
Archive Screen
Task Creation Modal
Settings / Notification Manager

## Frontend Components

- Technology Stack:
- Frontend: LWC OSS (hosted via Netlify, Vercel, or GitHub Pages)
- Backend: Salesforce (custom objects Work__c and Reminder__c)
- Auth: Salesforce OAuth2 (Implicit Grant Flow)
- Local Storage: Browser (session storage for access token)

### Major Screens

- Home Screen (Yesterday, Today, Tomorrow blocks)
- Archive Screen
- Task Creation / Edit Modal
- Settings / Notification Manager

### Widgets

- Task Tile Widget (checkbox, task title, tentative time, archive button, priority badge, label)
- Reminder Popup (optional)

## Backend Setup (Salesforce Objects)

### Object: Work__c

- Field: Name
  - Type: Text(255)
  - Description: Task Name
- Field: Task_Date__c
  - Type: Date
  - Description: Assigned date
- Field: Task_Time__c
  - Type: Time
  - Description: Tentative execution time
- Field: Priority__c
  - Type: Picklist (High, Medium, Low)
  - Description: Task urgency level
- Field: Label__c
  - Type: Picklist (Work, Personal, etc.)
  - Description: Category label
- Field: Reminder_Set__c
  - Type: Checkbox
  - Description: Whether a reminder is set
- Field: Completion_Time__c
  - Type: DateTime
  - Description: Actual completion timestamp
- Field: Is_Archived__c
  - Type: Checkbox
  - Description: Archived status
- Field: Is_Missed__c
  - Type: Checkbox
  - Description: Missed status
- Field: Is_Snoozed__c
  - Type: Checkbox
  - Description: Snoozed status
- Field: Reminders_Triggered__c
  - Type: Number
  - Description: Reminders count before completion
- Field: Missed_Count__c
  - Type: Number
  - Description: Times missed before completion

### Object: Reminder__c

- Field: Name
  - Type: Text(255)
  - Description: Reminder Name
- Field: Related_Work__c
  - Type: Lookup(Work__c)
  - Description: Parent Task Reference
- Field: Reminder_Time__c
  - Type: Time
  - Description: Reminder trigger time
- Field: Is_Completed__c
  - Type: Checkbox
  - Description: Completion marker

## Reports & Analytics

- Tasks Completed vs Tasks Missed
  - Track overall productivity
- Average Delay by Priority
  - Understand how critical tasks are delayed
- Archived Task History
  - Audit previously archived tasks
- Tasks Completed on Time
  - Measure punctuality of task completion
- Average Reminders Before Completion
  - Understand reminder effectiveness
- Missed Count Analysis
  - Evaluate repetition of missed tasks
- Tasks by Label Report
  - Understand distribution across Work, Personal, etc.

## Future Enhancements

- Add support for Recurring tasks
- Push/Broadcast Notification Management
- Multi-Device Synchronization
- Task Export/Import feature
- Gamification elements (badges for consistency)
- Offline support (PWA upgrade)
- Dark Mode toggle

## Deployment Plan
- GitHub Repository Structure:
  - `/docs` → Documentation Files
  - `/src` → Flutter Source Code
  - `/config` → Salesforce Metadata Files
- Versioned deployments using Git
- Package.xml for Salesforce metadata deployments
- Hosting options: Netlify / Vercel / GitLab Pages

## Technical Development Approach

### Project Setup

- Install Node.js and npm
- Install LWC OSS CLI
- Create project using `lwc-create-app`

### Web App Structure

<img width="461" alt="image" src="https://github.com/user-attachments/assets/6a7747e1-9e0c-4822-9cc0-2af29584857e" />

### Frontend Component Development

- Build Home Screen static layout
- Build Task Tile widget
- Create Archive Screen
- Create Login Screen (Salesforce OAuth login)
- Integrate context management for session/auth token
- Fetch and bind Salesforce Work__c tasks
- Local reminder handling (optional browser notifications)
- Error Handling and Toast Notifications
- Mobile responsive design with flexible CSS

### Screen Details

## Home Screen (todoHome)

<img width="379" alt="image" src="https://github.com/user-attachments/assets/9fb9295e-7416-4248-89e0-0fe8ce178584" />

# Display:
- Yesterday's tasks (Comlumns to show : a checkbox, task name, time)
- Today's tasks (same as above)
- Tomorrow's tasks (same as above)

# Actions:
- Checkbox : To mark a task complete
- alarm symbol after the task : to snooze task to tomorrow
- Button for archive [for irrelevant tasks]

# Special Handling:
If a task is missed it will be shown with some highlight so they can be seen visually. a missed task usually may have higher priority than today's tasks. 
So Highlight missed tasks visually

## Archive Screen (archiveScreen)
+------------------------------------+
|           Archived Tasks           |
+------------------------------------+
| [x] Task A (Archived)              |
| [x] Task B (Archived)              |
+------------------------------------+

# Display:
- Archived tasks history

# Actions:
- (Optional Future) Restore archived tasks

## Login Screen (loginScreen)

# Display:
- Login button

# Actions:
- Authenticate via Salesforce OAuth2 Implicit Grant
- Capture and store access token

## Reminder Popup (Optional Feature)

# Display:
- Browser notification / modal popup

# Actions:
- Dismiss or mark task complete directly

## Settings screen (Optional Feature)
- TBA

### Key Functional Integrations

- Auto-migration of Yesterday's incomplete tasks
- Manual archive and snooze functionality
- Reminder count tracking mechanism
- Missed count tracking for completion analysis

### Conclusion
The Three-Day To-Do Tracker is not just a simple task manager —
- it's a structured, smart, and scalable platform to help users stay productive and organized.
- Designed with modular frontend (LWC OSS) and reliable backend (Salesforce),
- the app lays a strong foundation for personal users and can be extended for enterprise task management as well.
