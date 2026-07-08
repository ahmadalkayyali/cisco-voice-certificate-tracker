from send_certificate_reminders import send_email
import os

if __name__ == "__main__":
    target = os.getenv("EMAIL_TO", "voice-team@example.com")
    send_email(
        target,
        "Cisco Voice Certificate Tracker Test Email",
        "This is a test message from the certificate lifecycle tracker."
    )
    print(f"Test email sent to {target}")
