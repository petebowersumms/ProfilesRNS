SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [ORCID.].[RecordLevelAuditTrail](
	[RecordLevelAuditTrailID] [bigint] IDENTITY(1,1) NOT NULL,
	[MetaTableID] [int] NOT NULL,
	[RowIdentifier] [bigint] NOT NULL,
	[RecordLevelAuditTypeID] [tinyint] NOT NULL,
	[CreatedDate] [smalldatetime] NOT NULL,
	[CreatedBy] [varchar](10) NOT NULL,
 CONSTRAINT [PK_RecordLevelAuditTrail] PRIMARY KEY CLUSTERED 
(
	[RecordLevelAuditTrailID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
ALTER TABLE [ORCID.].[RecordLevelAuditTrail] ADD  CONSTRAINT [DF_RecordLevelAuditTrail_CreatedDate]  DEFAULT (getdate()) FOR [CreatedDate]
GO
ALTER TABLE [ORCID.].[RecordLevelAuditTrail]  WITH CHECK ADD  CONSTRAINT [FK_RecordLevelAuditTrail_RecordLevelAuditType] FOREIGN KEY([RecordLevelAuditTypeID])
REFERENCES [ORCID.].[RecordLevelAuditType] ([RecordLevelAuditTypeID])
ON UPDATE CASCADE
GO
ALTER TABLE [ORCID.].[RecordLevelAuditTrail] CHECK CONSTRAINT [FK_RecordLevelAuditTrail_RecordLevelAuditType]
GO
