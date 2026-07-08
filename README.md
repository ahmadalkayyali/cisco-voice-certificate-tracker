# Cisco Voice Certificate Tracker

A generic, free-to-use certificate lifecycle tracking application for Cisco voice and contact center environments.

This project is designed to help voice engineering teams track certificate expiration, renewal ownership, reminder status, and operational validation across platforms such as CUCM, Expressway, CUBE, Finesse, CVP, VVB, UCCE, CUIC, Live Data, recording integrations, and other voice infrastructure components.

The application is intentionally generic. It does **not** include passwords, internal hostnames, real IP addresses, employer data, or production certificates.

## What it does

- Tracks voice platforms, servers, and certificate records.
- Shows expired, critical, warning, and healthy certificate counts.
- Stores certificate purpose, issuer, SAN values, dependency, owner, and expiration date.
- Tracks renewal tasks, renewal decisions, and engineering actions/notes.
- Sends reminder emails for certificates reaching configured thresholds.
- Logs notification history to avoid duplicate reminders.
- Logs Windows Task Scheduler runs for operational visibility.
- Provides dashboard, certificates, servers, notifications, and scheduler health pages.

## Technology stack

- Python 3
- Flask
- Microsoft SQL Server / SQL Server Express
- pyodbc
- Windows Server Task Scheduler
- Optional IIS reverse proxy or internal hosting

## Repository structure

```text
cisco-voice-certificate-tracker/
├── app.py
├── db.py
├── send_certificate_reminders.py
├── test_email.py
├── requirements.txt
├── .env.example
├── .gitignore
├── LICENSE
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_schema.sql
│   ├── 03_views.sql
│   └── 04_sample_data.sql
├── templates/
│   ├── base.html
│   ├── dashboard.html
│   ├── certificates.html
│   ├── certificate_form.html
│   ├── servers.html
│   ├── notifications.html
│   └── scheduler_health.html
└── docs/
    ├── deployment_windows_server.md
    ├── windows_task_scheduler.md
    └── security_notes.md
```

## Quick start

1. Install SQL Server Express or use an existing Microsoft SQL Server instance.
2. Open SQL Server Management Studio.
3. Run the SQL scripts in order:
   - `sql/01_create_database.sql`
   - `sql/02_schema.sql`
   - `sql/03_views.sql`
   - `sql/04_sample_data.sql` optional
4. Create a Python virtual environment:

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

5. Copy `.env.example` to `.env` and update the values for your environment.
6. Run the dashboard:

```powershell
python app.py
```

7. Open the dashboard:

```text
http://localhost:5000/dashboard
```

8. Configure Windows Task Scheduler to run `send_certificate_reminders.py` daily.

## Important security note

Do not commit `.env`, passwords, internal hostnames, production data, private keys, certificate files, or screenshots from a real enterprise environment to GitHub.

## License

This project is provided under the MIT License. Review the license before publishing or using it in production.
