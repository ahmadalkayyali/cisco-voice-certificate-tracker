import os
from datetime import date
from flask import Flask, render_template, request, redirect, url_for, flash
from dotenv import load_dotenv
from db import fetch_all, execute

load_dotenv()
app = Flask(__name__)
app.secret_key = os.getenv("APP_SECRET_KEY", "change-this-in-production")


@app.route("/")
def index():
    return redirect(url_for("dashboard"))


@app.route("/dashboard")
def dashboard():
    summary = fetch_all("SELECT * FROM dbo.vw_DashboardSummary")
    expiring = fetch_all("""
        SELECT TOP 25 *
        FROM dbo.vw_CertificatesExpiringSoon
        ORDER BY DaysUntilExpiration ASC, BusinessImpact DESC
    """)
    return render_template("dashboard.html", summary=summary[0] if summary else {}, expiring=expiring)


@app.route("/certificates")
def certificates():
    rows = fetch_all("""
        SELECT CertificateID, PlatformName, ServerName, FQDN, CertificateName,
               CertificatePurpose, Issuer, ExpirationDate, DaysUntilExpiration,
               RiskStatus, BusinessImpact, OwnerTeam, RenewalStatus
        FROM dbo.vw_CertificateInventory
        ORDER BY DaysUntilExpiration ASC, PlatformName, ServerName
    """)
    return render_template("certificates.html", certificates=rows)


@app.route("/certificates/add", methods=["GET", "POST"])
def add_certificate():
    if request.method == "POST":
        params = [
            request.form.get("server_id"),
            request.form.get("certificate_name"),
            request.form.get("certificate_purpose"),
            request.form.get("issuer"),
            request.form.get("serial_number"),
            request.form.get("subject_name"),
            request.form.get("san_entries"),
            request.form.get("expiration_date"),
            request.form.get("business_impact"),
            request.form.get("owner_team"),
            request.form.get("renewal_status"),
            request.form.get("dependency_notes"),
        ]
        execute("""
            INSERT INTO dbo.Certificates
            (ServerID, CertificateName, CertificatePurpose, Issuer, SerialNumber,
             SubjectName, SANEntries, ExpirationDate, BusinessImpact, OwnerTeam,
             RenewalStatus, DependencyNotes)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        """, params)
        flash("Certificate record added.", "success")
        return redirect(url_for("certificates"))

    servers = fetch_all("""
        SELECT s.ServerID, p.PlatformName, s.ServerName, s.FQDN
        FROM dbo.Servers s
        JOIN dbo.Platforms p ON p.PlatformID = s.PlatformID
        WHERE s.IsActive = 1
        ORDER BY p.PlatformName, s.ServerName
    """)
    return render_template("certificate_form.html", servers=servers)


@app.route("/servers")
def servers():
    rows = fetch_all("""
        SELECT p.PlatformName, s.ServerName, s.FQDN, s.EnvironmentName,
               s.LocationName, s.OwnerTeam, s.IsActive
        FROM dbo.Servers s
        JOIN dbo.Platforms p ON p.PlatformID = s.PlatformID
        ORDER BY p.PlatformName, s.ServerName
    """)
    return render_template("servers.html", servers=rows)


@app.route("/notifications")
def notifications():
    rows = fetch_all("""
        SELECT TOP 100 NotificationID, CertificateID, ReminderType, SentTo,
               SentAt, DeliveryStatus, ErrorMessage
        FROM dbo.NotificationLog
        ORDER BY SentAt DESC
    """)
    return render_template("notifications.html", notifications=rows)


@app.route("/scheduler-health")
def scheduler_health():
    rows = fetch_all("""
        SELECT TOP 100 RunID, JobName, StartedAt, FinishedAt, RunStatus,
               CertificatesChecked, NotificationsSent, ErrorMessage
        FROM dbo.SchedulerRunLog
        ORDER BY StartedAt DESC
    """)
    return render_template("scheduler_health.html", runs=rows)


if __name__ == "__main__":
    host = os.getenv("APP_HOST", "0.0.0.0")
    port = int(os.getenv("APP_PORT", "5000"))
    debug = os.getenv("APP_DEBUG", "false").lower() == "true"
    app.run(host=host, port=port, debug=debug)
