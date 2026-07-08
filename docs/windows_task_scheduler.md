# Windows Task Scheduler Setup

Use Windows Task Scheduler to run the reminder script daily.

## Recommended schedule

- Frequency: Daily
- Time: Early morning before business hours
- Script: `send_certificate_reminders.py`
- Working directory: root folder of the project
- Account: approved service account with least privilege

## Example action

Program/script:

```text
C:\Path\To\Project\.venv\Scripts\python.exe
```

Add arguments:

```text
C:\Path\To\Project\send_certificate_reminders.py
```

Start in:

```text
C:\Path\To\Project
```

## Validation

After creating the task:

1. Run it manually once.
2. Confirm a row appears in `dbo.SchedulerRunLog`.
3. Confirm `RunStatus = Success`.
4. Confirm expected notifications appear in `dbo.NotificationLog`.
5. Confirm duplicate reminders are not sent for the same certificate/reminder type/recipient.
