SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [ORCID.].[cg2_GroupGet]
 
    @SecurityGroupID  BIGINT 

AS
 
    SELECT TOP 100 PERCENT
        [RDF.Security].[Group].[SecurityGroupID]
        , [RDF.Security].[Group].[Label]
        , [RDF.Security].[Group].[HasSpecialViewAccess]
        , [RDF.Security].[Group].[HasSpecialEditAccess]
        , [RDF.Security].[Group].[Description]
        , [ORCID.].[DefaultORCIDDecisionIDMapping].[DefaultORCIDDecisionID]
    FROM
        [RDF.Security].[Group]
		join [ORCID.].[DefaultORCIDDecisionIDMapping]
		on [RDF.Security].[Group].SecurityGroupID = [ORCID.].[DefaultORCIDDecisionIDMapping].SecurityGroupID
    WHERE
        [RDF.Security].[Group].[SecurityGroupID] = @SecurityGroupID



GO
