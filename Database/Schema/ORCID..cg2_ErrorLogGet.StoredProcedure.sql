SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [ORCID.].[cg2_ErrorLogGet]
 
    @ErrorLogID  INT 

AS
 
    SELECT TOP 100 PERCENT
        [ORCID.].[ErrorLog].[ErrorLogID]
        , [ORCID.].[ErrorLog].[InternalUsername]
        , [ORCID.].[ErrorLog].[Exception]
        , [ORCID.].[ErrorLog].[OccurredOn]
        , [ORCID.].[ErrorLog].[Processed]
    FROM
        [ORCID.].[ErrorLog]
    WHERE
        [ORCID.].[ErrorLog].[ErrorLogID] = @ErrorLogID




GO
