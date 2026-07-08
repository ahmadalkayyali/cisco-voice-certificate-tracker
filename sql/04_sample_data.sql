USE CertRenewalTracker;
GO

INSERT INTO dbo.Platforms (PlatformName, PlatformCategory, Notes)
VALUES
('CUCM', 'Call Control', 'Cisco Unified Communications Manager'),
('Expressway', 'Edge / MRA', 'Expressway-C and Expressway-E'),
('CUBE', 'Voice Edge', 'Cisco Unified Border Element'),
('Finesse', 'Contact Center Desktop', 'Cisco Finesse agent desktop'),
('CVP', 'Contact Center IVR', 'Cisco Customer Voice Portal'),
('VVB', 'Contact Center Media', 'Cisco Virtualized Voice Browser'),
('CUIC / Live Data', 'Reporting', 'Cisco reporting and real-time data');
GO

INSERT INTO dbo.Servers (PlatformID, ServerName, FQDN, EnvironmentName, LocationName, OwnerTeam)
SELECT PlatformID, 'voice-node-01', 'voice-node-01.example.local', 'Production', 'Primary Data Center', 'Voice Engineering'
FROM dbo.Platforms WHERE PlatformName = 'CUCM';

INSERT INTO dbo.Servers (PlatformID, ServerName, FQDN, EnvironmentName, LocationName, OwnerTeam)
SELECT PlatformID, 'expressway-edge-01', 'expressway-edge-01.example.com', 'Production', 'DMZ', 'Voice Engineering'
FROM dbo.Platforms WHERE PlatformName = 'Expressway';

INSERT INTO dbo.Servers (PlatformID, ServerName, FQDN, EnvironmentName, LocationName, OwnerTeam)
SELECT PlatformID, 'cube-edge-01', 'cube-edge-01.example.local', 'Production', 'Primary Data Center', 'Voice Engineering'
FROM dbo.Platforms WHERE PlatformName = 'CUBE';

INSERT INTO dbo.Servers (PlatformID, ServerName, FQDN, EnvironmentName, LocationName, OwnerTeam)
SELECT PlatformID, 'finesse-a', 'finesse-a.example.local', 'Production', 'Primary Data Center', 'Contact Center Engineering'
FROM dbo.Platforms WHERE PlatformName = 'Finesse';
GO

INSERT INTO dbo.Certificates
(ServerID, CertificateName, CertificatePurpose, Issuer, SubjectName, SANEntries,
 ExpirationDate, BusinessImpact, OwnerTeam, RenewalStatus, DependencyNotes)
SELECT ServerID, 'tomcat', 'HTTPS / Admin UI', 'Example Internal CA', 'CN=voice-node-01.example.local',
       'DNS:voice-node-01.example.local', DATEADD(DAY, 72, CAST(GETDATE() AS DATE)),
       'High', 'Voice Engineering', 'Not Started', 'Used for CUCM web administration and application trust.'
FROM dbo.Servers WHERE ServerName = 'voice-node-01';

INSERT INTO dbo.Certificates
(ServerID, CertificateName, CertificatePurpose, Issuer, SubjectName, SANEntries,
 ExpirationDate, BusinessImpact, OwnerTeam, RenewalStatus, DependencyNotes)
SELECT ServerID, 'server', 'Expressway Server Certificate', 'Public CA', 'CN=expressway-edge-01.example.com',
       'DNS:expressway-edge-01.example.com', DATEADD(DAY, 41, CAST(GETDATE() AS DATE)),
       'Critical', 'Voice Engineering', 'Planning', 'Used for external access, traversal, and secure edge services.'
FROM dbo.Servers WHERE ServerName = 'expressway-edge-01';

INSERT INTO dbo.Certificates
(ServerID, CertificateName, CertificatePurpose, Issuer, SubjectName, SANEntries,
 ExpirationDate, BusinessImpact, OwnerTeam, RenewalStatus, DependencyNotes)
SELECT ServerID, 'sip-tls-trustpoint', 'SIP TLS Trustpoint', 'Example Internal CA', 'CN=cube-edge-01.example.local',
       'DNS:cube-edge-01.example.local', DATEADD(DAY, 55, CAST(GETDATE() AS DATE)),
       'Critical', 'Voice Engineering', 'Not Started', 'Used for secure SIP signaling.'
FROM dbo.Servers WHERE ServerName = 'cube-edge-01';

INSERT INTO dbo.Certificates
(ServerID, CertificateName, CertificatePurpose, Issuer, SubjectName, SANEntries,
 ExpirationDate, BusinessImpact, OwnerTeam, RenewalStatus, DependencyNotes)
SELECT ServerID, 'tomcat', 'Finesse Agent Desktop HTTPS', 'Example Internal CA', 'CN=finesse-a.example.local',
       'DNS:finesse-a.example.local', DATEADD(DAY, 28, CAST(GETDATE() AS DATE)),
       'Critical', 'Contact Center Engineering', 'In Progress', 'Used by agent desktop and contact center web access.'
FROM dbo.Servers WHERE ServerName = 'finesse-a';
GO
