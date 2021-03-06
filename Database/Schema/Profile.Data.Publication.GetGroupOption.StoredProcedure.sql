SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[Publication.GetGroupOption]
	@GroupID INT=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	SELECT top 1 [IncludeMemberPublications] FROM [Profile.Data].[Publication.Group.Option] WHERE GroupID = @GroupID AND [IncludeMemberPublications] = 1
END

GO
