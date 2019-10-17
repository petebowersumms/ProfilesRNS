SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[List.AddRemove.SelectedPeople]
	@ListID INT,
	@SelectedPeople VARCHAR(MAX),
	@Remove BIT=0,
	@Size INT=NULL OUTPUT
AS
BEGIN

	-- Get existing list info
	SELECT @Size = Size
		FROM [Profile.Data].[List.General]
		WHERE ListID = @ListID

	-- Get the list of people
	CREATE TABLE #p (PersonID INT PRIMARY KEY)
	DECLARE @x XML
	SELECT @x = CAST('<x>'+REPLACE(@SelectedPeople,',','</x><x>')+'</x>' AS XML)
	INSERT INTO #p
		SELECT DISTINCT r.p.value('.','INT')
		FROM (SELECT @x x) t
			CROSS APPLY t.x.nodes('x') AS r(p)

	BEGIN TRANSACTION
		-- Remove
		IF (@Remove=1)
		BEGIN
			DELETE FROM [Profile.Data].[List.Member]
				WHERE ListID=@ListID AND PersonID IN (SELECT PersonID FROM #p)
		END
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
