SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [Profile.Data].[List.AddRemove.Filter]
	@ListID INT,
	@Institution VARCHAR(1000)=NULL,
	@FacultyRank VARCHAR(100)=NULL,
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
	INSERT INTO #p
		SELECT l.PersonID
			FROM [Profile.Data].[List.Member] l
				LEFT OUTER JOIN [Profile.Cache].[Person] p
					ON l.PersonID=p.PersonID
			WHERE l.ListID=@ListID AND
				(CASE WHEN @Institution IS NULL THEN 1
					WHEN @Institution = p.InstitutionName THEN 1
					ELSE 0 END)
				+(CASE WHEN @FacultyRank IS NULL THEN 1
					WHEN @FacultyRank = p.FacultyRank THEN 1
					ELSE 0 END)
				=2

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
