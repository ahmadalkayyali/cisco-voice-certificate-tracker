USE CertRenewalTracker;
GO

CREATE OR ALTER VIEW dbo.vw_CertificateInventory AS
SELECT
    c.CertificateID,
    p.PlatformName,
    p.PlatformCategory,
    s.ServerID,
    s.ServerName,
    s.FQDN,
    s.EnvironmentName,
    s.LocationName,
    c.CertificateName,
    c.CertificatePurpose,
    c.Issuer,
    c.SerialNumber,
    c.SubjectName,
    c.SANEntries,
    c.ExpirationDate,
    DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.ExpirationDate) AS DaysUntilExpiration,
    CASE
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.ExpirationDate) < 0 THEN 'Expired'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.ExpirationDate) <= 7 THEN 'Critical'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.ExpirationDate) <= 14 THEN 'High'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.ExpirationDate) <= 30 THEN 'Medium'
        WHEN DATEDIFF(DAY, CAST(GETDATE() AS DATE), c.ExpirationDate) <= 90 THEN 'Watch'
        ELSE 'Healthy'
    END AS RiskStatus,
    c.BusinessImpact,
    c.OwnerTeam,
    c.DependencyNotes,
    c.RenewalDecision,
    c.RenewalStatus,
    c.DoNotRenew,
    c.RetirementDate,
    c.ReplacementSystem,
    c.LastRenewedAt,
    c.LastRenewedBy
FROM dbo.Certificates c
JOIN dbo.Servers s ON s.ServerID = c.ServerID
JOIN dbo.Platforms p ON p.PlatformID = s.PlatformID
WHERE s.IsActive = 1;
GO

CREATE OR ALTER VIEW dbo.vw_ExpiredCertificates AS
SELECT *
FROM dbo.vw_CertificateInventory
WHERE DaysUntilExpiration < 0;
GO

CREATE OR ALTER VIEW dbo.vw_CertificatesExpiringSoon AS
SELECT *
FROM dbo.vw_CertificateInventory
WHERE DaysUntilExpiration BETWEEN 0 AND 90;
GO

CREATE OR ALTER VIEW dbo.vw_CertificateRenewalHistory AS
SELECT
    r.RenewalID,
    c.CertificateID,
    p.PlatformName,
    s.ServerName,
    c.CertificateName,
    r.PreviousExpirationDate,
    r.NewExpirationDate,
    r.ChangeTicket,
    r.RenewalStatus,
    r.ValidationStatus,
    r.ValidationNotes,
    r.RenewedBy,
    r.RenewedAt
FROM dbo.CertificateRenewals r
JOIN dbo.Certificates c ON c.CertificateID = r.CertificateID
JOIN dbo.Servers s ON s.ServerID = c.ServerID
JOIN dbo.Platforms p ON p.PlatformID = s.PlatformID;
GO

CREATE OR ALTER VIEW dbo.vw_DashboardSummary AS
SELECT
    COUNT(*) AS TotalCertificates,
    SUM(CASE WHEN DaysUntilExpiration < 0 THEN 1 ELSE 0 END) AS ExpiredCount,
    SUM(CASE WHEN DaysUntilExpiration BETWEEN 0 AND 7 THEN 1 ELSE 0 END) AS CriticalCount,
    SUM(CASE WHEN DaysUntilExpiration BETWEEN 8 AND 14 THEN 1 ELSE 0 END) AS HighCount,
    SUM(CASE WHEN DaysUntilExpiration BETWEEN 15 AND 30 THEN 1 ELSE 0 END) AS MediumCount,
    SUM(CASE WHEN DaysUntilExpiration BETWEEN 31 AND 90 THEN 1 ELSE 0 END) AS WatchCount,
    SUM(CASE WHEN DaysUntilExpiration > 90 THEN 1 ELSE 0 END) AS HealthyCount
FROM dbo.vw_CertificateInventory;
GO
