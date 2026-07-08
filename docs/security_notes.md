# Security Notes

This project is intended to be a generic certificate lifecycle tracking tool. It should not store private keys, certificate passwords, production secrets, or restricted internal infrastructure details.

## Do not commit

- `.env`
- Passwords
- SQL login secrets
- SMTP credentials
- Real production hostnames if they are confidential
- Real public IP addresses if they are sensitive
- Private keys
- PFX/P12 files
- Internal architecture diagrams
- Screenshots showing customer, employer, or vendor-sensitive data

## Recommended controls

- Use a dedicated SQL login or Windows service account with least privilege.
- Restrict access to the dashboard by network, authentication, or both.
- Use HTTPS when exposing the dashboard beyond localhost.
- Review all sample data before publishing.
- Keep GitHub repository data generic and sanitized.
