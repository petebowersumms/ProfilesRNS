SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[List.ExportPersonPublicationsList] 
	@UserID int
AS
BEGIN

	SELECT Data 
	FROM (
		SELECT -1 PersonID, '"PersonID","First Name","Last Name","Display Name","PubMed ID","Publication Date","Source (Journal)","Item (Article)","Reference","URL"' Data
		UNION ALL
		SELECT l.PersonID, Data
			FROM [Profile.Data].[List.Member] l
				INNER JOIN [Profile.Cache].[List.Export.Publications] p
					ON l.UserID=@UserID AND l.PersonID=p.PersonID
	) t
	ORDER BY PersonID

END

GO
