# WhatsApp Web Bulk Contact Deletion Helper

A browser-console JavaScript utility that helps users identify and bulk-delete WhatsApp-only contacts through WhatsApp Web's own user interface.

**Status:** Experimental · Untested against all WhatsApp Web configurations

## Overview

Managing a large number of contacts on WhatsApp can be tedious, particularly when deleting contacts individually.

This project provides a lightweight JavaScript helper that automates repetitive contact-deletion actions through WhatsApp Web's existing graphical interface.

It allows users to scan their contact list, select multiple contacts, inspect whether the deletion controls are available, and process selected contacts sequentially.

The script interacts with the visible WhatsApp Web interface rather than using private APIs, authentication tokens, cookies, or direct network requests.

## Features

- **Contact scanning:** Scans the New Chat contact list and collects visible contact names.
- **Contact selection:** Select individual contacts or select all currently displayed results.
- **Search and filtering:** Quickly find contacts by name.
- **Non-destructive probing:** Checks whether the contact information, edit interface, and Delete Contact control can be located without deleting anything.
- **Sequential deletion:** Processes selected contacts one at a time.
- **Confirmation safeguards:** Requires the user to type `DELETE` before starting.
- **First-deletion checkpoint:** Requests confirmation after the first successful deletion when processing multiple contacts.
- **Randomised delays:** Introduces pauses between deletion attempts.
- **Stop control:** Allows the user to stop processing after the current contact.
- **Diagnostic logging:** Reports failures, skipped contacts, and unexpected interface states.
- **Header verification:** Checks that the intended contact is displayed before proceeding.
- **Emoji-aware verification:** Allows header comparisons to ignore emoji characters while retaining the original contact name for searching.

## Requirements

- Google Chrome or another Chromium-based browser.
- An active WhatsApp Web session.
- Access to the browser's Developer Tools.
- Basic familiarity with using the JavaScript console.

## Installation

No installation, dependencies, package manager, or build process is required.

1. Open [WhatsApp Web](https://web.whatsapp.com/).
2. Log in to your WhatsApp account.
3. Open Developer Tools by pressing `F12`.
4. Navigate to the **Console** tab.
5. Paste the complete JavaScript source code.
6. Press `Enter` to execute it.

Chrome may display a warning about pasting code into the console. Only proceed if you understand and have inspected the script you are executing.

Once loaded, the helper interface should appear in the upper-right corner of WhatsApp Web.

## Usage

### 1. Scan contacts

Click **1. Scan contacts**.

The script opens the New Chat panel and scans its contact list, collecting contact names.

The resulting list can be filtered using the search field.

**Important:** The scanned list may include phone-synchronised contacts. The script cannot reliably determine which contacts are exclusively stored on WhatsApp.

### 2. Select contacts

Use the checkboxes to select the contacts you intend to delete.

Alternatively, use **Select all shown** to select all contacts currently matching the search filter.

Always review your selection before proceeding.

### 3. Probe before deletion

Click **2. Probe (no delete)**.

This checks whether the script can:

- Locate the selected contact.
- Open the correct conversation.
- Verify the conversation header.
- Locate the Edit control.
- Locate the Delete Contact control.

The probe does not intentionally confirm or execute a deletion.

A successful probe indicates that the required interface controls were found, not that the contact is necessarily WhatsApp-only.

### 4. Delete selected contacts

Click **3. Delete selected**.

A confirmation prompt displays the selected contacts.

Type:

`DELETE`

to authorise the operation.

Contacts are then processed individually.

After the first successful deletion, the script asks whether to continue. This provides an opportunity to check that the operation behaved as expected.

### 5. Stop processing

Click **Stop** to request that the script stop after the current contact operation.

## Safety Mechanisms

The project includes several safeguards intended to reduce accidental actions.

| Safeguard | Purpose |
|---|---|
| Exact contact search | Avoids selecting loosely matching names |
| Header verification | Checks that the intended conversation is open |
| Emoji-aware comparison | Accommodates emoji differences in displayed headers |
| Probe mode | Tests interface navigation without intentional deletion |
| Confirmation prompt | Requires explicit authorisation |
| First-deletion checkpoint | Allows manual verification before continuing |
| Unexpected-state handling | Stops processing when an unexpected error occurs |
| Sequential execution | Avoids simultaneous deletion operations |

### Important distinction: WhatsApp-only contacts

The script is intended for WhatsApp-only contact deletion.

However, it cannot guarantee that a contact is not synchronised with a phone address book or an external contacts provider.

Its dialog-text checks are heuristic safeguards, not definitive verification.

Users must independently establish that a selected contact is safe to delete.

## Troubleshooting

### Chat header verification failed

**Possible cause:** WhatsApp's displayed header differs from the contact name collected from the contact list.

This can happen when:

- The header contains an additional profile initial.
- Emojis are omitted from the displayed name.
- WhatsApp changes its DOM structure.
- The conversation takes longer to load.

**Current approach:** The script checks all header text lines and can ignore emoji characters during comparison.

### Edit or Delete Contact button not found

**Possible cause:** WhatsApp has changed its interface or the contact does not expose the expected editing controls.

**Recommended action:**
1. Refresh WhatsApp Web.
2. Run the script again.
3. Select the affected contact.
4. Run Probe.
5. Inspect the console diagnostics.

### Multiple exact matches

The script skips a contact when it cannot identify exactly one matching result.

This behaviour is intentional and should be retained.

### Unexpected UI state

The script stops when an unexpected error occurs during deletion.

This prevents it from continuing through the remaining contacts when the interface may no longer be in the expected state.

## Technical Implementation

The project uses standard browser JavaScript and DOM interaction.

Key implementation components include:

- DOM selectors for locating contact-list entries and interface controls.
- `Mutation`-independent polling through a custom `waitFor()` helper.
- Simulated mouse events for interface interaction.
- Text normalisation for contact-name comparisons.
- Emoji removal for header verification.
- Asynchronous execution for sequential operations.
- Randomised delays between deletion attempts.
- A floating HTML interface for user interaction.

The script does not intentionally access WhatsApp's private APIs, authentication credentials, session cookies, or perform direct network requests.

## Limitations

This project is experimental and has several limitations:

1. WhatsApp Web's DOM structure and interface labels can change without notice.
2. Contact scanning depends on the structure of the currently rendered contact list.
3. Some contacts may not expose the same editing or deletion controls.
4. Header verification may encounter differences in formatting, initials, or emojis.
5. Phone-synchronised contacts cannot always be distinguished reliably from WhatsApp-only contacts.
6. Simulated browser events may not behave identically to ordinary user interactions.
7. Successful control detection does not guarantee successful deletion.
8. The project has not been comprehensively tested across all WhatsApp Web versions and account configurations.

## Disclaimer

This project is an independent experimental utility and is not affiliated with, endorsed by, or supported by WhatsApp or Meta.

Use it at your own discretion.

Always inspect the source code before executing it in your browser console. Test using Probe first and verify each deletion manually.

The author assumes no responsibility for unintended contact deletion, data loss, account restrictions, or changes to WhatsApp Web that affect the script's behaviour.

**Use responsibly and maintain a backup of important contacts.**

## Project Status

The script has undergone iterative troubleshooting involving:

- Contact-row identification.
- `gridcell` support.
- Conversation-header verification.
- Emoji-aware name comparison.
- Contact editing and deletion-control detection.

It has demonstrated successful probing and sequential deletion in the author's environment, but broader compatibility testing remains necessary.

## License

Choose and add an appropriate open-source licence before distributing this project. Until a licence is added, all rights are reserved by the copyright holder.
