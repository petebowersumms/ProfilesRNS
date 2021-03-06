SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORNG.].[UpsertAppData](@Uri nvarchar(255),@AppID INT, @Keyname nvarchar(255),@Value nvarchar(4000))
As
BEGIN
	SET NOCOUNT ON
	DECLARE @NodeID bigint
	
	SELECT @NodeID = [RDF.].[fnURI2NodeID](@Uri);
	IF (SELECT COUNT(*) FROM AppData WHERE NodeID = @NodeID AND AppID = @AppID and Keyname = @Keyname) > 0
		UPDATE [ORNG.].[AppData] set [Value] = @Value, updatedDT = GETDATE() WHERE NodeID = @nodeId AND AppID = @AppID and Keyname = @Keyname
	ELSE
		INSERT [ORNG.].[AppData] (NodeID, AppID, Keyname, [Value]) values (@NodeID, @AppID, @Keyname, @Value)
END		

GO
