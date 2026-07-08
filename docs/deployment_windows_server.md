# Deployment on Windows Server

This is a generic deployment guide. Do not store passwords or production certificate files in the repository.

## 1. Install prerequisites

- Windows Server
- Python 3.x
- Microsoft SQL Server or SQL Server Express
- SQL Server Management Studio
- ODBC Driver 17 or 18 for SQL Server

## 2. Create database

Open SQL Server Management Studio and run the scripts in the `sql` folder in this order:

1. `01_create_database.sql`
2. `02_schema.sql`
3. `03_views.sql`
4. `04_sample_data.sql` optional

## 3. Configure Python application

```powershell
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
copy .env.example .env
notepad .env
```

Update `.env` with local database and email relay settings.

## 4. Start application

```powershell
python app.py
```

Open:

```text
http://localhost:5000/dashboard
```

## 5. Production note

For production, place the app behind IIS, a reverse proxy, or an approved internal web hosting pattern. Use HTTPS, Windows authentication or an approved authentication layer, restricted network access, and proper service accounts.
