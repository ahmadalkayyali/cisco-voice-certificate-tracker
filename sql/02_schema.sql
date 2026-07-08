USE CertRenewalTracker;
GO

IF OBJECT_ID('dbo.CertificateActions', 'U') IS NOT NULL DROP TABLE dbo.CertificateActions;
IF OBJECT_ID('dbo.CertificateRenewals', 'U') IS NOT NULL DROP TABLE dbo.CertificateRenewals;
IF OBJECT_ID('dbo.NotificationLog', 'U') IS NOT NULL DROP TABLE dbo.NotificationLog;
IF OBJECT_ID('dbo.SchedulerRunLog', 'U') IS NOT NULL DROP TABLE dbo.SchedulerRunLog;
IF OBJECT_ID('dbo.Certificates', 'U') IS NOT NULL DROP TABLE dbo.Certificates;
IF OBJECT_ID('dbo.Servers', 'U') IS NOT NULL DROP TABLE dbo.Servers;
IF OBJECT_ID('dbo.Platforms', 'U') IS NOT NULL DROP TABLE dbo.Platforms;
IF OBJECT_ID('dbo.AppSettings', 'U') IS NOT NULL DROP TABLE dbo.AppSettings;
GO

CREATE TABLE dbo.Platforms
(
    PlatformID INT IDENTITY(1,1) PRIMARY KEY,
    PlatformName NVARCHAR(100) NOT NULL UNIQUE,
    PlatformCategory NVARCHAR(100) NULL,
    Notes NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

CREATE TABLE dbo.Servers
(
    ServerID INT IDENTITY(1,1) PRIMARY KEY,
    PlatformID INT NOT NULL,
    ServerName NVARCHAR(150) NOT NULL,
    FQDN NVARCHAR(255) NULL,
    EnvironmentName NVARCHAR(50) NOT NULL DEFAULT 'Production',
    LocationName NVARCHAR(100) NULL,
    OwnerTeam NVARCHAR(100) NULL,
    IsActive BIT NOT NULL DEFAULT 1,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_Servers_Platforms FOREIGN KEY (PlatformID) REFERENCES dbo.Platforms(PlatformID)
);
GO

CREATE TABLE dbo.Certificates
(
    CertificateID INT IDENTITY(1,1) PRIMARY KEY,
    ServerID INT NOT NULL,
    CertificateName NVARCHAR(150) NOT NULL,
    CertificatePurpose NVARCHAR(100) NOT NULL,
    Issuer NVARCHAR(255) NULL,
    SerialNumber NVARCHAR(255) NULL,
    SubjectName NVARCHAR(255) NULL,
    SANEntries NVARCHAR(MAX) NULL,
    ExpirationDate DATE NOT NULL,
    BusinessImpact NVARCHAR(50) NOT NULL DEFAULT 'Medium',
    OwnerTeam NVARCHAR(100) NULL,
    DependencyNotes NVARCHAR(MAX) NULL,
    RenewalDecision NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    RenewalStatus NVARCHAR(50) NOT NULL DEFAULT 'Not Started',
    DoNotRenew BIT NOT NULL DEFAULT 0,
    RetirementDate DATE NULL,
    ReplacementSystem NVARCHAR(255) NULL,
    LastRenewedAt DATETIME2 NULL,
    LastRenewedBy NVARCHAR(100) NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    UpdatedAt DATETIME2 NULL,
    CONSTRAINT FK_Certificates_Servers FOREIGN KEY (ServerID) REFERENCES dbo.Servers(ServerID)
);
GO

CREATE TABLE dbo.CertificateRenewals
(
    RenewalID INT IDENTITY(1,1) PRIMARY KEY,
    CertificateID INT NOT NULL,
    PreviousExpirationDate DATE NULL,
    NewExpirationDate DATE NULL,
    ChangeTicket NVARCHAR(100) NULL,
    RenewalStatus NVARCHAR(50) NOT NULL DEFAULT 'Planned',
    ValidationStatus NVARCHAR(50) NULL,
    ValidationNotes NVARCHAR(MAX) NULL,
    RenewedBy NVARCHAR(100) NULL,
    RenewedAt DATETIME2 NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CertificateRenewals_Certificates FOREIGN KEY (CertificateID) REFERENCES dbo.Certificates(CertificateID)
);
GO

CREATE TABLE dbo.CertificateActions
(
    ActionID INT IDENTITY(1,1) PRIMARY KEY,
    CertificateID INT NOT NULL,
    ActionType NVARCHAR(100) NOT NULL,
    ActionNotes NVARCHAR(MAX) NULL,
    ActionOwner NVARCHAR(100) NULL,
    ActionDate DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    CONSTRAINT FK_CertificateActions_Certificates FOREIGN KEY (CertificateID) REFERENCES dbo.Certificates(CertificateID)
);
GO

CREATE TABLE dbo.NotificationLog
(
    NotificationID INT IDENTITY(1,1) PRIMARY KEY,
    CertificateID INT NULL,
    ReminderType NVARCHAR(50) NOT NULL,
    SentTo NVARCHAR(255) NOT NULL,
    SentAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    DeliveryStatus NVARCHAR(50) NOT NULL,
    ErrorMessage NVARCHAR(MAX) NULL,
    CONSTRAINT FK_NotificationLog_Certificates FOREIGN KEY (CertificateID) REFERENCES dbo.Certificates(CertificateID)
);
GO

CREATE TABLE dbo.SchedulerRunLog
(
    RunID INT IDENTITY(1,1) PRIMARY KEY,
    JobName NVARCHAR(100) NOT NULL,
    StartedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    FinishedAt DATETIME2 NULL,
    RunStatus NVARCHAR(50) NOT NULL,
    CertificatesChecked INT NULL,
    NotificationsSent INT NULL,
    ErrorMessage NVARCHAR(MAX) NULL
);
GO

CREATE TABLE dbo.AppSettings
(
    SettingName NVARCHAR(100) PRIMARY KEY,
    SettingValue NVARCHAR(MAX) NULL,
    UpdatedAt DATETIME2 NOT NULL DEFAULT SYSDATETIME()
);
GO

INSERT INTO dbo.AppSettings (SettingName, SettingValue)
VALUES
('NotificationToEmail', 'voice-team@example.com'),
('ReminderDays', '90,60,30,14,7');
GO
