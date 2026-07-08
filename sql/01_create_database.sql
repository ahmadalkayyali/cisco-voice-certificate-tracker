IF DB_ID('CertRenewalTracker') IS NULL
BEGIN
    CREATE DATABASE CertRenewalTracker;
END;
GO

USE CertRenewalTracker;
GO
