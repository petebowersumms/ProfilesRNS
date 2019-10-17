SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[List.AddRemove.Search]
	@ListID INT,
	@SearchXML XML,
	@SessionID UNIQUEIDENTIFIER,
	@Remove BIT=0,
	@Size INT=NULL OUTPUT
AS
BEGIN

	-- Get existing list info
	SELECT @Size = Size
		FROM [Profile.Data].[List.General]
		WHERE ListID = @ListID

	-- Construct a search XML
	DECLARE @MatchOptions VARCHAR(MAX)
	DECLARE @SearchOptions XML
	SELECT @MatchOptions = CAST(t.p.query('.') AS VARCHAR(MAX))
		FROM @SearchXML.nodes('/SearchOptions/MatchOptions') AS t(p)
	SELECT @SearchOptions = 
		'<SearchOptions>' + 
			@MatchOptions +
			'<OutputOptions>
				<Offset>0</Offset>
				<Limit>100000</Limit>
			</OutputOptions>	
		</SearchOptions>'

	-- Get the list of matching people
	CREATE TABLE #Node (
		SortOrder bigint primary key,
		NodeID bigint,
		Paths bigint,
		Weight float,
		PersonID int
	)
	INSERT INTO #Node (SortOrder, NodeID, Paths, Weight) 
		EXEC [Search.].[GetNodes] @SearchOptions=@SearchOptions, @NoRDF=1, @SessionID=@SessionID
	UPDATE n SET PersonID = m.InternalID 
		FROM #Node n
			INNER JOIN [RDF.Stage].InternalNodeMap m 
				ON Class = 'http://xmlns.com/foaf/0.1/Person' AND InternalType = 'Person' AND n.NodeID = m.NodeID

	-- Add or Remove
	BEGIN TRANSACTION
		-- Add
		IF (@Remove=0)
			INSERT INTO [Profile.Data].[List.Member] (ListID, PersonID)
				SELECT @ListID, PersonID
					FROM #Node n
					WHERE NOT EXISTS (
						SELECT *
						FROM [Profile.Data].[List.Member] l
						WHERE l.ListID=@ListID AND n.PersonID=l.PersonID
					)
		-- Remove
		IF (@Remove=1)
			DELETE l
				FROM [Profile.Data].[List.Member] l
					INNER JOIN #Node n
						ON l.ListID=@ListID AND l.PersonID=n.PersonID
		-- Update list size
		UPDATE [Profile.Data].[List.General]
			SET Size = (SELECT COUNT(*) FROM [Profile.Data].[List.Member] WHERE ListID=@ListID)
			WHERE ListID = @ListID
		SELECT @Size = Size
			FROM [Profile.Data].[List.General]
			WHERE ListID=@ListID
	COMMIT TRANSACTION

END

GO
