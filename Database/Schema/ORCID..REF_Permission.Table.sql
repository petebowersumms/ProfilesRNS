SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING OFF
GO
CREATE TABLE [ORCID.].[REF_Permission](
	[PermissionID] [tinyint] IDENTITY(1,1) NOT NULL,
	[PermissionScope] [varchar](100) NOT NULL,
	[PermissionDescription] [varchar](500) NOT NULL,
	[MethodAndRequest] [varchar](100) NULL,
	[SuccessMessage] [varchar](1000) NULL,
	[FailedMessage] [varchar](1000) NULL,
 CONSTRAINT [PK_REF_Permission] PRIMARY KEY CLUSTERED 
(
	[PermissionID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
SET ANSI_PADDING OFF
GO
