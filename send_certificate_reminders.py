import os
import smtplib
from email.message import EmailMessage
from datetime import datetime
from dotenv import load_dotenv
from db import fetch_all, execute

load_dotenv()
JOB_NAME = "CiscoVoiceCertificateReminder"
REMINDER_DAYS = [90, 60, 30, 14, 7]


def bool_env(name: str, default: str = "false") -> bool:
    return os.getenv(name, default).strip().lower() in {"1", "true", "yes", "y"}


def get_setting(name: str, fallback: str = "") -> str:
    rows = fetch_all("SELECT SettingValue FROM dbo.AppSettings WHERE SettingName = ?", [name])
    if rows:
        return rows[0]["SettingValue"]
    return fallback


def send_email(to_address: str, subject: str, body: str):
    smtp_server = os.getenv("SMTP_SERVER", "")
    smtp_port = int(os.getenv("SMTP_PORT", "587"))
    smtp_user = os.getenv("SMTP_USER", "")
    smtp_password = os.getenv("SMTP_PASSWORD", "")
    use_tls = bool_env("SMTP_USE_TLS", "true")
    from_address = os.getenv("EMAIL_FROM", "cert-tracker@example.com")

    if not smtp_server:
        raise RuntimeError("SMTP_SERVER is not configured.")

    msg = EmailMessage()
    msg["From"] = from_address
    msg["To"] = to_address
    msg["Subject"] = subject
    msg.set_content(body)

    with smtplib.SMTP(smtp_server, smtp_port, timeout=30) as smtp:
        if use_tls:
            smtp.starttls()
        if smtp_user:
            smtp.login(smtp_user, smtp_password)
        smtp.send_message(msg)


def log_scheduler_start():
    execute("""
        INSERT INTO dbo.SchedulerRunLog (JobName, StartedAt, RunStatus)
        VALUES (?, SYSDATETIME(), 'Running')
    """, [JOB_NAME])
    row = fetch_all("SELECT MAX(RunID) AS RunID FROM dbo.SchedulerRunLog WHERE JobName = ?", [JOB_NAME])
    return row[0]["RunID"]


def log_scheduler_finish(run_id, status, checked, sent, error=None):
    execute("""
        UPDATE dbo.SchedulerRunLog
        SET FinishedAt = SYSDATETIME(), RunStatus = ?, CertificatesChecked = ?,
            NotificationsSent = ?, ErrorMessage = ?
        WHERE RunID = ?
    """, [status, checked, sent, error, run_id])


def main():
    run_id = log_scheduler_start()
    sent_count = 0
    checked_count = 0
    try:
        target_email = get_setting("NotificationToEmail", os.getenv("EMAIL_TO", "voice-team@example.com"))
        rows = fetch_all("""
            SELECT CertificateID, PlatformName, ServerName, FQDN, CertificateName,
                   CertificatePurpose, ExpirationDate, DaysUntilExpiration,
                   BusinessImpact, OwnerTeam
            FROM dbo.vw_CertificateInventory
            WHERE DaysUntilExpiration IN (90, 60, 30, 14, 7)
               OR DaysUntilExpiration < 0
            ORDER BY DaysUntilExpiration ASC
        """)
        checked_count = len(rows)

        for cert in rows:
            days = cert["DaysUntilExpiration"]
            reminder_type = "Expired" if days < 0 else f"{days}DayReminder"
            existing = fetch_all("""
                SELECT NotificationID
                FROM dbo.NotificationLog
                WHERE CertificateID = ? AND ReminderType = ? AND SentTo = ?
            """, [cert["CertificateID"], reminder_type, target_email])
            if existing:
                continue

            subject = f"Certificate Alert: {cert['CertificateName']} on {cert['ServerName']}"
            body = f"""
Certificate lifecycle alert

Platform: {cert['PlatformName']}
Server: {cert['ServerName']}
FQDN: {cert['FQDN']}
Certificate: {cert['CertificateName']}
Purpose: {cert['CertificatePurpose']}
Expiration date: {cert['ExpirationDate']}
Days until expiration: {cert['DaysUntilExpiration']}
Business impact: {cert['BusinessImpact']}
Owner team: {cert['OwnerTeam']}

Please review the renewal plan, change window, trust chain, and post-change validation steps.
""".strip()
            try:
                send_email(target_email, subject, body)
                execute("""
                    INSERT INTO dbo.NotificationLog
                    (CertificateID, ReminderType, SentTo, SentAt, DeliveryStatus)
                    VALUES (?, ?, ?, SYSDATETIME(), 'Sent')
                """, [cert["CertificateID"], reminder_type, target_email])
                sent_count += 1
            except Exception as exc:
                execute("""
                    INSERT INTO dbo.NotificationLog
                    (CertificateID, ReminderType, SentTo, SentAt, DeliveryStatus, ErrorMessage)
                    VALUES (?, ?, ?, SYSDATETIME(), 'Failed', ?)
                """, [cert["CertificateID"], reminder_type, target_email, str(exc)])

        log_scheduler_finish(run_id, "Success", checked_count, sent_count)
    except Exception as exc:
        log_scheduler_finish(run_id, "Failed", checked_count, sent_count, str(exc))
        raise


if __name__ == "__main__":
    main()
