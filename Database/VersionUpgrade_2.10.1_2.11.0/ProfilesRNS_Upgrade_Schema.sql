/*
Run this script on:

        Profiles 2.10.1   -  This database will be modified

to synchronize it with:

        Profiles 2.11.0

You are recommended to back up your database before running this script

Details of which objects have changed can be found in the release notes.
If you have made changes to existing tables or stored procedures in profiles, you may need to merge changes individually. 

*/

GO
PRINT N'Creating [Profile.Data].[Group.Admin]...';


GO
CREATE TABLE [Profile.Data].[Group.Admin] (
    [UserID] INT NOT NULL,
    PRIMARY KEY CLUSTERED ([UserID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Group.General]...';


GO
CREATE TABLE [Profile.Data].[Group.General] (
    [GroupID]           INT           IDENTITY (1, 1) NOT NULL,
    [GroupName]         VARCHAR (400) NULL,
    [ViewSecurityGroup] BIGINT        NULL,
    [CreateDate]        DATETIME      NULL,
    [EndDate]           DATETIME      NULL,
    PRIMARY KEY CLUSTERED ([GroupID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Group.Manager]...';


GO
CREATE TABLE [Profile.Data].[Group.Manager] (
    [GroupID] INT NOT NULL,
    [UserID]  INT NOT NULL,
    PRIMARY KEY CLUSTERED ([GroupID] ASC, [UserID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Group.Member]...';


GO
CREATE TABLE [Profile.Data].[Group.Member] (
    [MemberRoleID] VARCHAR (50)   NOT NULL,
    [GroupID]      INT            NOT NULL,
    [UserID]       INT            NOT NULL,
    [IsActive]     BIT            NULL,
    [IsApproved]   BIT            NULL,
    [IsVisible]    BIT            NULL,
    [Title]        NVARCHAR (255) NULL,
    [IsFeatured]   BIT            NULL,
    [SortOrder]    INT            NULL,
    PRIMARY KEY CLUSTERED ([MemberRoleID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Group.Photo]...';


GO
CREATE TABLE [Profile.Data].[Group.Photo] (
    [PhotoID]   INT             IDENTITY (1, 1) NOT NULL,
    [GroupID]   INT             NOT NULL,
    [Photo]     VARBINARY (MAX) NULL,
    [PhotoLink] NVARCHAR (MAX)  NULL,
    PRIMARY KEY CLUSTERED ([PhotoID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Publication.Group.Include]...';


GO
CREATE TABLE [Profile.Data].[Publication.Group.Include] (
    [PubID]   UNIQUEIDENTIFIER NOT NULL,
    [GroupID] INT              NULL,
    [PMID]    INT              NULL,
    [MPID]    NVARCHAR (50)    NULL,
    PRIMARY KEY CLUSTERED ([PubID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Publication.Group.MyPub.General]...';


GO
CREATE TABLE [Profile.Data].[Publication.Group.MyPub.General] (
    [MPID]             NVARCHAR (50)   NOT NULL,
    [GroupID]          INT             NULL,
    [PMID]             NVARCHAR (15)   NULL,
    [HmsPubCategory]   NVARCHAR (60)   NULL,
    [NlmPubCategory]   NVARCHAR (250)  NULL,
    [PubTitle]         NVARCHAR (2000) NULL,
    [ArticleTitle]     NVARCHAR (2000) NULL,
    [ArticleType]      NVARCHAR (30)   NULL,
    [ConfEditors]      NVARCHAR (2000) NULL,
    [ConfLoc]          NVARCHAR (2000) NULL,
    [EDITION]          NVARCHAR (30)   NULL,
    [PlaceOfPub]       NVARCHAR (60)   NULL,
    [VolNum]           NVARCHAR (30)   NULL,
    [PartVolPub]       NVARCHAR (15)   NULL,
    [IssuePub]         NVARCHAR (30)   NULL,
    [PaginationPub]    NVARCHAR (30)   NULL,
    [AdditionalInfo]   NVARCHAR (2000) NULL,
    [Publisher]        NVARCHAR (255)  NULL,
    [SecondaryAuthors] NVARCHAR (2000) NULL,
    [ConfNm]           NVARCHAR (2000) NULL,
    [ConfDTs]          NVARCHAR (60)   NULL,
    [ReptNumber]       NVARCHAR (35)   NULL,
    [ContractNum]      NVARCHAR (35)   NULL,
    [DissUnivNm]       NVARCHAR (2000) NULL,
    [NewspaperCol]     NVARCHAR (15)   NULL,
    [NewspaperSect]    NVARCHAR (15)   NULL,
    [PublicationDT]    SMALLDATETIME   NULL,
    [Abstract]         VARCHAR (MAX)   NULL,
    [Authors]          VARCHAR (MAX)   NULL,
    [URL]              VARCHAR (1000)  NULL,
    [CreatedDT]        DATETIME        NULL,
    [CreatedBy]        VARCHAR (50)    NULL,
    [UpdatedDT]        DATETIME        NULL,
    [UpdatedBy]        VARCHAR (50)    NULL,
    [CopiedMPID]       NVARCHAR (50)   NULL,
    PRIMARY KEY CLUSTERED ([MPID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[Publication.Group.Option]...';


GO
CREATE TABLE [Profile.Data].[Publication.Group.Option] (
    [GroupID]                   INT NOT NULL,
    [IncludeMemberPublications] BIT NULL,
    PRIMARY KEY CLUSTERED ([GroupID] ASC)
);


GO
PRINT N'Creating [Profile.Data].[vwGroup.GeneralWithDeleted]...';


GO

CREATE VIEW [Profile.Data].[vwGroup.GeneralWithDeleted] AS 
	SELECT GroupID, GroupName, g.ViewSecurityGroup, ISNULL(m.NodeID,-40) EditSecurityGroup, CreateDate, EndDate,
		(case when g.ViewSecurityGroup = 0 then 'Deleted' when g.ViewSecurityGroup > 0 then 'Private' else isnull(s.Label,'Unknown') end) ViewSecurityGroupName, 
		m.NodeID GroupNodeID
	FROM [Profile.Data].[Group.General] g
		LEFT OUTER JOIN [RDF.Security].[Group] s
			ON g.ViewSecurityGroup = s.SecurityGroupID
		LEFT OUTER JOIN [RDF.Stage].InternalNodeMap m
			ON m.Class = 'http://xmlns.com/foaf/0.1/Group' AND m.InternalType = 'Group' AND InternalID = g.GroupID
		LEFT OUTER JOIN [RDF.].[Node] n
			ON m.NodeID = n.NodeID
GO
PRINT N'Creating [Profile.Data].[vwGroup.Manager]...';


GO

CREATE VIEW [Profile.Data].[vwGroup.Manager] AS 
	SELECT m.GroupID, m.UserID, g.ViewSecurityGroup, -40 EditSecurityGroup
	FROM [Profile.Data].[Group.Manager] m
		INNER JOIN [Profile.Data].[Group.General] g
			ON g.GroupID = m.GroupID
	WHERE g.ViewSecurityGroup <> 0
GO
PRINT N'Creating [Profile.Data].[vwGroup.Member]...';


GO
CREATE VIEW [Profile.Data].[vwGroup.Member] AS 
	SELECT m.MemberRoleID, m.GroupID, m.UserID, u.PersonID, m.IsActive, m.IsApproved, m.IsVisible, m.Title, m.IsFeatured, m.SortOrder, g.ViewSecurityGroup, -40 EditSecurityGroup
	FROM [Profile.Data].[Group.Member] m
		INNER JOIN [Profile.Data].[Group.General] g
			ON g.GroupID = m.GroupID
		INNER JOIN [User.Account].[User] u
			ON m.UserID = u.UserID
	WHERE (m.IsActive=1) AND (m.IsApproved=1) AND (m.IsVisible=1) AND (u.PersonID IS NOT NULL) and (g.ViewSecurityGroup <> 0)
GO
PRINT N'Creating [Profile.Data].[vwGroup.Photo]...';


GO

CREATE VIEW [Profile.Data].[vwGroup.Photo]
AS
SELECT p.*, m.NodeID GroupNodeID, o.Value+'Modules/CustomViewPersonGeneralInfo/PhotoHandler.ashx?NodeID='+CAST(m.NodeID as varchar(50)) URI
FROM [Profile.Data].[Group.Photo] p
	INNER JOIN [RDF.Stage].[InternalNodeMap] m
		ON m.Class = 'http://xmlns.com/foaf/0.1/Group'
			AND m.InternalType = 'Group'
			AND m.InternalID = CAST(p.GroupID as varchar(50))
	INNER JOIN [Framework.].[Parameter] o
		ON o.ParameterID = 'baseURI';
GO
PRINT N'Creating [Profile.Data].[vwGroup.Publication.Entity.AssociatedInformationResource]...';


GO
CREATE VIEW [Profile.Data].[vwGroup.Publication.Entity.AssociatedInformationResource]
AS
	SELECT GroupID, EntityID, EntityDate FROM [Profile.Data].[Publication.Entity.InformationResource] ir
		JOIN [Profile.Data].[Publication.Group.Include] i
		ON ((ir.PMID = i.PMID AND ir.MPID IS NULL) OR (ir.MPID = i.MPID AND ir.PMID IS NULL))
	UNION
	SELECT g.GroupID, EntityID, EntityDate FROM [Profile.Data].[Publication.Group.Option] o
		JOIN [Profile.Data].[Group.Member] g
		ON o.GroupID = g.GroupID and o.IncludeMemberPublications = 1
		JOIN [User.Account].[User] u
		ON g.UserID = u.UserID
		JOIN [Profile.Data].[vwPublication.Entity.Authorship] a
		ON u.PersonID = a.PersonID
GO
PRINT N'Creating [Profile.Data].[vwGroup.General]...';


GO
CREATE VIEW [Profile.Data].[vwGroup.General] AS 
	SELECT GroupID, GroupName, ViewSecurityGroup, EditSecurityGroup, CreateDate, ViewSecurityGroupName, GroupNodeID
	FROM [Profile.Data].[vwGroup.GeneralWithDeleted]
	WHERE ViewSecurityGroup <> 0
GO
PRINT N'Altering [Ontology.].[UpdateDerivedFields]...';


GO
ALTER PROCEDURE [Ontology.].[UpdateDerivedFields]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Triple
	UPDATE o
		SET	_SubjectNode = [RDF.].fnURI2NodeID(subject),
			_PredicateNode = [RDF.].fnURI2NodeID(predicate),
			_ObjectNode = [RDF.].fnURI2NodeID(object),
			_TripleID = NULL
		FROM [Ontology.Import].[Triple] o
	UPDATE o
		SET o._TripleID = r.TripleID
		FROM [Ontology.Import].[Triple] o, [RDF.].Triple r
		WHERE o._SubjectNode = r.Subject AND o._PredicateNode = r.Predicate AND o._ObjectNode = r.Object

	-- DataMap
	UPDATE o
		SET	_ClassNode = [RDF.].fnURI2NodeID(Class),
			_NetworkPropertyNode = [RDF.].fnURI2NodeID(NetworkProperty),
			_PropertyNode = [RDF.].fnURI2NodeID(property)
		FROM [Ontology.].DataMap o

	-- ClassProperty
	UPDATE o
		SET	_ClassNode = [RDF.].fnURI2NodeID(Class),
			_NetworkPropertyNode = [RDF.].fnURI2NodeID(NetworkProperty),
			_PropertyNode = [RDF.].fnURI2NodeID(property),
			_TagName = (select top 1 n.Prefix+':'+substring(o.property,len(n.URI)+1,len(o.property)) t
						from [Ontology.].Namespace n
						where o.property like n.uri+'%'
						)
		FROM [Ontology.].ClassProperty o
	UPDATE e
		SET e._PropertyLabel = o.value
		FROM [ontology.].ClassProperty e
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON e._PropertyNode = t.subject AND t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label') 
			LEFT OUTER JOIN [RDF.].[Node] o
				ON t.object = o.nodeid
	UPDATE e
		SET e._ObjectType = (CASE WHEN o.value = 'http://www.w3.org/2002/07/owl#ObjectProperty' THEN 0 ELSE 1 END)
		FROM [ontology.].ClassProperty e
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON e._PropertyNode = t.subject AND t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') 
			LEFT OUTER JOIN [RDF.].[Node] o
				ON t.object = o.nodeid and o.value in ('http://www.w3.org/2002/07/owl#DatatypeProperty','http://www.w3.org/2002/07/owl#ObjectProperty')

	-- ClassGroup
	UPDATE o
		SET	_ClassGroupNode = [RDF.].fnURI2NodeID(ClassGroupURI)
		FROM [Ontology.].ClassGroup o
	UPDATE e
		SET e._ClassGroupLabel = o.value
		FROM [ontology.].ClassGroup e
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON e._ClassGroupNode = t.subject AND t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label') 
			LEFT OUTER JOIN [RDF.].[Node] o
				ON t.object = o.nodeid

	-- ClassGroupClass
	UPDATE o
		SET	_ClassGroupNode = [RDF.].fnURI2NodeID(ClassGroupURI),
			_ClassNode = [RDF.].fnURI2NodeID(ClassURI)
		FROM [Ontology.].ClassGroupClass o
	UPDATE e
		SET e._ClassLabel = o.value
		FROM [ontology.].ClassGroupClass e
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON e._ClassNode = t.subject AND t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label') 
			LEFT OUTER JOIN [RDF.].[Node] o
				ON t.object = o.nodeid
				
	-- ClassTreeDepth
	declare @ClassDepths table (
		NodeID bigint,
		SubClassOf bigint,
		Depth int,
		ClassURI varchar(400),
		ClassName varchar(400)
	)
	;with x as (
		select t.subject NodeID, 
			max(case when w.subject is null then null else v.object end) SubClassOf
		from [RDF.].Triple t
			left outer join [RDF.].Triple v
				on v.subject = t.subject 
				and v.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#subClassOf')
			left outer join [RDF.].Triple w
				on w.subject = v.object
				and w.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') 
				and w.object = [RDF.].fnURI2NodeID('http://www.w3.org/2002/07/owl#Class')
		where t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type') 
			and t.object = [RDF.].fnURI2NodeID('http://www.w3.org/2002/07/owl#Class') 
		group by t.subject
	)
	insert into @ClassDepths (NodeID, SubClassOf, Depth, ClassURI)
		select x.NodeID, x.SubClassOf, (case when x.SubClassOf is null then 0 else null end) Depth, n.Value
		from x, [RDF.].Node n
		where x.NodeID = n.NodeID
	;with a as (
		select NodeID, SubClassOf, Depth
			from @ClassDepths
		union all
		select b.NodeID, IsNull(a.NodeID,b.SubClassOf), a.Depth+1
			from a, @ClassDepths b
			where b.SubClassOf = a.NodeID
				and a.Depth is not null
				and b.Depth is null
	), b as (
		select NodeID, SubClassOf, Max(Depth) Depth
		from a
		group by NodeID, SubClassOf
	)
	update c
		set c.Depth = b.Depth
		from @ClassDepths c, b
		where c.NodeID = b.NodeID
	;with a as (
		select c.NodeID, max(n.Value) ClassName
			from @ClassDepths c
				inner join [RDF.].Triple t
					on t.subject = c.NodeID
						and t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
				inner join [RDF.].Node n
					on t.object = n.NodeID
			group by c.NodeID
	)
	update c
		set c.ClassName = a.ClassName
		from @ClassDepths c, a
		where c.NodeID = a.NodeID
	truncate table [Ontology.].ClassTreeDepth
	insert into [Ontology.].ClassTreeDepth (Class, _TreeDepth, _ClassNode, _ClassName)
		select ClassURI, Depth, NodeID, ClassName
			from @ClassDepths

	-- PropertyGroup
	UPDATE o
		SET	_PropertyGroupNode = [RDF.].fnURI2NodeID(PropertyGroupURI)
		FROM [Ontology.].PropertyGroup o
	UPDATE e
		SET e._PropertyGroupLabel = o.value
		FROM [ontology.].PropertyGroup e
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON e._PropertyGroupNode = t.subject AND t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label') 
			LEFT OUTER JOIN [RDF.].[Node] o
				ON t.object = o.nodeid

	-- PropertyGroupProperty
	UPDATE o
		SET	_PropertyGroupNode = [RDF.].fnURI2NodeID(PropertyGroupURI),
			_PropertyNode = [RDF.].fnURI2NodeID(PropertyURI),
			_TagName = (select top 1 n.Prefix+':'+substring(o.PropertyURI,len(n.URI)+1,len(o.PropertyURI)) t
						from [Ontology.].Namespace n
						where o.PropertyURI like n.uri+'%'
						)
		FROM [Ontology.].PropertyGroupProperty o
	UPDATE e
		SET e._PropertyLabel = o.value
		FROM [ontology.].PropertyGroupProperty e
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON e._PropertyNode = t.subject AND t.predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label') 
			LEFT OUTER JOIN [RDF.].[Node] o
				ON t.object = o.nodeid


	-- Presentation
	UPDATE o
		SET	_SubjectNode = [RDF.].fnURI2NodeID(subject),
			_PredicateNode = [RDF.].fnURI2NodeID(predicate),
			_ObjectNode = [RDF.].fnURI2NodeID(object)
		FROM [Ontology.Presentation].[XML] o


	-- Funding
	UPDATE [Ontology.].[ClassProperty]
		SET _PropertyLabel = 'research activities and funding' --'research activities'
		WHERE Class='http://xmlns.com/foaf/0.1/Person' AND Property='http://vivoweb.org/ontology/core#hasResearcherRole' AND NetworkProperty IS NULL

	-- Groups
	UPDATE [Ontology.].[ClassProperty]
		SET _PropertyLabel = 'members' --'research activities'
		WHERE Class='http://xmlns.com/foaf/0.1/Group' AND Property='http://vivoweb.org/ontology/core#contributingRole' AND NetworkProperty IS NULL

	UPDATE [Ontology.].[ClassProperty]
		SET _PropertyLabel = 'groups' --'research activities'
		WHERE Class='http://xmlns.com/foaf/0.1/Person' AND Property='http://vivoweb.org/ontology/core#hasMemberRole' AND NetworkProperty IS NULL

	UPDATE [Ontology.].[ClassProperty]
		SET _PropertyLabel = 'groups' --'research activities'
		WHERE Class='http://xmlns.com/foaf/0.1/Agent' AND Property='http://vivoweb.org/ontology/core#hasMemberRole' AND NetworkProperty IS NULL

	UPDATE [Ontology.].[ClassProperty]
		SET _PropertyLabel = 'selected publications' --'research activities'
		WHERE Class='http://xmlns.com/foaf/0.1/Group' AND Property='http://profiles.catalyst.harvard.edu/ontology/prns#associatedInformationResource' AND NetworkProperty IS NULL


	-- select * from [Ontology.Import].[Triple]
	-- select * from [Ontology.].ClassProperty
	-- select * from [Ontology.].ClassGroup
	-- select * from [Ontology.].ClassGroupClass
	-- select * from [Ontology.].ClassTreeDepth
	-- select * from [Ontology.].PropertyGroup
	-- select * from [Ontology.].PropertyGroupProperty
	-- select * from [Ontology.Presentation].[XML]

END
GO
PRINT N'Altering [ORNG.].[AddAppToPerson]...';


GO

ALTER PROCEDURE [ORNG.].[AddAppToPerson]
@SubjectID BIGINT=NULL, @SubjectURI nvarchar(255)=NULL, @AppID INT, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT, @NodeID BIGINT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	-- Cat2
	DECLARE @InternalType nvarchar(100) -- lookup from import.twitter
	DECLARE @InternalID nvarchar(100) -- lookpup personid and add appID
	DECLARE @PersonID INT
	DECLARE @PersonName nvarchar(255)
	DECLARE @Label nvarchar(255)
	DECLARE @LabelID BIGINT
	DECLARE @AppName NVARCHAR(100)
	DECLARE @ApplicationNodeID BIGINT
	DECLARE @PredicateURI nvarchar(255) -- this could be passed in for some situations
	DECLARE @PERSON_FILTER_ID INT
	
	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	SELECT @InternalType = [Object] FROM [Ontology.Import].[Triple] 
		WHERE [Subject] = 'http://orng.info/ontology/orng#ApplicationInstance' AND [Predicate] = 'http://www.w3.org/2000/01/rdf-schema#label'
		

	SELECT @PersonID = cast(InternalID as INT), @InternalID = InternalID + '-' + CAST(@AppID as varchar) FROM [RDF.Stage].[InternalNodeMap]
		WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'

	IF (@InternalID is null)
	BEGIN
		SELECT @InternalID = InternalID + '-GROUP-' + CAST(@AppID as varchar) FROM [RDF.Stage].[InternalNodeMap]
			WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Group'
	END
		
	SELECT @PersonName = DisplayName from [Profile.Data].Person WHERE PersonID = @PersonID
	--- this odd label format is required for the DataMap items to work properly!
	SELECT @Label = 'http://orng.info/ontology/orng#ApplicationInstance^^' +
					@InternalType + '^^' + @InternalID
					
					
	-- Convert the AppID to an AppName based on its URL
	SELECT @AppName = REPLACE(RTRIM(RIGHT(url, CHARINDEX('/', REVERSE(url)) - 1)), '.xml', '')
		FROM [ORNG.].[Apps] 
		WHERE AppID = @AppID

	-- STOP, should we test that the PredicateURI is consistent with the AppID?
	SELECT @PredicateURI = 'http://orng.info/ontology/orng#has'+@AppName
				
	SELECT @ApplicationNodeID  = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#Application' AND InternalType = 'ORNG Application'
			AND InternalID = @AppName

		
	----------------------------------------------------------------
	-- Determine if this app has already been added to this person
	----------------------------------------------------------------
	DECLARE @AppInstanceID BIGINT
	SELECT @AppInstanceID = NodeID
		FROM [RDF.Stage].[InternalNodeMap]

		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' 
			AND InternalType = 'ORNG Application Instance'
			AND InternalID = @InternalID
	IF @AppInstanceID IS NOT NULL
	BEGIN
		-- Determine the ViewSecurityGroup
		DECLARE @ViewSecurityGroup BIGINT
		SELECT @ViewSecurityGroup = IsNull(p.ViewSecurityGroup,c.ViewSecurityGroup)
			FROM [Ontology.].ClassProperty c
				LEFT OUTER JOIN [RDF.Security].NodeProperty p
					ON p.Property = c._PropertyNode AND p.NodeID = @SubjectID
			WHERE c.Class = 'http://xmlns.com/foaf/0.1/Person'
				AND c.Property = @PredicateURI
				AND c.NetworkProperty IS NULL

		-- Change the security group of the triple
		EXEC [RDF.].[GetStoreTriple] @SubjectID = @SubjectID, -- bigint
									 @ObjectID = @AppInstanceID, -- bigint
									 @PredicateURI = @PredicateURI, -- varchar(400)
									 @ViewSecurityGroup = @ViewSecurityGroup, -- bigint
									 @SessionID = NULL, -- uniqueidentifier
									 @Error = NULL -- bit

		print 'Weare ready to add person to filter'
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM [ORNG.].[Apps]  
			WHERE AppID = @AppID AND PersonFilterID NOT IN (
				SELECT personFilterId FROM [Profile.Data].[Person.FilterRelationship] 
					WHERE PersonID = @PersonID))
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				INSERT [Profile.Import].[PersonFilterFlag]
					SELECT InternalUserName, PersonFilter FROM [Profile.Data].[Person], [Profile.Data].[Person.Filter]
						WHERE PersonID = @PersonID AND PersonFilterID = @PERSON_FILTER_ID
				INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) 
					values (@PersonID, @PERSON_FILTER_ID)
			END

		-- Exit the proc
		RETURN;
	END


	----------------------------------------------------------------
	-- Add the app to the person for the first time
	----------------------------------------------------------------
	SELECT @Error = 0
	BEGIN TRAN
		-- We want Type 2.  Lookup internal type from import.triple, pass in AppID
		EXEC [RDF.].GetStoreNode	@Class = 'http://orng.info/ontology/orng#ApplicationInstance',
									@InternalType = @InternalType,
									@InternalID = @InternalID,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @NodeID OUTPUT
		-- for some reason, this Status in [RDF.Stage].InternalNodeMap is set to 0, not 3.  This causes issues so
		-- we fix
		UPDATE [RDF.Stage].[InternalNodeMap] SET [Status] = 3 WHERE NodeID = @NodeID						
			
		EXEC [RDF.].GetStoreNode @Value = @Label, @Language = NULL, @DataType = NULL,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @LabelID OUTPUT	

		-- Add the Type
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://orng.info/ontology/orng#ApplicationInstance',
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the Label
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
									@ObjectID = @LabelID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Link the ApplicationInstance to the Application
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationInstanceOfApplication',
									@ObjectID = @ApplicationNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT		
		-- Link the ApplicationInstance to the person
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://orng.info/ontology/orng#applicationInstanceForPerson',
									@ObjectID = @SubjectID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT								
		-- Link the person to the ApplicationInstance
		EXEC [RDF.].GetStoreTriple	@SubjectID = @SubjectID,
									@PredicateURI = @PredicateURI,
									@ObjectID = @NodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		
		-- wire in the filter to both the import and live tables
		print 'Weare ready to add person to filter'
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM [ORNG.].[Apps]  

			WHERE AppID = @AppID AND PersonFilterID NOT IN (
				SELECT personFilterId FROM [Profile.Data].[Person.FilterRelationship] 
					WHERE PersonID = @PersonID))
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				INSERT [Profile.Import].[PersonFilterFlag]
					SELECT InternalUserName, PersonFilter FROM [Profile.Data].[Person], [Profile.Data].[Person.Filter]
						WHERE PersonID = @PersonID AND PersonFilterID = @PERSON_FILTER_ID

				INSERT [Profile.Data].[Person.FilterRelationship](PersonID, personFilterId) 
					values (@PersonID, @PERSON_FILTER_ID)
			END
	COMMIT	
END
GO
PRINT N'Altering [ORNG.].[RemoveAppFromPerson]...';


GO

ALTER PROCEDURE [ORNG.].[RemoveAppFromPerson]
@SubjectID BIGINT=NULL, @SubjectURI NVARCHAR(255)=NULL, @AppID INT, @DeleteType tinyint = 1, @SessionID UNIQUEIDENTIFIER=NULL, @Error BIT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @ApplicationInstanceNodeID  BIGINT
	DECLARE @TripleID BIGINT
	DECLARE @PersonID INT
	DECLARE @InternalID nvarchar(100)	
	DECLARE @PERSON_FILTER_ID INT
	DECLARE @InternalUserName NVARCHAR(50)
	DECLARE @PersonFilter NVARCHAR(50)

	IF (@SubjectID IS NULL)
		SET @SubjectID = [RDF.].fnURI2NodeID(@SubjectURI)
	
	-- Lookup the PersonID
	SELECT @InternalID = InternalID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE NodeID = @SubjectID

	-- Lookup the App Instance's NodeID
	SELECT @ApplicationInstanceNodeID  = NodeID
		FROM [RDF.Stage].[InternalNodeMap]
		WHERE Class = 'http://orng.info/ontology/orng#ApplicationInstance' AND InternalType = 'ORNG Application Instance'
			AND InternalID = @InternalID + '-' + CAST(@AppID AS VARCHAR(50))
	
		
	-- there is only ONE link from the person to the application object, so grab it	
	SELECT @TripleID = [TripleID] FROM [RDF.].Triple 
		WHERE [Subject] = @SubjectID
		AND [Object] = @ApplicationInstanceNodeID

	-- now delete it
	BEGIN TRAN

		EXEC [RDF.].DeleteTriple @TripleID = @TripleID, 
								 @SessionID = @SessionID, 
								 @Error = @Error

		IF (@DeleteType = 0) -- true delete, remove the now orphaned application instance
		BEGIN
			EXEC [RDF.].DeleteNode @NodeID = @ApplicationInstanceNodeID, 
							   @DeleteType = @DeleteType,
							   @SessionID = @SessionID, 
							   @Error = @Error OUTPUT
		END							   

		-- remove any filters
		SELECT @PERSON_FILTER_ID = (SELECT PersonFilterID FROM Apps WHERE AppID = @AppID)
		IF (@PERSON_FILTER_ID IS NOT NULL) 
			BEGIN
				SELECT @PersonID = CAST(InternalID AS INT) FROM [RDF.Stage].[InternalNodeMap]
					WHERE [NodeID] = @SubjectID AND Class = 'http://xmlns.com/foaf/0.1/Person'
				IF (@PersonID IS NOT NULL)
					BEGIN
						SELECT @InternalUserName = InternalUserName FROM [Profile.Data].[Person] WHERE PersonID = @PersonID
						SELECT @PersonFilter = PersonFilter FROM [Profile.Data].[Person.Filter] WHERE PersonFilterID = @PERSON_FILTER_ID

						DELETE FROM [Profile.Import].[PersonFilterFlag] WHERE InternalUserName = @InternalUserName AND personfilter = @PersonFilter
						DELETE FROM [Profile.Data].[Person.FilterRelationship] WHERE PersonID = @PersonID AND personFilterId = @PERSON_FILTER_ID
					END
			END
	COMMIT
END
GO
PRINT N'Altering [Profile.Data].[Publication.Entity.UpdateEntity]...';


GO
ALTER PROCEDURE [Profile.Data].[Publication.Entity.UpdateEntity]

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update InformationResource entities
	-- *******************************************************************
	-- *******************************************************************
 
 
	----------------------------------------------------------------------
	-- Get a list of current publications
	----------------------------------------------------------------------

	CREATE TABLE #Publications
	(
		PMID INT NULL ,
		MPID NVARCHAR(50) NULL ,
		PMCID NVARCHAR(55) NULL,
		EntityDate DATETIME NULL ,
		Reference VARCHAR(MAX) NULL ,
		Source VARCHAR(25) NULL ,
		URL VARCHAR(1000) NULL ,
		Title VARCHAR(4000) NULL ,
		EntityID INT NULL
	)
 
	-- Add PMIDs to the publications temp table
	INSERT  INTO #Publications
            ( PMID ,
			  PMCID,
              EntityDate ,
              Reference ,
              Source ,
              URL ,
              Title
            )
            SELECT -- Get Pub Med pubs
                    PG.PMID ,
					PG.PMCID,
                    EntityDate = PG.PubDate,
                    Reference = REPLACE([Profile.Cache].[fnPublication.Pubmed.General2Reference](PG.PMID,
                                                              PG.ArticleDay,
                                                              PG.ArticleMonth,
                                                              PG.ArticleYear,
                                                              PG.ArticleTitle,
                                                              PG.Authors,
                                                              PG.AuthorListCompleteYN,
                                                              PG.Issue,
                                                              PG.JournalDay,
                                                              PG.JournalMonth,
                                                              PG.JournalYear,
                                                              PG.MedlineDate,
                                                              PG.MedlinePgn,
                                                              PG.MedlineTA,
                                                              PG.Volume, 0),
                                        CHAR(11), '') ,
                    Source = 'PubMed',
                    URL = 'http://www.ncbi.nlm.nih.gov/pubmed/' + CAST(ISNULL(PG.pmid, '') AS VARCHAR(20)),
                    Title = left((case when IsNull(PG.ArticleTitle,'') <> '' then PG.ArticleTitle else 'Untitled Publication' end),4000)
            FROM    [Profile.Data].[Publication.PubMed.General] PG
			WHERE	PG.PMID IN (
						SELECT PMID 
							FROM [Profile.Data].[Publication.Person.Include]
							WHERE PMID IS NOT NULL
						UNION
						SELECT PMID 
							FROM [Profile.Data].[Publication.Group.Include]
							WHERE PMID IS NOT NULL)
 
	-- Add MPIDs to the publications temp table
	INSERT  INTO #Publications
            ( MPID ,
              EntityDate ,
			  Reference ,
			  Source ,
              URL ,
              Title
            )
            SELECT  MPID ,
                    EntityDate ,
                    Reference = REPLACE(authors
										+ (CASE WHEN IsNull(article,'') <> '' THEN article + '. ' ELSE '' END)
										+ (CASE WHEN IsNull(pub,'') <> '' THEN pub + '. ' ELSE '' END)
										+ y
                                        + CASE WHEN y <> ''
                                                    AND vip <> '' THEN '; '
                                               ELSE ''
                                          END + vip
                                        + CASE WHEN y <> ''
                                                    OR vip <> '' THEN '.'
                                               ELSE ''
                                          END, CHAR(11), '') ,
                    Source = 'Custom' ,
                    URL = url,
                    Title = left((case when IsNull(article,'')<>'' then article when IsNull(pub,'')<>'' then pub else 'Untitled Publication' end),4000)
            FROM    ( SELECT    MPID ,
                                EntityDate ,
                                url ,
                                authors = CASE WHEN authors = '' THEN ''
                                               WHEN RIGHT(authors, 1) = '.'
                                               THEN LEFT(authors,
                                                         LEN(authors) - 1)
                                               ELSE authors
                                          END ,
                                article = CASE WHEN article = '' THEN ''
                                               WHEN RIGHT(article, 1) = '.'
                                               THEN LEFT(article,
                                                         LEN(article) - 1)
                                               ELSE article
                                          END ,
                                pub = CASE WHEN pub = '' THEN ''
                                           WHEN RIGHT(pub, 1) = '.'
                                           THEN LEFT(pub, LEN(pub) - 1)
                                           ELSE pub
                                      END ,
                                y ,
                                vip
                      FROM      ( SELECT    MPG.mpid ,
                                            EntityDate = MPG.publicationdt ,
                                            authors = CASE WHEN RTRIM(LTRIM(COALESCE(MPG.authors,
                                                              ''))) = ''
                                                           THEN ''
                                                           WHEN RIGHT(COALESCE(MPG.authors,
                                                              ''), 1) = '.'
                                                            THEN  COALESCE(MPG.authors,
                                                              '') + ' '
                                                           ELSE COALESCE(MPG.authors,
                                                              '') + '. '
                                                      END ,
                                            url = CASE WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                            AND LEFT(COALESCE(MPG.url,
                                                              ''), 4) = 'http'
                                                       THEN MPG.url
                                                       WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                       THEN 'http://' + MPG.url
                                                       ELSE ''
                                                  END ,
                                            article = LTRIM(RTRIM(COALESCE(MPG.articletitle,
                                                              ''))) ,
                                            pub = LTRIM(RTRIM(COALESCE(MPG.pubtitle,
                                                              ''))) ,
                                            y = CASE WHEN MPG.publicationdt > '1/1/1901'
                                                     THEN CONVERT(VARCHAR(50), YEAR(MPG.publicationdt))
                                                     ELSE ''
                                                END ,
                                            vip = COALESCE(MPG.volnum, '')
                                            + CASE WHEN COALESCE(MPG.issuepub,
                                                              '') <> ''
                                                   THEN '(' + MPG.issuepub
                                                        + ')'
                                                   ELSE ''
                                              END
                                            + CASE WHEN ( COALESCE(MPG.paginationpub,
                                                              '') <> '' )
                                                        AND ( COALESCE(MPG.volnum,
                                                              '')
                                                              + COALESCE(MPG.issuepub,
                                                              '') <> '' )
                                                   THEN ':'
                                                   ELSE ''
                                              END + COALESCE(MPG.paginationpub,
                                                             '')
                                  FROM      [Profile.Data].[Publication.MyPub.General] MPG
                                  INNER JOIN [Profile.Data].[Publication.Person.Include] PL ON MPG.mpid = PL.mpid
                                                           AND PL.mpid NOT LIKE 'DASH%'
                                                           AND PL.mpid NOT LIKE 'ISI%'
                                                           AND PL.pmid IS NULL
                                ) T0
                    ) T0
 
	CREATE NONCLUSTERED INDEX idx_pmid on #publications(pmid)
	CREATE NONCLUSTERED INDEX idx_mpid on #publications(mpid)

	----------------------------------------------------------------------
	-- Update the Publication.Entity.InformationResource table
	----------------------------------------------------------------------

	-- Determine which publications already exist
	UPDATE p
		SET p.EntityID = e.EntityID
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.PMID = e.PMID and p.PMID is not null
	UPDATE p
		SET p.EntityID = e.EntityID
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.MPID = e.MPID and p.MPID is not null
	CREATE NONCLUSTERED INDEX idx_entityid on #publications(EntityID)

	-- Deactivate old publications
	UPDATE e
		SET e.IsActive = 0
		FROM [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE e.EntityID NOT IN (SELECT EntityID FROM #publications)

	-- Update the data for existing publications
	UPDATE e
		SET e.EntityDate = p.EntityDate,
			e.pmcid = p.pmcid,
			e.Reference = p.Reference,
			e.Source = p.Source,
			e.URL = p.URL,
			e.EntityName = p.Title,
			e.IsActive = 1,
			e.PubYear = year(p.EntityDate),
            e.YearWeight = (case when p.EntityDate is null then 0.5
                when year(p.EntityDate) <= 1901 then 0.5
                else power(cast(0.5 as float),cast(datediff(d,p.EntityDate,GetDate()) as float)/365.25/10)
                end)
		FROM #publications p, [Profile.Data].[Publication.Entity.InformationResource] e
		WHERE p.EntityID = e.EntityID and p.EntityID is not null

	-- Insert new publications
	INSERT INTO [Profile.Data].[Publication.Entity.InformationResource] (
			PMID,
			PMCID,
			MPID,
			EntityName,
			EntityDate,
			Reference,
			Source,
			URL,
			IsActive,
			PubYear,
			YearWeight
		)
		SELECT 	PMID,
				PMCID,
				MPID,
				Title,
				EntityDate,
				Reference,
				Source,
				URL,
				1 IsActive,
				PubYear = year(EntityDate),
				YearWeight = (case when EntityDate is null then 0.5
								when year(EntityDate) <= 1901 then 0.5
								else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
								end)
		FROM #publications
		WHERE EntityID IS NULL

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update Authorship entities
	-- *******************************************************************
	-- *******************************************************************
 
 	----------------------------------------------------------------------
	-- Get a list of current Authorship records
	----------------------------------------------------------------------

	CREATE TABLE #Authorship
	(
		EntityDate DATETIME NULL ,
		authorRank INT NULL,
		numberOfAuthors INT NULL,
		authorNameAsListed VARCHAR(255) NULL,
		AuthorWeight FLOAT NULL,
		AuthorPosition VARCHAR(1) NULL,
		PubYear INT NULL ,
		YearWeight FLOAT NULL ,
		PersonID INT NULL ,
		InformationResourceID INT NULL,
		PMID INT NULL,
		IsActive BIT,
		EntityID INT
	)
 
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, e.PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE e.PMID = i.PMID and e.PMID is not null
	INSERT INTO #Authorship (EntityDate, PersonID, InformationResourceID, PMID, IsActive)
		SELECT e.EntityDate, i.PersonID, e.EntityID, null PMID, 1 IsActive
			FROM [Profile.Data].[Publication.Entity.InformationResource] e,
				[Profile.Data].[Publication.Person.Include] i
			WHERE (e.MPID = i.MPID) and (e.MPID is not null) and (e.PMID is null)
	CREATE NONCLUSTERED INDEX idx_person_pmid ON #Authorship(PersonID, PMID)
	CREATE NONCLUSTERED INDEX idx_person_pub ON #Authorship(PersonID, InformationResourceID)

	UPDATE a
		SET	a.authorRank=p.authorRank,
			a.numberOfAuthors=p.numberOfAuthors,
			a.authorNameAsListed=p.authorNameAsListed, 
			a.AuthorWeight=p.AuthorWeight, 
			a.AuthorPosition=p.AuthorPosition,
			a.PubYear=p.PubYear,
			a.YearWeight=p.YearWeight
		FROM #Authorship a, [Profile.Cache].[Publication.PubMed.AuthorPosition]  p
		WHERE a.PersonID = p.PersonID and a.PMID = p.PMID and a.PMID is not null
	UPDATE #authorship
		SET authorWeight = 0.5
		WHERE authorWeight IS NULL
	UPDATE #authorship
		SET authorPosition = 'U'
		WHERE authorPosition IS NULL
	UPDATE #authorship
		SET PubYear = year(EntityDate)
		WHERE PubYear IS NULL
	UPDATE #authorship
		SET	YearWeight = (case when EntityDate is null then 0.5
							when year(EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,EntityDate,GetDate()) as float)/365.25/10)
							end)
		WHERE YearWeight IS NULL

	----------------------------------------------------------------------
	-- Update the Publication.Authorship table
	----------------------------------------------------------------------

	-- Determine which authorships already exist
	UPDATE a
		SET a.EntityID = e.EntityID
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.PersonID = e.PersonID and a.InformationResourceID = e.InformationResourceID
 	CREATE NONCLUSTERED INDEX idx_entityid on #authorship(EntityID)

	-- Deactivate old authorships
	UPDATE a
		SET a.IsActive = 0
		FROM [Profile.Data].[Publication.Entity.Authorship] a
		WHERE a.EntityID NOT IN (SELECT EntityID FROM #authorship)

	-- Update the data for existing authorships
	UPDATE e
		SET e.EntityDate = a.EntityDate,
			e.authorRank = a.authorRank,
			e.numberOfAuthors = a.numberOfAuthors,
			e.authorNameAsListed = a.authorNameAsListed,
			e.authorWeight = a.authorWeight,
			e.authorPosition = a.authorPosition,
			e.PubYear = a.PubYear,
			e.YearWeight = a.YearWeight,
			e.IsActive = 1
		FROM #authorship a, [Profile.Data].[Publication.Entity.Authorship] e
		WHERE a.EntityID = e.EntityID and a.EntityID is not null

	-- Insert new Authorships
	INSERT INTO [Profile.Data].[Publication.Entity.Authorship] (
			EntityDate,
			authorRank,
			numberOfAuthors,
			authorNameAsListed,
			authorWeight,
			authorPosition,
			PubYear,
			YearWeight,
			PersonID,
			InformationResourceID,
			IsActive
		)
		SELECT 	EntityDate,
				authorRank,
				numberOfAuthors,
				authorNameAsListed,
				authorWeight,
				authorPosition,
				PubYear,
				YearWeight,
				PersonID,
				InformationResourceID,
				IsActive
		FROM #authorship a
		WHERE EntityID IS NULL

	-- Assign an EntityName
	UPDATE [Profile.Data].[Publication.Entity.Authorship]
		SET EntityName = 'Authorship ' + CAST(EntityID as VARCHAR(50))
		WHERE EntityName is null
 
END
GO
PRINT N'Altering [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]...';


GO
ALTER procedure [Profile.Data].[Publication.Pubmed.ParseALLPubMedXML]
AS
BEGIN
	SET NOCOUNT ON;

/*
	UPDATE [Profile.Data].[Publication.PubMed.AllXML] set ParseDT = GetDate() where pmid = @pmid


	delete from [Profile.Data].[Publication.PubMed.Author] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Investigator] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.PubType] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Chemical] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Databank] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Accession] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Keyword] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Grant] where pmid = @pmid
	delete from [Profile.Data].[Publication.PubMed.Mesh] where pmid = @pmid
	*/
	
	--*** general ***
	truncate table [Profile.Data].[Publication.PubMed.General.Stage]
	insert into [Profile.Data].[Publication.PubMed.General.Stage] (pmid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN,PMCID)
		select pmid, 
			nref.value('@Owner[1]','varchar(50)') Owner,
			nref.value('@Status[1]','varchar(50)') Status,
			nref.value('Article[1]/@PubModel','varchar(50)') PubModel,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/Volume[1]','varchar(255)') Volume,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/Issue[1]','varchar(255)') Issue,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/MedlineDate[1]','varchar(255)') MedlineDate,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Year[1]','varchar(50)') JournalYear,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Month[1]','varchar(50)') JournalMonth,
			nref.value('Article[1]/Journal[1]/JournalIssue[1]/PubDate[1]/Day[1]','varchar(50)') JournalDay,
			nref.value('Article[1]/Journal[1]/Title[1]','varchar(1000)') JournalTitle,
			nref.value('Article[1]/Journal[1]/ISOAbbreviation[1]','varchar(100)') ISOAbbreviation,
			nref.value('MedlineJournalInfo[1]/MedlineTA[1]','varchar(1000)') MedlineTA,
			nref.value('Article[1]/ArticleTitle[1]','varchar(4000)') ArticleTitle,
			nref.value('Article[1]/Pagination[1]/MedlinePgn[1]','varchar(255)') MedlinePgn,
			nref.value('Article[1]/Abstract[1]/AbstractText[1]','varchar(max)') AbstractText,
			nref.value('Article[1]/ArticleDate[1]/@DateType[1]','varchar(50)') ArticleDateType,
			NULLIF(nref.value('Article[1]/ArticleDate[1]/Year[1]','varchar(10)'),'') ArticleYear,
			NULLIF(nref.value('Article[1]/ArticleDate[1]/Month[1]','varchar(10)'),'') ArticleMonth,
			NULLIF(nref.value('Article[1]/ArticleDate[1]/Day[1]','varchar(10)'),'') ArticleDay,
			Affiliation = COALESCE(nref.value('Article[1]/AuthorList[1]/Author[1]/AffiliationInfo[1]/Affiliation[1]','varchar(8000)'),
				nref.value('Article[1]/AuthorList[1]/Author[1]/Affiliation[1]','varchar(8000)'),
				nref.value('Article[1]/Affiliation[1]','varchar(8000)')) ,
			nref.value('Article[1]/AuthorList[1]/@CompleteYN[1]','varchar(1)') AuthorListCompleteYN,
			nref.value('Article[1]/GrantList[1]/@CompleteYN[1]','varchar(1)') GrantListCompleteYN,
			PMCID=COALESCE(nref.value('(OtherID[@Source="NLM" and text()[contains(.,"PMC")]])[1]', 'varchar(55)'), nref.value('(OtherID[@Source="NLM"][1])','varchar(55)'))
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//MedlineCitation[1]') as R(nref)
		where ParseDT is null and x is not null

		update [Profile.Data].[Publication.PubMed.General.Stage]
		set MedlineDate = (case when right(MedlineDate,4) like '20__' then ltrim(rtrim(right(MedlineDate,4)+' '+left(MedlineDate,len(MedlineDate)-4))) else null end)
		where MedlineDate is not null and MedlineDate not like '[0-9][0-9][0-9][0-9]%'

		
		update [Profile.Data].[Publication.PubMed.General.Stage]
		set PubDate = [Profile.Data].[fnPublication.Pubmed.GetPubDate](medlinedate,journalyear,journalmonth,journalday,articleyear,articlemonth,articleday)


	--*** authors ***
	truncate table [Profile.Data].[Publication.PubMed.Author.Stage]
	insert into [Profile.Data].[Publication.PubMed.Author.Stage] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('@ValidYN','varchar(1)') ValidYN, 
			nref.value('LastName[1]','varchar(100)') LastName, 
			nref.value('FirstName[1]','varchar(100)') FirstName,
			nref.value('ForeName[1]','varchar(100)') ForeName,
			nref.value('Suffix[1]','varchar(20)') Suffix,
			nref.value('Initials[1]','varchar(20)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(1000)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//AuthorList/Author') as R(nref)
		where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		


	--*** general (authors) ***

	create table #a (pmid int primary key, authors varchar(4000))
	insert into #a(pmid,authors)
		select pmid,
			(case	when len(s) < 3990 then s
					when charindex(',',reverse(left(s,3990)))>0 then
						left(s,3990-charindex(',',reverse(left(s,3990))))+', et al'
					else left(s,3990)
					end) authors
		from (
			select pmid, substring(s,3,len(s)) s
			from (
				select pmid, isnull(cast((
					select ', '+lastname+' '+initials
					from [Profile.Data].[Publication.PubMed.Author.Stage] q
					where q.pmid = p.pmid
					order by PmPubsAuthorID
					for xml path(''), type
				) as nvarchar(max)),'') s
				from [Profile.Data].[Publication.PubMed.General.Stage] p
			) t
		) t

	--[10132 in 00:00:01]
	update g
		set g.authors = isnull(a.authors,'')
		from [Profile.Data].[Publication.PubMed.General.Stage] g, #a a
		where g.pmid = a.pmid
	update [Profile.Data].[Publication.PubMed.General.Stage]
		set authors = ''
		where authors is null
		
		
		
	--*** mesh ***
	truncate table [Profile.Data].[Publication.PubMed.Mesh.Stage]
	insert into [Profile.Data].[Publication.PubMed.Mesh.Stage] (pmid, DescriptorName, QualifierName, MajorTopicYN)
		select pmid, DescriptorName, IsNull(QualifierName,''), max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('.','varchar(max)') DescriptorName,
				null QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/DescriptorName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
			union all
			select pmid, 
				nref.value('@MajorTopicYN[1]','varchar(max)') MajorTopicYN, 
				nref.value('../DescriptorName[1]','varchar(max)') DescriptorName,
				nref.value('.','varchar(max)') QualifierName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//MeshHeadingList/MeshHeading/QualifierName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DescriptorName is not null
		group by pmid, DescriptorName, QualifierName

		
	--******************************************************************
	--******************************************************************
	--*** Update General
	--******************************************************************
	--******************************************************************

	update g
		set 
			g.pmid=a.pmid,
			g.pmcid=a.pmcid,
			g.Owner=a.Owner,
			g.Status=a.Status,
			g.PubModel=a.PubModel,
			g.Volume=a.Volume,
			g.Issue=a.Issue,
			g.MedlineDate=a.MedlineDate,
			g.JournalYear=a.JournalYear,
			g.JournalMonth=a.JournalMonth,
			g.JournalDay=a.JournalDay,
			g.JournalTitle=a.JournalTitle,
			g.ISOAbbreviation=a.ISOAbbreviation,
			g.MedlineTA=a.MedlineTA,
			g.ArticleTitle=a.ArticleTitle,
			g.MedlinePgn=a.MedlinePgn,
			g.AbstractText=a.AbstractText,
			g.ArticleDateType=a.ArticleDateType,
			g.ArticleYear=a.ArticleYear,
			g.ArticleMonth=a.ArticleMonth,
			g.ArticleDay=a.ArticleDay,
			g.Affiliation=a.Affiliation,
			g.AuthorListCompleteYN=a.AuthorListCompleteYN,
			g.GrantListCompleteYN=a.GrantListCompleteYN,
			g.PubDate = a.PubDate,
			g.Authors = a.Authors
		from [Profile.Data].[Publication.PubMed.General] (nolock) g
			inner join [Profile.Data].[Publication.PubMed.General.Stage] a
				on g.pmid = a.pmid
				
	insert into [Profile.Data].[Publication.PubMed.General] (pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors)
		select pmid, pmcid, Owner, Status, PubModel, Volume, Issue, MedlineDate, JournalYear, JournalMonth, JournalDay, JournalTitle, ISOAbbreviation, MedlineTA, ArticleTitle, MedlinePgn, AbstractText, ArticleDateType, ArticleYear, ArticleMonth, ArticleDay, Affiliation, AuthorListCompleteYN, GrantListCompleteYN, PubDate, Authors
			from [Profile.Data].[Publication.PubMed.General.Stage]
			where pmid not in (select pmid from [Profile.Data].[Publication.PubMed.General])
	
	
	--******************************************************************
	--******************************************************************
	--*** Update Authors
	--******************************************************************
	--******************************************************************
	
	delete from [Profile.Data].[Publication.PubMed.Author] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.Author.Stage])
	insert into [Profile.Data].[Publication.PubMed.Author] (pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, ValidYN, LastName, FirstName, ForeName, Suffix, Initials, Affiliation
		from [Profile.Data].[Publication.PubMed.Author.Stage]
		order by PmPubsAuthorID

		
	--******************************************************************
	--******************************************************************
	--*** Update MeSH
	--******************************************************************
	--******************************************************************


	--*** mesh ***
	delete from [Profile.Data].[Publication.PubMed.Mesh] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	--[16593 in 00:00:11]
	insert into [Profile.Data].[Publication.PubMed.Mesh]
		select * from [Profile.Data].[Publication.PubMed.Mesh.Stage]
	--[86375 in 00:00:17]

		
		
		
	--*** investigators ***
	delete from [Profile.Data].[Publication.PubMed.Investigator] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Investigator] (pmid, LastName, FirstName, ForeName, Suffix, Initials, Affiliation)
		select pmid, 
			nref.value('LastName[1]','varchar(max)') LastName, 
			nref.value('FirstName[1]','varchar(max)') FirstName,
			nref.value('ForeName[1]','varchar(max)') ForeName,
			nref.value('Suffix[1]','varchar(max)') Suffix,
			nref.value('Initials[1]','varchar(max)') Initials,
			COALESCE(nref.value('AffiliationInfo[1]/Affiliation[1]','varchar(max)'),
				nref.value('Affiliation[1]','varchar(max)')) Affiliation
		from [Profile.Data].[Publication.PubMed.AllXML] cross apply x.nodes('//InvestigatorList/Investigator') as R(nref)
		where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		

	--*** pubtype ***
	delete from [Profile.Data].[Publication.PubMed.PubType] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.PubType] (pmid, PublicationType)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') PublicationType
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//PublicationTypeList/PublicationType') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where PublicationType is not null


	--*** chemicals
	delete from [Profile.Data].[Publication.PubMed.Chemical] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Chemical] (pmid, NameOfSubstance)
		select * from (
			select distinct pmid, nref.value('.','varchar(max)') NameOfSubstance
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//ChemicalList/Chemical/NameOfSubstance') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where NameOfSubstance is not null


	--*** databanks ***
	delete from [Profile.Data].[Publication.PubMed.Databank] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Databank] (pmid, DataBankName)
		select * from (
			select distinct pmid, 
				nref.value('.','varchar(max)') DataBankName
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/DataBankName') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DataBankName is not null


	--*** accessions ***
	delete from [Profile.Data].[Publication.PubMed.Accession] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Accession] (pmid, DataBankName, AccessionNumber)
		select * from (
			select distinct pmid, 
				nref.value('../../DataBankName[1]','varchar(max)') DataBankName,
				nref.value('.','varchar(max)') AccessionNumber
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//DataBankList/DataBank/AccessionNumberList/AccessionNumber') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where DataBankName is not null and AccessionNumber is not null


	--*** keywords ***
	delete from [Profile.Data].[Publication.PubMed.Keyword] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Keyword] (pmid, Keyword, MajorTopicYN)
		select pmid, Keyword, max(MajorTopicYN)
		from (
			select pmid, 
				nref.value('.','varchar(max)') Keyword,
				nref.value('@MajorTopicYN','varchar(max)') MajorTopicYN
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//KeywordList/Keyword') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where Keyword is not null
		group by pmid, Keyword


	--*** grants ***
	delete from [Profile.Data].[Publication.PubMed.Grant] where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
	insert into [Profile.Data].[Publication.PubMed.Grant] (pmid, GrantID, Acronym, Agency)
		select pmid, GrantID, max(Acronym), max(Agency)
		from (
			select pmid, 
				nref.value('GrantID[1]','varchar(50)') GrantID, 
				nref.value('Acronym[1]','varchar(50)') Acronym,
				nref.value('Agency[1]','varchar(1000)') Agency
			from [Profile.Data].[Publication.PubMed.AllXML]
				cross apply x.nodes('//GrantList/Grant') as R(nref)
			where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
		) t where GrantID is not null
		group by pmid, GrantID


	--******************************************************************
	--******************************************************************
	--*** Update parse date
	--******************************************************************
	--******************************************************************

	update [Profile.Data].[Publication.PubMed.AllXML] set ParseDT = GetDate() where pmid in (select pmid from [Profile.Data].[Publication.PubMed.General.Stage])
END
GO
PRINT N'Altering [RDF.Security].[GetSessionSecurityGroupNodes]...';


GO
ALTER PROCEDURE [RDF.Security].[GetSessionSecurityGroupNodes]
@SessionID UNIQUEIDENTIFIER=NULL, @Subject BIGINT=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*

	This procedure returns Security Group nodes to which
	the given session has access. However, it only returns
	the NodeID of the session itself if the subject is that
	session node; otherwise, there is no need to include
	node in the result set.

	*/

	-- Get the session's NodeID
	SELECT NodeID SecurityGroupNode
		FROM [User.Session].Session
		WHERE NodeID IS NOT NULL
			AND SessionID = @SessionID
	-- Get the user's NodeID
	UNION
	SELECT m.NodeID SecurityGroupNode
		FROM [User.Session].Session s 
			INNER JOIN [RDF.Stage].InternalNodeMap m
				ON	s.SessionID = @SessionID
					AND s.UserID IS NOT NULL
					AND m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
					AND m.InternalType = 'User'
					AND m.InternalID = CAST(s.UserID AS VARCHAR(50))
	-- Get designated proxy NodeIDs
	UNION
	SELECT m.NodeID SecurityGroupNode
		FROM [User.Session].Session s
			INNER JOIN [User.Account].[DesignatedProxy] x
				ON	s.SessionID = @SessionID
					AND s.UserID IS NOT NULL
					AND @Subject IS NOT NULL
					AND x.UserID = s.UserID
			INNER JOIN [RDF.Stage].InternalNodeMap m
				ON	m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
					AND m.InternalType = 'User'
					AND m.InternalID = CAST(x.ProxyForUserID AS VARCHAR(50))
			INNER JOIN [RDF.].[Node] n
				ON	n.NodeID = @Subject
					AND m.NodeID IN (@Subject, n.ViewSecurityGroup, n.EditSecurityGroup)
	/*
	SELECT m.NodeID SecurityGroupNode
		FROM [User.Session].Session s
			INNER JOIN [RDF.].[Node] n
				ON	s.SessionID = @SessionID
					AND s.UserID IS NOT NULL
					AND @Subject IS NOT NULL
					AND n.NodeID = @Subject
			INNER JOIN [User.Account].[DesignatedProxy] x
				ON	x.UserID = s.UserID
					AND x.ProxyForUserID IN (@Subject, n.ViewSecurityGroup, n.EditSecurityGroup)
			INNER JOIN [RDF.Stage].InternalNodeMap m
				ON	m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
					AND m.InternalType = 'User'
					AND m.InternalID = CAST(x.ProxyForUserID AS VARCHAR(50))
	*/
	-- Get default proxy NodeIDs
	UNION
	SELECT m.NodeID SecurityGroupNode
		FROM [User.Session].Session s
			INNER JOIN [RDF.].[Node] n
				ON	s.SessionID = @SessionID
					AND s.UserID IS NOT NULL
					AND @Subject IS NOT NULL
					AND n.NodeID = @Subject
			INNER JOIN [User.Account].[DefaultProxy] x
				ON	x.UserID = s.UserID
			INNER JOIN [User.Account].[User] u
				ON	((IsNull(x.ProxyForInstitution,'') = '') 
							OR (IsNull(x.ProxyForInstitution,'') = IsNull(u.Institution,'')))
					AND ((IsNull(x.ProxyForDepartment,'') = '') 
							OR (IsNull(x.ProxyForDepartment,'') = IsNull(u.Department,'')))
					AND ((IsNull(x.ProxyForDivision,'') = '') 
							OR (IsNull(x.ProxyForDivision,'') = IsNull(u.Division,'')))
			INNER JOIN [RDF.Stage].InternalNodeMap m
				ON	m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
					AND m.InternalType = 'User'
					AND m.InternalID = CAST(u.UserID AS VARCHAR(50))
					AND m.NodeID IN (@Subject, n.ViewSecurityGroup, n.EditSecurityGroup)
	-- Get Group Administrator NodesIDs
	UNION
	SELECT g.GroupNodeID SecurityGroupNode
		FROM [User.Session].Session s
			INNER JOIN [Profile.Data].[Group.Admin] x
				ON	s.SessionID = @SessionID
					AND s.UserID IS NOT NULL
					AND @Subject IS NOT NULL
					AND x.UserID = s.UserID
			INNER JOIN [Profile.Data].[vwGroup.General] g
				ON g.ViewSecurityGroup <> 0
				AND g.GroupNodeID = @Subject
	-- Get Group Manager NodeIDs
	UNION
	SELECT g.GroupNodeID SecurityGroupNode
		FROM [User.Session].Session s
			INNER JOIN [Profile.Data].[Group.Manager] x
				ON	s.SessionID = @SessionID
					AND s.UserID IS NOT NULL
					AND @Subject IS NOT NULL
					AND x.UserID = s.UserID
			INNER JOIN [Profile.Data].[vwGroup.General] g
				ON g.ViewSecurityGroup <> 0
				AND g.GroupID = x.GroupID
				AND g.GroupNodeID = @Subject					
	/*
	SELECT m.NodeID SecurityGroupNode
		FROM [User.Session].Session s
			INNER JOIN [RDF.].[Node] n
				ON	s.SessionID = @SessionID
					AND s.UserID IS NOT NULL
					AND @Subject IS NOT NULL
					AND n.NodeID = @Subject
			INNER JOIN [User.Account].[DefaultProxy] x
				ON	x.UserID = s.UserID
			INNER JOIN [User.Account].[User] u
				ON	u.UserID IN (@Subject, n.ViewSecurityGroup, n.EditSecurityGroup)
					AND ((IsNull(x.ProxyForInstitution,'') = '') 
							OR (IsNull(x.ProxyForInstitution,'') = IsNull(u.Institution,'')))
					AND ((IsNull(x.ProxyForDepartment,'') = '') 
							OR (IsNull(x.ProxyForDepartment,'') = IsNull(u.Department,'')))
					AND ((IsNull(x.ProxyForDivision,'') = '') 
							OR (IsNull(x.ProxyForDivision,'') = IsNull(u.Division,'')))
			INNER JOIN [RDF.Stage].InternalNodeMap m
				ON	m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User'
					AND m.InternalType = 'User'
					AND m.InternalID = CAST(u.UserID AS VARCHAR(50))
	*/

	/*
	This will later be expanded to include all nodes to which a
	session's users is connected through a membership predicate.
	*/


END
GO
PRINT N'Creating [Direct.Framework].[AddLogIncoming]...';


GO
CREATE PROCEDURE [Direct.Framework].[AddLogIncoming]
	@Details bit,
	@RequestIP varchar(16),
	@QueryString varchar(1000)
AS
BEGIN
	INSERT INTO [Direct.].LogIncoming(Details,ReceivedDate,RequestIP,QueryString)
	values (@Details, GETDATE(), @RequestIP, @QueryString)
END
GO
PRINT N'Creating [Direct.Framework].[AddLogOutgoing]...';


GO
CREATE PROCEDURE [Direct.Framework].[AddLogOutgoing]
	@FSID uniqueidentifier,
	@SiteID int,
	@Details bit
AS
BEGIN
	INSERT INTO [Direct.].LogOutgoing(FSID, SiteID, Details, SentDate)
	values (@FSID, @SiteID, @Details, GETDATE())
END
GO
PRINT N'Creating [Direct.Framework].[UpdateLogOutgoing]...';


GO
CREATE PROCEDURE [Direct.Framework].[UpdateLogOutgoing]
	@FSID uniqueidentifier,
	@ResponseState int,
	@ResponseStatus int = NULL,
	@ResultText varchar(4000) = NULL,
	@ResultCount varchar(10) = NULL,
	@ResultDetailsURL varchar(1000) = NULL
AS
BEGIN
	UPDATE [Direct.].LogOutgoing SET ResponseTime = datediff(ms,SentDate,GetDate()),
	ResponseState = @ResponseState,
	ResponseStatus = ISNULL(@ResponseStatus, ResponseStatus),
	ResultText = ISNULL(@ResultText, ResultText),
	ResultCount = ISNULL(@ResultCount, ResultCount),
	ResultDetailsURL = ISNULL(@ResultDetailsURL, ResultDetailsURL)
	WHERE FSID = @FSID
END
GO
PRINT N'Creating [Edit.Module].[CustomEditAssociatedInformationResource.GetList]...';


GO
CREATE PROCEDURE [Edit.Module].[CustomEditAssociatedInformationResource.GetList]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN

	DECLARE @GroupID INT
 
	SELECT @GroupID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
	SELECT r.Reference, (CASE WHEN r.PMID IS NOT NULL THEN 1 ELSE 0 END) FromPubMed, i.PubID, r.PMID, r.MPID, NULL Category, r.URL, r.EntityDate PubDate, r.EntityID, r.Source, r.IsActive, i.GroupID
		FROM [Profile.Data].[Publication.Group.Include] i
			INNER JOIN [Profile.Data].[Publication.Entity.InformationResource] r
				ON i.PMID = r.PMID AND i.PMID IS NOT NULL
				AND i.GroupID = @GroupID
	UNION ALL
	SELECT r.Reference, (CASE WHEN r.PMID IS NOT NULL THEN 1 ELSE 0 END) FromPubMed, i.PubID, r.PMID, r.MPID, g.HmsPubCategory Category, r.URL, r.EntityDate PubDate, r.EntityID, r.Source, r.IsActive, i.GroupID
		FROM [Profile.Data].[Publication.Group.Include] i
			INNER JOIN [Profile.Data].[Publication.Entity.InformationResource] r
				ON i.MPID = r.MPID AND i.PMID IS NULL AND i.MPID IS NOT NULL
				AND i.GroupID = @GroupID
			INNER JOIN [Profile.Data].[Publication.Group.MyPub.General] g
				ON i.MPID = g.MPID
	ORDER BY EntityDate DESC, EntityID

END
GO
PRINT N'Creating [Profile.Data].[Group.AddPhoto]...';


GO
CREATE procedure [Profile.Data].[Group.AddPhoto]
	@GroupID INT=NULL,
	@GroupNodeID BIGINT=NULL,
	@Photo VARBINARY(MAX)=NULL,
	@PhotoLink NVARCHAR(MAX)=NULL
AS
BEGIN
	
	SET NOCOUNT ON;
	
	IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
	SELECT @GroupID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID

	-- Only one custom photo per user, so replace any existing custom photos
	IF EXISTS (SELECT 1 FROM [Profile.Data].[Group.Photo] WHERE GroupID = @Groupid)
		BEGIN 
			UPDATE [Profile.Data].[Group.Photo] SET photo = @photo, PhotoLink = @PhotoLink WHERE GroupID = @Groupid 
		END
	ELSE 
		BEGIN 
			INSERT INTO [Profile.Data].[Group.Photo](GroupID ,Photo,PhotoLink) VALUES(@GroupID,@Photo,@PhotoLink)
		END 
	
	DECLARE @NodeID BIGINT
	DECLARE @URI VARCHAR(400)
	DECLARE @URINodeID BIGINT
	SELECT @NodeID = GroupNodeID, @URI = URI
		FROM [Profile.Data].[vwGroup.Photo]
		WHERE GroupID = @GroupID
	IF (@NodeID IS NOT NULL AND @URI IS NOT NULL)
		BEGIN
			EXEC [RDF.].[GetStoreNode] @Value = @URI, @NodeID = @URINodeID OUTPUT
			IF (@URINodeID IS NOT NULL)
				EXEC [RDF.].[GetStoreTriple]	@SubjectID = @NodeID,
												@PredicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#mainImage',
												@ObjectID = @URINodeID
		END
 
END
GO
PRINT N'Creating [Profile.Data].[Group.GetGroup]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.GetGroup]
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Convert URIs and NodeIDs to GroupID
 	IF (@GroupNodeID IS NULL) AND (@GroupURI IS NOT NULL)
		SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 	IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
		SELECT @GroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID

	SELECT * FROM [Profile.Data].[vwGroup.GeneralWithDeleted] where GroupID = @GroupID


END
GO
PRINT N'Creating [Profile.Data].[Group.GetGroups]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.GetGroups]
	@SortBy VARCHAR(50)='GroupName',
	@SortDesc BIT=0,
	@ShowDeletedGroups BIT=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @sql NVARCHAR(MAX)

	SELECT @sql = 'SELECT * FROM [Profile.Data].[vwGroup.GeneralWithDeleted] '
				+(CASE WHEN @ShowDeletedGroups = 0 THEN 'WHERE ViewSecurityGroup <> 0 '
					WHEN @ShowDeletedGroups = 1 THEN 'WHERE ViewSecurityGroup = 0 '
					ELSE '' END)
				+'ORDER BY '
				+(CASE WHEN @SortBy IN ('GroupID','CreateDate','ViewSecurityGroupName','GroupNodeID') 
					THEN @SortBy + (CASE WHEN @SortDesc=1 THEN ' DESC' ELSE '' END) + ', ' 
					ELSE '' END)
				+'GroupName'
				+(CASE WHEN @SortBy='GroupID' THEN '' ELSE ', GroupID' END)

	EXEC sp_executesql @sql

END
GO
PRINT N'Creating [Profile.Data].[Group.GetPhotos]...';


GO
CREATE procedure [Profile.Data].[Group.GetPhotos](@NodeID bigINT)
AS
BEGIN

DECLARE @GroupID INT 

    SELECT @GroupID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
		
	SELECT  photo,
			p.PhotoID		
		FROM [Profile.Data].[Group.Photo] p WITH(NOLOCK)
	 WHERE GroupID=@GroupID  
END
GO
PRINT N'Creating [Profile.Data].[Group.Manager.GetManagers]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.Manager.GetManagers]
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Convert URIs and NodeIDs to GroupID
 	IF (@GroupNodeID IS NULL) AND (@GroupURI IS NOT NULL)
		SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 	IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
		SELECT @GroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID
	
	-- Validate GroupID
	IF (@GroupID IS NULL)
		RETURN;

	-- List the Managers
	SELECT m.GroupID, u.UserID, u.PersonID, u.FirstName, u.LastName, u.DisplayName, u.Institution, u.Department, u.Division, u.EmailAddr
		FROM [Profile.Data].[Group.Manager] m
			INNER JOIN [User.Account].[User] u
				ON m.UserID = u.UserID
		WHERE m.GroupID = @GroupID
		ORDER BY u.LastName, u.FirstName, u.DisplayName, u.UserID

END
GO
PRINT N'Creating [Profile.Data].[Group.Member.AddUpdateMember]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.Member.AddUpdateMember]
	-- Role
	@MemberRoleID VARCHAR(50)=NULL,
	@MemberRoleNodeID BIGINT=NULL,
	@MemberRoleURI VARCHAR(400)=NULL,
	-- Group
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL,
	-- User
	@UserID INT=NULL,
	@UserNodeID BIGINT=NULL,
	@UserURI VARCHAR(400)=NULL,
	-- Other
	@IsApproved bit=NULL,
	@IsVisible bit=NULL,
	@Title nvarchar(255)=NULL,
	@SessionID UNIQUEIDENTIFIER=NULL, 
	@Error BIT=NULL OUTPUT, 
	@NodeID BIGINT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	
	This stored procedure either adds or updates a Group Member.
	Either specify:
	1) A MemberRole by either MemberRoleID, NodeID, or URI.
	2) A Group by either GroupID, NodeID or URI;
		and, a User by UserID, NodeID, or URI.
	
	*/
	
	SELECT @Error = 0

	-------------------------------------------------
	-- Validate and prepare variables
	-------------------------------------------------
	
	-- Convert MemberRoleID to GroupID and NodeID
 	IF (@MemberRoleNodeID IS NULL) AND (@MemberRoleURI IS NOT NULL)
		SELECT @MemberRoleNodeID = [RDF.].fnURI2NodeID(@MemberRoleURI)
 	IF (@MemberRoleID IS NULL) AND (@MemberRoleNodeID IS NOT NULL)
		SELECT @MemberRoleID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @MemberRoleNodeID
	IF (@MemberRoleID IS NOT NULL)
		SELECT @GroupID = GroupID, @UserID = UserID
		FROM [Profile.Data].[Group.Member]
		WHERE MemberRoleID = @MemberRoleID

	-- Convert URIs and NodeIDs to GroupID
 	IF (@GroupNodeID IS NULL) AND (@GroupURI IS NOT NULL)
		SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 	IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
		SELECT @GroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID
	IF @GroupNodeID IS NULL
		SELECT @GroupNodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://xmlns.com/foaf/0.1/Group' AND InternalType = 'Group' AND InternalID = @GroupID

	-- Convert URIs and NodeIDs to UserID
 	IF (@UserNodeID IS NULL) AND (@UserURI IS NOT NULL)
		SELECT @UserNodeID = [RDF.].fnURI2NodeID(@UserURI)
 	IF (@UserID IS NULL) AND (@UserNodeID IS NOT NULL)
		SELECT @UserID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @UserNodeID
	IF @UserNodeID IS NULL
		SELECT @UserNodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User' AND InternalType = 'User' AND InternalID = @UserID

	-- Convert the UserID to a PersonNodeID
	DECLARE @PersonNodeID BIGINT
	SELECT @PersonNodeID = m.NodeID
		FROM [User.Account].[User] u
			INNER JOIN [RDF.Stage].InternalNodeMap m
				ON m.Class = 'http://xmlns.com/foaf/0.1/Person' AND InternalType = 'Person' AND InternalID = u.PersonID
		WHERE u.UserID = @UserID AND u.PersonID IS NOT NULL

	IF @PersonNodeID IS NULL
		RETURN;

	-------------------------------------------------
	-- Create or update the membership
	-------------------------------------------------

	DECLARE @IsActive BIT
	SELECT @MemberRoleID = MemberRoleID, @IsActive = IsActive
		FROM [Profile.Data].[Group.Member] 
		WHERE GroupID=@GroupID AND UserID=@UserID

	DECLARE @labelNodeID BIGINT
	DECLARE @SecurityGroupID BIGINT


	-- Check if this is a new member
	IF @MemberRoleID IS NULL
	BEGIN
		-- Create a MemberRoleID
		SELECT @MemberRoleID = CAST(NEWID() AS VARCHAR(50))
		-- Validate the title
		SELECT @Title = ISNULL(NULLIF(@Title,''),'Member')
		-- Add the new member
		INSERT INTO [Profile.Data].[Group.Member] (MemberRoleID, GroupID, UserID, IsActive, IsApproved, IsVisible, Title)
			SELECT @MemberRoleID, @GroupID, @UserID, 1, ISNULL(@IsApproved,1), ISNULL(@IsVisible,1), @Title

		-- Order the members
		UPDATE x
		SET x.SortOrder = x.memberSort
			FROM (
                SELECT MemberRoleID, SortOrder, ROW_NUMBER () OVER ( ORDER BY lastname, firstname) AS memberSort FROM [Profile.Data].[Group.Member] m
				JOIN [User.Account].[User] u ON m.UserID = u.UserID				
				AND GroupID = @GroupID
			) x

		DECLARE @SortOrder BIGINT
		SELECT @SortOrder = SortOrder FROM [Profile.Data].[Group.Member] where MemberRoleID = @MemberRoleID

		----------------------------------
		-- Create the MemberRole RDF
		----------------------------------
		-- Get the Group's ViewSecurityGroup
		SELECT @SecurityGroupID = ViewSecurityGroup
			FROM [Profile.Data].[Group.General]
			WHERE GroupID = @GroupID
		-- Create the NodeID (hidden by default)
		EXEC [RDF.].GetStoreNode @Class = 'http://vivoweb.org/ontology/core#MemberRole', @InternalType = 'MemberRole', @InternalID = @MemberRoleID,
			@ViewSecurityGroup = @SecurityGroupID, @EditSecurityGroup = -40,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @MemberRoleNodeID OUTPUT
		-- Add the class types
		EXEC [RDF.].GetStoreTriple	@SubjectID = @MemberRoleNodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://vivoweb.org/ontology/core#MemberRole',
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @MemberRoleNodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://vivoweb.org/ontology/core#Role',
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Add the title (label)
		EXEC [RDF.].GetStoreNode	@Value = @Title, 
									@Language = NULL,
									@DataType = NULL,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @labelNodeID OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @MemberRoleNodeID,
									@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
									@ObjectID = @labelNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Link the MemberRole to the Group and the Person
		EXEC [RDF.].GetStoreTriple	@SubjectID = @MemberRoleNodeID,
									@PredicateURI = 'http://vivoweb.org/ontology/core#roleContributesTo',
									@ObjectID = @GroupNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @MemberRoleNodeID,
									@PredicateURI = 'http://vivoweb.org/ontology/core#memberRoleOf',
									@ObjectID = @PersonNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		-- Link the Group and the Person to the MemberRole
		EXEC [RDF.].GetStoreTriple	@SubjectID = @GroupNodeID,
									@PredicateURI = 'http://vivoweb.org/ontology/core#contributingRole',
									@ObjectID = @MemberRoleNodeID,
									@SessionID = @SessionID,
									@SortOrder = @SortOrder,
									@Error = @Error OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @PersonNodeID,
									@PredicateURI = 'http://vivoweb.org/ontology/core#hasMemberRole',
									@ObjectID = @MemberRoleNodeID,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
	END
	ELSE
	BEGIN
		-- Update an existing member
		SELECT @MemberRoleNodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://vivoweb.org/ontology/core#MemberRole' AND InternalType = 'MemberRole' AND InternalID = @MemberRoleID
		-- Confirm the MemberRole NodeID exists
		IF @MemberRoleNodeID IS NULL
			RETURN;
		-- Activate an inactive member
		IF @IsActive = 0
		BEGIN
			UPDATE [Profile.Data].[Group.Member] 
				SET IsActive = 1
				WHERE MemberRoleID = @MemberRoleID
			SELECT @SecurityGroupID = ViewSecurityGroup
				FROM [Profile.Data].[Group.General]
				WHERE GroupID = @GroupID
			UPDATE [RDF.].[Node]
				SET ViewSecurityGroup = @SecurityGroupID
				WHERE NodeID = @MemberRoleNodeID
		END
		-- Update the title
		IF (ISNULL(@Title,'')<>'')
		BEGIN
			-- Update the General table
			UPDATE [Profile.Data].[Group.Member] 
				SET Title = @Title
				WHERE MemberRoleID = @MemberRoleID
			-- Get the NodeID for the label
			EXEC [RDF.].GetStoreNode	@Value = @Title, 
										@Language = NULL,
										@DataType = NULL,
										@SessionID = @SessionID, 
										@Error = @Error OUTPUT, 
										@NodeID = @labelNodeID OUTPUT
			-- Check if a label already exists
			DECLARE @ExistingTripleID BIGINT
			SELECT @ExistingTripleID = TripleID
				FROM [RDF.].[Triple]
				WHERE Subject = @MemberRoleNodeID AND Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
			IF @ExistingTripleID IS NOT NULL
			BEGIN
				-- Update an existing label
				UPDATE [RDF.].[Triple]
					SET Object = @labelNodeID
					WHERE TripleID = @ExistingTripleID
			END
			ELSE
			BEGIN
				-- Create a new label
				EXEC [RDF.].GetStoreTriple	@SubjectID = @MemberRoleNodeID,
											@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
											@ObjectID = @labelNodeID,
											@SessionID = @SessionID,
											@Error = @Error OUTPUT
			END

		END
	END

	SELECT @NodeID = @MemberRoleNodeID

END
GO
PRINT N'Creating [Profile.Data].[Group.Member.DeleteMember]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.Member.DeleteMember]
	-- Role
	@MemberRoleID VARCHAR(50)=NULL,
	@MemberRoleNodeID BIGINT=NULL,
	@MemberRoleURI VARCHAR(400)=NULL,
	-- Group
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL,
	-- User
	@UserID INT=NULL,
	@UserNodeID BIGINT=NULL,
	@UserURI VARCHAR(400)=NULL,
	-- Other
	@SessionID UNIQUEIDENTIFIER=NULL, 
	@Error BIT=NULL OUTPUT, 
	@NodeID BIGINT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	
	This stored procedure deletes a Group Member.
	Either specify:
	1) A MemberRole by either MemberRoleID, NodeID, or URI.
	2) A Group by either GroupID, NodeID or URI;
		and, a User by UserID, NodeID, or URI.
	
	*/
	
	SELECT @Error = 0

	-------------------------------------------------
	-- Validate and prepare variables
	-------------------------------------------------
	
	-- Convert IDs and URIs to MemberRoleID

 	IF (@MemberRoleNodeID IS NULL) AND (@MemberRoleURI IS NOT NULL)
		SELECT @MemberRoleNodeID = [RDF.].fnURI2NodeID(@MemberRoleURI)
 	IF (@MemberRoleID IS NULL) AND (@MemberRoleNodeID IS NOT NULL)
		SELECT @MemberRoleID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @MemberRoleNodeID

	IF (@MemberRoleID IS NULL)
	BEGIN
		-- Convert URIs and NodeIDs to GroupID
 		IF (@GroupNodeID IS NULL) AND (@GroupURI IS NOT NULL)
			SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 		IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
			SELECT @GroupID = CAST(m.InternalID AS INT)
				FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
				WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID

		-- Convert URIs and NodeIDs to UserID
 		IF (@UserNodeID IS NULL) AND (@UserURI IS NOT NULL)
			SELECT @UserNodeID = [RDF.].fnURI2NodeID(@UserURI)
 		IF (@UserID IS NULL) AND (@UserNodeID IS NOT NULL)
			SELECT @UserID = CAST(m.InternalID AS INT)
				FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
				WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @UserNodeID

		-- Lookup the MemberRoleID
		IF (@GroupID IS NOT NULL) AND (@UserID IS NOT NULL)
			SELECT @MemberRoleID = MemberRoleID
			FROM [Profile.Data].[Group.Member]
			WHERE GroupID = @GroupID AND UserID = @UserID
	END

	IF (@MemberRoleID IS NULL)
		RETURN;

	-------------------------------------------------
	-- Delete the MemberRole
	-------------------------------------------------

	SELECT @MemberRoleNodeID = NodeID
		FROM [RDF.Stage].InternalNodeMap
		WHERE Class = 'http://vivoweb.org/ontology/core#MemberRole' AND InternalType = 'MemberRole' AND InternalID = @MemberRoleID

	UPDATE [Profile.Data].[Group.Member]
		SET IsActive = 0
		WHERE MemberRoleID = @MemberRoleID

	IF (@MemberRoleNodeID IS NOT NULL)
		UPDATE [RDF.].[Node]
			SET ViewSecurityGroup = 0
			WHERE NodeID = @MemberRoleNodeID

	SELECT @NodeID = @MemberRoleNodeID

END
GO
PRINT N'Creating [Profile.Data].[Group.Member.GetMembers]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.Member.GetMembers]
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	-- Convert URIs and NodeIDs to GroupID
 	IF (@GroupNodeID IS NULL) AND (@GroupURI IS NOT NULL)
		SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 	IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
		SELECT @GroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID
	
	-- Validate GroupID
	IF (@GroupID IS NULL)
		RETURN;

	-- Get the BaseURI
	DECLARE @baseURI NVARCHAR(400)
	SELECT @baseURI = value FROM [Framework.].Parameter WHERE ParameterID = 'baseURI'

	-- List the Members
	SELECT m.GroupID, u.UserID, u.PersonID, @baseURI+CAST(i.NodeID AS VARCHAR(50)) PersonURI, m.IsApproved, m.IsVisible, m.Title,
			p.FirstName, p.LastName, p.DisplayName, p.InstitutionName, p.DepartmentName, p.DivisionFullName, p.FacultyRank, p.FacultyRankSort
		FROM [Profile.Data].[Group.Member] m
			INNER JOIN [User.Account].[User] u
				ON m.UserID = u.UserID
			INNER JOIN [Profile.Cache].[Person] p
				ON u.PersonID = p.PersonID
			INNER JOIN [RDF.Stage].InternalNodeMap i
				ON i.Class = 'http://xmlns.com/foaf/0.1/Person' AND i.InternalType = 'Person' AND i.InternalID = u.PersonID
		WHERE m.GroupID = @GroupID AND m.IsActive = 1 AND m.IsApproved = 1 AND m.IsVisible = 1
		ORDER BY p.LastName, p.FirstName, p.DisplayName, p.UserID

END
GO
PRINT N'Creating [Profile.Data].[Group.Member.Search]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.Member.Search]
	@LastName nvarchar(100) = NULL,
	@FirstName nvarchar(100) = NULL,
	@Institution nvarchar(500) = NULL,
	@Department nvarchar(500) = NULL,
	@Division nvarchar(500) = NULL,
	@offset INT = 0,
	@limit INT = 20
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET nocount  ON;

	SELECT @offset = IsNull(@offset,0), @limit = IsNull(@limit,1000)
	SELECT @limit = 1000 WHERE @limit > 1000
	
	SELECT	@LastName = (CASE WHEN @LastName = '' THEN NULL ELSE @LastName END),
			@FirstName = (CASE WHEN @FirstName = '' THEN NULL ELSE @FirstName END),
			@Institution = (CASE WHEN @Institution = '' THEN NULL ELSE @Institution END),
			@Department = (CASE WHEN @Department = '' THEN NULL ELSE @Department END),
			@Division = (CASE WHEN @Division = '' THEN NULL ELSE @Division END)

	DECLARE @sql NVARCHAR(MAX)
	
	SELECT @sql = '
		SELECT UserID, PersonID, DisplayName, Institution, Department, EmailAddr
			FROM (
				SELECT UserID, isnull(PersonID, 0) as PersonID, DisplayName, Institution, Department, EmailAddr, 
					row_number() over (order by LastName, FirstName, UserID) k
				FROM [User.Account].[User]
				WHERE IsActive = 1
					AND CanBeProxy = 1
					' + IsNull('AND FirstName LIKE '''+replace(@FirstName,'''','''''')+'%''','') + '
					' + IsNull('AND LastName LIKE '''+replace(@LastName,'''','''''')+'%''','') + '
					' + IsNull('AND Institution = '''+replace(@Institution,'''','''''')+'''','') + '
					' + IsNull('AND Department = '''+replace(@Department,'''','''''')+'''','') + '
					' + IsNull('AND Division = '''+replace(@Division,'''','''''')+'''','') + '
			) t
			WHERE (k >= ' + cast(@offset+1 as varchar(50)) + ') AND (k < ' + cast(@offset+@limit+1 as varchar(50)) + ')
			ORDER BY k
		'

	EXEC sp_executesql @sql

END
GO
PRINT N'Creating [Profile.Data].[Group.UpdateSecurityMembership]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.UpdateSecurityMembership]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	------------------------------------------------------------
	-- Get the users who currently can edit a group
	------------------------------------------------------------

	SELECT s.UserID, ISNULL(m.NodeID,0) NodeID, g.GroupID
		INTO #OldSecurityMembership
		FROM [Profile.Data].[Group.General] g
			INNER JOIN [RDF.Stage].InternalNodeMap m
				ON m.Class = 'http://xmlns.com/foaf/0.1/Group' AND m.InternalType = 'Group' AND m.InternalID = CAST(g.GroupID AS VARCHAR(50))
			INNER JOIN [RDF.Security].[Member] s
				ON m.NodeID = s.SecurityGroupID
		WHERE m.NodeID IS NOT NULL

	ALTER TABLE #OldSecurityMembership ADD PRIMARY KEY (UserID,NodeID)

	------------------------------------------------------------
	-- Get the users who should be able to edit a group
	------------------------------------------------------------

	;WITH a AS (
		SELECT DISTINCT UserID, GroupID
		FROM (
				SELECT a.UserID, g.GroupID
					FROM [Profile.Data].[Group.Admin] a
						CROSS JOIN [Profile.Data].[Group.General] g
					WHERE g.ViewSecurityGroup <> 0
				UNION ALL
				SELECT a.UserID, g.GroupID
					FROM [Profile.Data].[Group.Manager] a
						CROSS JOIN [Profile.Data].[Group.General] g
					WHERE g.ViewSecurityGroup <> 0
			) t 
	)
	SELECT a.UserID, ISNULL(m.NodeID,0) NodeID, a.GroupID
		INTO #NewSecurityMembership
		FROM a INNER JOIN [RDF.Stage].InternalNodeMap m
			ON m.Class = 'http://xmlns.com/foaf/0.1/Group' AND m.InternalType = 'Group' AND m.InternalID = CAST(a.GroupID AS VARCHAR(50))
		WHERE m.NodeID IS NOT NULL

	ALTER TABLE #NewSecurityMembership ADD PRIMARY KEY (UserID,NodeID)

	------------------------------------------------------------
	-- Update the group security membership
	------------------------------------------------------------

	DELETE m
		FROM [RDF.Security].[Member] m
		WHERE EXISTS (SELECT * FROM #OldSecurityMembership o WHERE o.UserID=m.UserID AND o.NodeID=m.SecurityGroupID)
			AND NOT EXISTS (SELECT * FROM #NewSecurityMembership n WHERE n.UserID=m.UserID AND n.NodeID=m.SecurityGroupID)

	INSERT INTO [RDF.Security].[Member] (UserID, SecurityGroupID, IsVisible)
		SELECT UserID, NodeID, 0 IsVisible
		FROM #NewSecurityMembership n
		WHERE NOT EXISTS (SELECT * FROM [RDF.Security].[Member] m WHERE n.UserID=m.UserID AND n.NodeID=m.SecurityGroupID)

END
GO
PRINT N'Creating [Profile.Data].[Publication.Entity.UpdateEntityOneGroup]...';


GO
CREATE PROCEDURE [Profile.Data].[Publication.Entity.UpdateEntityOneGroup]
	@GroupID INT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

 
	-- *******************************************************************
	-- *******************************************************************
	-- Update InformationResource entities
	-- *******************************************************************
	-- *******************************************************************
 
 
	----------------------------------------------------------------------
	-- Get a list of current publications
	----------------------------------------------------------------------
 
	CREATE TABLE #Publications
	(
		PMID INT NULL ,
		MPID NVARCHAR(50) NULL ,
		PMCID NVARCHAR(55) NULL,
		EntityDate DATETIME NULL ,
		Reference VARCHAR(MAX) NULL ,
		Source VARCHAR(25) NULL ,
		URL VARCHAR(1000) NULL ,
		Title VARCHAR(4000) NULL
	)
 
	-- Add PMIDs to the publications temp table
	INSERT  INTO #Publications
            ( PMID ,
			  PMCID,
              EntityDate ,
              Reference ,
              Source ,
              URL ,
              Title
            )
            SELECT -- Get Pub Med pubs
                    PG.PMID ,
					PG.PMCID,
                    EntityDate = PG.PubDate,
                    Reference = REPLACE([Profile.Cache].[fnPublication.Pubmed.General2Reference](PG.PMID,
                                                              PG.ArticleDay,
                                                              PG.ArticleMonth,
                                                              PG.ArticleYear,
                                                              PG.ArticleTitle,
                                                              PG.Authors,
                                                              PG.AuthorListCompleteYN,
                                                              PG.Issue,
                                                              PG.JournalDay,
                                                              PG.JournalMonth,
                                                              PG.JournalYear,
                                                              PG.MedlineDate,
                                                              PG.MedlinePgn,
                                                              PG.MedlineTA,
                                                              PG.Volume, 0),
                                        CHAR(11), '') ,
                    Source = 'PubMed',
                    URL = 'http://www.ncbi.nlm.nih.gov/pubmed/' + CAST(ISNULL(PG.pmid, '') AS VARCHAR(20)),
                    Title = left((case when IsNull(PG.ArticleTitle,'') <> '' then PG.ArticleTitle else 'Untitled Publication' end),4000)
            FROM    [Profile.Data].[Publication.PubMed.General] PG
			WHERE	PG.PMID IN (
						SELECT PMID 
						FROM [Profile.Data].[Publication.Group.Include]
						WHERE PMID IS NOT NULL AND GroupID = @GroupID
					)
					AND PG.PMID NOT IN (
						SELECT PMID
						FROM [Profile.Data].[Publication.Entity.InformationResource]
						WHERE PMID IS NOT NULL
					)
 
	-- Add MPIDs to the publications temp table
	INSERT  INTO #Publications
            ( MPID ,
              EntityDate ,
			  Reference ,
			  Source ,
              URL ,
              Title
            )
            SELECT  MPID ,
                    EntityDate ,
 
 
                     Reference = REPLACE(authors
										+ (CASE WHEN IsNull(article,'') <> '' THEN article + '. ' ELSE '' END)
										+ (CASE WHEN IsNull(pub,'') <> '' THEN pub + '. ' ELSE '' END)
										+ y
                                        + CASE WHEN y <> ''
                                                    AND vip <> '' THEN '; '
                                               ELSE ''
                                          END + vip
                                        + CASE WHEN y <> ''
                                                    OR vip <> '' THEN '.'
                                               ELSE ''
                                          END, CHAR(11), '') ,
                    Source = 'Custom' ,
                    URL = url,
                    Title = left((case when IsNull(article,'')<>'' then article when IsNull(pub,'')<>'' then pub else 'Untitled Publication' end),4000)
            FROM    ( SELECT    MPID ,
                                EntityDate ,
                                url ,
                                authors = CASE WHEN authors = '' THEN ''
                                               WHEN RIGHT(authors, 1) = '.'
                                               THEN LEFT(authors,
                                                         LEN(authors) - 1)
                                               ELSE authors
                                          END ,
                                article = CASE WHEN article = '' THEN ''
                                               WHEN RIGHT(article, 1) = '.'
                                               THEN LEFT(article,
                                                         LEN(article) - 1)
                                               ELSE article
                                          END ,
                                pub = CASE WHEN pub = '' THEN ''
                                           WHEN RIGHT(pub, 1) = '.'
                                           THEN LEFT(pub, LEN(pub) - 1)
                                           ELSE pub
                                      END ,
                                y ,
                                vip
                      FROM      ( SELECT    MPG.mpid ,
                                            EntityDate = MPG.publicationdt ,
                                            authors = CASE WHEN RTRIM(LTRIM(COALESCE(MPG.authors,
                                                              ''))) = ''
                                                           THEN ''
                                                           WHEN RIGHT(COALESCE(MPG.authors,
                                                              ''), 1) = '.'
                                                            THEN  COALESCE(MPG.authors,
                                                              '') + ' '
                                                           ELSE COALESCE(MPG.authors,
                                                              '') + '. '
                                                      END ,
                                            url = CASE WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                            AND LEFT(COALESCE(MPG.url,
                                                              ''), 4) = 'http'
                                                       THEN MPG.url
                                                       WHEN COALESCE(MPG.url,
                                                              '') <> ''
                                                       THEN 'http://' + MPG.url
                                                       ELSE ''
                                                  END ,
                                            article = LTRIM(RTRIM(COALESCE(MPG.articletitle,
                                                              ''))) ,
                                            pub = LTRIM(RTRIM(COALESCE(MPG.pubtitle,
                                                              ''))) ,
                                            y = CASE WHEN MPG.publicationdt > '1/1/1901'
                                                     THEN CONVERT(VARCHAR(50), YEAR(MPG.publicationdt))
                                                     ELSE ''
                                                END ,
                                            vip = COALESCE(MPG.volnum, '')
                                            + CASE WHEN COALESCE(MPG.issuepub,
                                                              '') <> ''
                                                   THEN '(' + MPG.issuepub
                                                        + ')'
                                                   ELSE ''
                                              END
                                            + CASE WHEN ( COALESCE(MPG.paginationpub,
                                                              '') <> '' )
                                                        AND ( COALESCE(MPG.volnum,
                                                              '')
                                                              + COALESCE(MPG.issuepub,
                                                              '') <> '' )
                                                   THEN ':'
                                                   ELSE ''
                                              END + COALESCE(MPG.paginationpub,
                                                             '')
                                  FROM      [Profile.Data].[Publication.Group.MyPub.General] MPG
                                  INNER JOIN [Profile.Data].[Publication.Group.Include] PL ON MPG.mpid = PL.mpid
                                                           AND PL.mpid NOT LIKE 'DASH%'
                                                           AND PL.mpid NOT LIKE 'ISI%'
                                                           AND PL.pmid IS NULL
                                                           AND PL.GroupID = @GroupID
									WHERE MPG.MPID NOT IN (
										SELECT MPID
										FROM [Profile.Data].[Publication.Entity.InformationResource]
										WHERE (MPID IS NOT NULL)
									)
                                ) T0
                    ) T0
 
	CREATE NONCLUSTERED INDEX idx_pmid on #publications(pmid)
	CREATE NONCLUSTERED INDEX idx_mpid on #publications(mpid)

	----------------------------------------------------------------------
	-- Update the Publication.Entity.InformationResource table
	----------------------------------------------------------------------
 
	DECLARE @maxEntityId AS INT
	SELECT @maxEntityId = MAX(EntityID) FROM [Profile.Data].[Publication.Entity.InformationResource]

	-- Insert new publications
	INSERT INTO [Profile.Data].[Publication.Entity.InformationResource] (
			PMID,
			PMCID,
			MPID,
			EntityName,
			EntityDate,
			Reference,
			Source,
			URL,
			IsActive
		)
		SELECT 	PMID,
				PMCID,
				MPID,
				Title,
				EntityDate,
				Reference,
				Source,
				URL,
				1 IsActive
		FROM #publications
	-- Assign an EntityName, PubYear, and YearWeight
	UPDATE e
		SET --e.EntityName = 'Publication ' + CAST(e.EntityID as VARCHAR(50)),
			e.PubYear = year(e.EntityDate),
			e.YearWeight = (case when e.EntityDate is null then 0.5
							when year(e.EntityDate) <= 1901 then 0.5
							else power(cast(0.5 as float),cast(datediff(d,e.EntityDate,GetDate()) as float)/365.25/10)
							end)
		FROM [Profile.Data].[Publication.Entity.InformationResource] e,
			#publications p
		WHERE ((e.PMID = p.PMID) OR (e.MPID = p.MPID))
 

	-- *******************************************************************
	-- *******************************************************************
	-- Update RDF
	-- *******************************************************************
	-- *******************************************************************



	--------------------------------------------------------------
	-- Version 3 : Create stub RDF
	--------------------------------------------------------------


	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
		  	SELECT *, '''SELECT CAST (EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.InformationResource] WHERE EntityID > ' + CAST(@maxEntityId AS VARCHAR(50)) + '''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND property IS NULL
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''' + CAST(@GroupID AS VARCHAR(50)) + '''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://xmlns.com/foaf/0.1/Group'
					AND property = 'http://profiles.catalyst.harvard.edu/ontology/prns#associatedInformationResource'
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END

	--select * from [Ontology.].DataMap


/*

	--------------------------------------------------------------
	-- Version 1 : Create all RDF using ProcessDataMap
	--------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND IsNull(property,'') <> 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND IsNull(property,'') NOT IN ('http://vivoweb.org/ontology/core#linkedAuthor','http://vivoweb.org/ontology/core#linkedInformationResource')
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND property = 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''' + CAST(@PersonID AS VARCHAR(50)) + '''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://xmlns.com/foaf/0.1/Person' 
					AND property = 'http://vivoweb.org/ontology/core#authorInAuthorship'
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		--print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END

*/


/*

	---------------------------------------------------------------------------------
	-- Version 2 : Create new entities using ProcessDataMap, and triples manually
	---------------------------------------------------------------------------------

	CREATE TABLE #sql (
		i INT IDENTITY(0,1) PRIMARY KEY,
		s NVARCHAR(MAX)
	)
	INSERT INTO #sql (s)
		SELECT	'EXEC [RDF.Stage].ProcessDataMap '
					+'  @DataMapID = '+CAST(DataMapID AS VARCHAR(50))
					+', @InternalIdIn = '+InternalIdIn
					+', @TurnOffIndexing=0, @SaveLog=0; '
		FROM (
			SELECT *, '''SELECT CAST(InformationResourceID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#InformationResource' 
					AND IsNull(property,'') <> 'http://vivoweb.org/ontology/core#informationResourceInAuthorship'
					AND NetworkProperty IS NULL
			UNION ALL
			SELECT *, '''SELECT CAST(EntityID AS VARCHAR(50)) FROM [Profile.Data].[Publication.Entity.Authorship] WHERE PersonID = '+CAST(@PersonID AS VARCHAR(50))+'''' InternalIdIn
				FROM [Ontology.].DataMap
				WHERE class = 'http://vivoweb.org/ontology/core#Authorship'
					AND IsNull(property,'') NOT IN ('http://vivoweb.org/ontology/core#linkedAuthor','http://vivoweb.org/ontology/core#linkedInformationResource')
					AND NetworkProperty IS NULL
		) t
		ORDER BY DataMapID

	--select * from #sql
	--return

	DECLARE @s NVARCHAR(MAX)
	WHILE EXISTS (SELECT * FROM #sql)
	BEGIN
		SELECT @s = s
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
		--print @s
		EXEC sp_executesql @s
		DELETE
			FROM #sql
			WHERE i = (SELECT MIN(i) FROM #sql)
	END


	CREATE TABLE #a (
		PersonID INT,
		AuthorshipID INT,
		InformationResourceID INT,
		IsActive BIT,
		PersonNodeID BIGINT,
		AuthorshipNodeID BIGINT,
		InformationResourceNodeID BIGINT,
		AuthorInAuthorshipTripleID BIGINT,
		LinkedAuthorTripleID BIGINT,
		LinkedInformationResourceTripleID BIGINT,
		InformationResourceInAuthorshipTripleID BIGINT,
		AuthorRank INT,
		EntityDate DATETIME,
		TripleWeight FLOAT,
		AuthorRecord INT
	)
	-- Get authorship records
	INSERT INTO #a (PersonID, AuthorshipID, InformationResourceID, IsActive, AuthorRank, EntityDate, TripleWeight, AuthorRecord)
		SELECT PersonID, EntityID, InformationResourceID, IsActive, 
				AuthorRank, EntityDate, IsNull(authorweight * yearweight,0),
				0
			FROM [Profile.Data].[Publication.Entity.Authorship]
			WHERE PersonID = @PersonID
		UNION ALL
		SELECT PersonID, EntityID, InformationResourceID, IsActive, 
				AuthorRank, EntityDate, IsNull(authorweight * yearweight,0),
				1
			FROM [Profile.Data].[Publication.Entity.Authorship]
			WHERE PersonID <> @PersonID 
				AND IsActive = 1
				AND InformationResourceID IN (
					SELECT InformationResourceID
					FROM [Profile.Data].[Publication.Entity.Authorship]
					WHERE PersonID = @PersonID
				)
	-- Get entity IDs
	UPDATE a
		SET a.PersonNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://xmlns.com/foaf/0.1/Person'
			AND m.InternalType = 'Person'
			AND m.InternalID = CAST(a.PersonID AS VARCHAR(50))
	UPDATE a
		SET a.AuthorshipNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://vivoweb.org/ontology/core#Authorship'
			AND m.InternalType = 'Authorship'
			AND m.InternalID = CAST(a.AuthorshipID AS VARCHAR(50))
	UPDATE a
		SET a.InformationResourceNodeID = m.NodeID
		FROM #a a, [RDF.Stage].InternalNodeMap m
		WHERE m.Class = 'http://vivoweb.org/ontology/core#InformationResource'
			AND m.InternalType = 'InformationResource'
			AND m.InternalID = CAST(a.InformationResourceID AS VARCHAR(50))
	-- Get triple IDs
	UPDATE a
		SET a.AuthorInAuthorshipTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.PersonNodeID IS NOT NULL AND a.AuthorshipNodeID IS NOT NULL
			AND t.subject = a.PersonNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#authorInAuthorship')
			AND t.object = a.AuthorshipNodeID
	UPDATE a
		SET a.LinkedAuthorTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.PersonNodeID IS NOT NULL AND a.AuthorshipNodeID IS NOT NULL
			AND t.subject = a.AuthorshipNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedAuthor')
			AND t.object = a.PersonNodeID
	UPDATE a
		SET a.LinkedInformationResourceTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.AuthorshipNodeID IS NOT NULL AND a.InformationResourceID IS NOT NULL
			AND t.subject = a.AuthorshipNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#linkedInformationResource')
			AND t.object = a.InformationResourceNodeID
	UPDATE a
		SET a.InformationResourceInAuthorshipTripleID = t.TripleID
		FROM #a a, [RDF.].Triple t
		WHERE a.AuthorshipNodeID IS NOT NULL AND a.InformationResourceID IS NOT NULL
			AND t.subject = a.InformationResourceNodeID
			AND t.predicate = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#informationResourceInAuthorship')
			AND t.object = a.AuthorshipNodeID
	
	--select * from #a
	--return
	--select * from [ontology.].datamap



	SELECT a.IsActive, a.subject, m._PropertyNode predicate, a.object, 
			a.TripleWeight, 0 ObjectType, a.SortOrder,
			IsNull(s.ViewSecurityGroup, m.ViewSecurityGroup) ViewSecurityGroup,
			a.TripleID, t.SortOrder ExistingSortOrder, X
		INTO #b
		FROM (
				SELECT AuthorshipNodeID subject, InformationResourceNodeID object, TripleWeight, 
						'http://vivoweb.org/ontology/core#Authorship' Class,
						'http://vivoweb.org/ontology/core#linkedInformationResource' Property,
						1 SortOrder,
						IsActive,
						LinkedInformationResourceTripleID TripleID,
						1 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
				UNION ALL
				SELECT AuthorshipNodeID subject, PersonNodeID object, 1 TripleWeight,
						'http://vivoweb.org/ontology/core#Authorship' Class,
						'http://vivoweb.org/ontology/core#linkedAuthor' Property,
						1 SortOrder,
						IsActive,
						LinkedAuthorTripleID TripleID,
						2 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
				UNION ALL
				SELECT InformationResourceNodeID subject, AuthorshipNodeID object, TripleWeight, 
						'http://vivoweb.org/ontology/core#InformationResource' Class,
						'http://vivoweb.org/ontology/core#informationResourceInAuthorship' Property,
						row_number() over (partition by InformationResourceNodeID, IsActive order by AuthorRank, t.SortOrder, AuthorshipNodeID) SortOrder,
						IsActive,
						InformationResourceInAuthorshipTripleID TripleID,
						3 X
					FROM #a a
						LEFT OUTER JOIN [RDF.].[Triple] t
						ON a.InformationResourceInAuthorshipTripleID = t.TripleID
					--WHERE IsActive = 1
				UNION ALL
				SELECT PersonNodeID subject, AuthorshipNodeID object, 1 TripleWeight, 
						'http://xmlns.com/foaf/0.1/Person' Class,
						'http://vivoweb.org/ontology/core#authorInAuthorship' Property,
						row_number() over (partition by PersonNodeID, IsActive order by EntityDate desc) SortOrder,
						IsActive,
						AuthorInAuthorshipTripleID TripleID,
						4 X
					FROM #a
					WHERE AuthorRecord = 0
					--WHERE IsActive = 1
			) a
			INNER JOIN [Ontology.].[DataMap] m
				ON m.Class = a.Class AND m.NetworkProperty IS NULL AND m.Property = a.Property
			LEFT OUTER JOIN [RDF.].[Triple] t
				ON a.TripleID = t.TripleID
			LEFT OUTER JOIN [RDF.Security].[NodeProperty] s
				ON s.NodeID = a.subject
					AND s.Property = m._PropertyNode

	--SELECT * FROM #b ORDER BY X, subject, property, IsActive, sortorder

	-- Delete
	DELETE
		FROM [RDF.].Triple
		WHERE TripleID IN (
			SELECT TripleID
			FROM #b
			WHERE IsActive = 0 AND TripleID IS NOT NULL
		)
	--select @@ROWCOUNT

	-- Update
	UPDATE t
		SET t.SortOrder = b.SortOrder
		FROM [RDF.].Triple t
			INNER JOIN #b b
			ON t.TripleID = b.TripleID
				AND b.IsActive = 1 
				AND b.TripleID IS NOT NULL
				AND b.SortOrder <> b.ExistingSortOrder
	--select @@ROWCOUNT

	-- Insert
	INSERT INTO [RDF.].Triple (Subject,Predicate,Object,TripleHash,Weight,Reitification,ObjectType,SortOrder,ViewSecurityGroup,Graph)
		SELECT Subject,Predicate,Object,
				[RDF.].fnTripleHash(Subject,Predicate,Object),
				TripleWeight,NULL,0,SortOrder,ViewSecurityGroup,1
			FROM #b
			WHERE IsActive = 1 AND TripleID IS NULL
	--select @@ROWCOUNT

*/


END
GO
PRINT N'Creating [Profile.Data].[Publication.GetGroupMemberPublications]...';


GO
CREATE PROCEDURE [Profile.Data].[Publication.GetGroupMemberPublications]
	@GroupID INT=NULL,
	@StartDate DateTime='01/01/1753',
	@EndDate DateTime='01/01/2500',
	@PersonIDs XML=NULL
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	
	CREATE TABLE #pubs (
		PMID int null,
		MPID nvarchar(50) null
	)

	IF @PersonIDs is null
	BEGIN
		insert into #pubs
		  select distinct pmid, mpid from [Profile.Data].[Publication.Person.Include] a
			  join [Profile.Data].Person p on a.PersonID = p.PersonID
			  join [Profile.Data].[Group.Member] g on p.UserID = g.UserID
			  and g.GroupID = @GroupID
			  where (pmid is null or pmid not in (select pmid from [Profile.Data].[Publication.Group.Include] where GroupID = @GroupID and PMID is not null))
			  and (mpid is null or mpid not in (select copiedMPID from [Profile.Data].[Publication.Group.MyPub.General] where GroupID = @GroupID and copiedMPID is not null))
	END 
	ELSE
	BEGIN
		;with People as (
			select nref.value('.','varchar(max)') as PersonID from @PersonIDs.nodes('//PersonIDs/PersonID') as R(nref)
		)
		insert into #pubs
			select distinct pmid, mpid from [Profile.Data].[Publication.Person.Include] a
				join People p on a.PersonID = p.PersonID
				where (pmid is null or pmid not in (select pmid from [Profile.Data].[Publication.Group.Include] where GroupID = @GroupID and PMID is not null))
				and (mpid is null or mpid not in (select copiedMPID from [Profile.Data].[Publication.Group.MyPub.General] where GroupID = @GroupID and copiedMPID is not null))
	END

  select top 100 '' as rownum, reference, case when e.PMID is not null then 'true' else 'false' end as FromPubMed, 0 as PubID, e.pmid, e.mpid, e.url, e.EntityDate as pubdate, '' as category from [Profile.Data].[vwPublication.Entity.InformationResource] e
	  join #pubs a on (a.PMID = e.PMID and e.MPID is null) OR (a.MPID = e.MPID and e.PMID is null)
	  where @StartDate <= isnull(EntityDate,'01/01/1900') and @EndDate >= isnull(EntityDate,'01/01/1900')
	  order by EntityDate desc
END
GO
PRINT N'Creating [Profile.Data].[Publication.GetGroupOption]...';


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
PRINT N'Creating [Profile.Data].[Publication.Group.DeleteAllPublications]...';


GO
CREATE procedure [Profile.Data].[Publication.Group.DeleteAllPublications]
	@GroupID INT,
	@deletePMID BIT = 0,
	@deleteMPID BIT = 0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	BEGIN TRY 
	BEGIN TRANSACTION
			delete from [Profile.Data].[Publication.Group.Include] 
				where GroupID = @GroupID AND (
						( (@deletePMID = 1) AND (@deleteMPID = 0) AND (pmid is not null) )
					or	( (@deletePMID = 0) AND (@deleteMPID = 1) AND (pmid is null) AND (mpid is not null) )
					or	( (@deletePMID = 1) AND (@deleteMPID = 1) )
				)

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		

END
GO
PRINT N'Creating [Profile.Data].[Publication.Group.DeleteOnePublication]...';


GO
CREATE procedure [Profile.Data].[Publication.Group.DeleteOnePublication]
	@GroupID INT,
	@PubID varchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
BEGIN TRY 	 
	BEGIN TRANSACTION

		delete from [Profile.Data].[Publication.Group.Include]  where pubid = @PubID and GroupID = @GroupID

	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		

END
GO
PRINT N'Creating [Profile.Data].[Publication.Group.MyPub.AddPublication]...';


GO
CREATE procedure [Profile.Data].[Publication.Group.MyPub.AddPublication]
	@GroupID INT,
	@HMS_PUB_CATEGORY nvarchar(60) = '',
	@PUB_TITLE nvarchar(2000) = '',
	@ARTICLE_TITLE nvarchar(2000) = '',
	@CONF_EDITORS nvarchar(2000) = '',
	@CONF_LOC nvarchar(2000) = '',
	@EDITION nvarchar(30) = '',
	@PLACE_OF_PUB nvarchar(60) = '',
	@VOL_NUM nvarchar(30) = '',
	@PART_VOL_PUB nvarchar(15) = '',
	@ISSUE_PUB nvarchar(30) = '',
	@PAGINATION_PUB nvarchar(30) = '',
	@ADDITIONAL_INFO nvarchar(2000) = '',
	@PUBLISHER nvarchar(255) = '',
	@CONF_NM nvarchar(2000) = '',
	@CONF_DTS nvarchar(60) = '',
	@REPT_NUMBER nvarchar(35) = '',
	@CONTRACT_NUM nvarchar(35) = '',
	@DISS_UNIV_NM nvarchar(2000) = '',
	@NEWSPAPER_COL nvarchar(15) = '',
	@NEWSPAPER_SECT nvarchar(15) = '',
	@PUBLICATION_DT smalldatetime = '',
	@ABSTRACT varchar(max) = '',
	@AUTHORS varchar(max) = '',
	@URL varchar(1000) = '',
	@created_by varchar(50) = ''
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int,@proc VARCHAR(200),@date DATETIME,@auditid UNIQUEIDENTIFIER 
	SELECT @proc = OBJECT_NAME(@@PROCID),@date=GETDATE() 	
	 
	DECLARE @mpid nvarchar(50)
	SET @mpid = cast(NewID() as nvarchar(50))

	DECLARE @pubid nvarchar(50)
	SET @pubid = cast(NewID() as nvarchar(50))
	BEGIN TRY
	BEGIN TRANSACTION

		INSERT INTO [Profile.Data].[Publication.Group.MyPub.General]
		        (
			mpid,
			GroupID,
			HmsPubCategory,
			PubTitle,
			ArticleTitle,
			ConfEditors,
			ConfLoc,
			EDITION,
			PlaceOfPub,
			VolNum,
			PartVolPub,
			IssuePub,
			PaginationPub,
			AdditionalInfo,
			Publisher,
			ConfNm,
			ConfDts,
			ReptNumber,
			ContractNum,
			DissUnivNM,
			NewspaperCol,
			NewspaperSect,
			PublicationDT,
			ABSTRACT,
			AUTHORS,
			URL,
			CreatedBy,
			CreatedDT,
			UpdatedBy,
			UpdatedDT
		) VALUES (
			@mpid,
			@GroupID,
			@HMS_PUB_CATEGORY,
			@PUB_TITLE,
			@ARTICLE_TITLE,
			@CONF_EDITORS,
			@CONF_LOC,
			@EDITION,
			@PLACE_OF_PUB,
			@VOL_NUM,
			@PART_VOL_PUB,
			@ISSUE_PUB,
			@PAGINATION_PUB,
			@ADDITIONAL_INFO,
			@PUBLISHER,
			@CONF_NM,
			@CONF_DTS,
			@REPT_NUMBER,
			@CONTRACT_NUM,
			@DISS_UNIV_NM,
	@NEWSPAPER_COL,
			@NEWSPAPER_SECT,
			@PUBLICATION_DT,
			@ABSTRACT,
			@AUTHORS,
			@URL,
			@created_by,
			GetDate(),
			@created_by,
			GetDate()
		)

		INSERT INTO [Profile.Data].[Publication.Group.Include]
		        ( PubID, GroupID,   MPID )
			VALUES (@pubid, @GroupID, @mpid)


	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
		SELECT @date=GETDATE()
		EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessEndDate=@date,@error = 1,@insert_new_record=1
		--Raise an error with the details of the exception
		SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

END
GO
PRINT N'Creating [Profile.Data].[Publication.Group.MyPub.CopyExistingPublication]...';


GO
CREATE procedure [Profile.Data].[Publication.Group.MyPub.CopyExistingPublication]
	@GroupID INT,
	@MPID nvarchar(50)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int,@proc VARCHAR(200),@date DATETIME,@auditid UNIQUEIDENTIFIER 
	SELECT @proc = OBJECT_NAME(@@PROCID),@date=GETDATE() 	
	 
	DECLARE @newmpid nvarchar(50)
	SET @newmpid = cast(NewID() as nvarchar(50))

	DECLARE @pubid nvarchar(50)
	SET @pubid = cast(NewID() as nvarchar(50))
	BEGIN TRY
	BEGIN TRANSACTION

		INSERT INTO [Profile.Data].[Publication.Group.MyPub.General]
		        (
			mpid,
			GroupID,
			HmsPubCategory,
			PubTitle,
			ArticleTitle,
			ConfEditors,
			ConfLoc,
			EDITION,
			PlaceOfPub,
			VolNum,
			PartVolPub,
			IssuePub,
			PaginationPub,
			AdditionalInfo,
			Publisher,
			ConfNm,
			ConfDts,
			ReptNumber,
			ContractNum,
			DissUnivNM,
			NewspaperCol,
			NewspaperSect,
			PublicationDT,
			ABSTRACT,
			AUTHORS,
			URL,
			CreatedBy,
			CreatedDT,
			UpdatedBy,
			UpdatedDT,
			CopiedMPID
		) select
			@newmpid,
			@GroupID,
			HmsPubCategory,
			PubTitle,
			ArticleTitle,
			ConfEditors,
			ConfLoc,
			EDITION,
			PlaceOfPub,
			VolNum,
			PartVolPub,
			IssuePub,
			PaginationPub,
			AdditionalInfo,
			Publisher,
			ConfNm,
			ConfDts,
			ReptNumber,
			ContractNum,
			DissUnivNM,
			NewspaperCol,
			NewspaperSect,
			PublicationDT,
			ABSTRACT,
			AUTHORS,
			URL,
			CreatedBy,
			CreatedDT,
			UpdatedBy,
			UpdatedDT,
			@MPID
			from [Profile.Data].[Publication.MyPub.General]
			where MPID = @MPID

		INSERT INTO [Profile.Data].[Publication.Group.Include]
		        ( PubID, GroupID,   MPID )
			VALUES (@pubid, @GroupID, @newmpid)


	COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
		SELECT @date=GETDATE()
		EXEC [Profile.Cache].[Process.AddAuditUpdate] @auditid=@auditid OUTPUT,@ProcessName =@proc,@ProcessEndDate=@date,@error = 1,@insert_new_record=1
		--Raise an error with the details of the exception
		SELECT @ErrMsg = ERROR_MESSAGE(), @ErrSeverity = ERROR_SEVERITY()
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
	END CATCH

END
GO
PRINT N'Creating [Profile.Data].[Publication.Group.Pubmed.AddPublication]...';


GO
CREATE procedure [Profile.Data].[Publication.Group.Pubmed.AddPublication] 
	@GroupNodeID BIGINT=null,
	@pmid int
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DECLARE @GroupID INT

	SELECT @GroupID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID

	if exists (select * from [Profile.Data].[Publication.PubMed.AllXML] where pmid = @pmid)
	begin
 
		declare @ParseDate datetime
		set @ParseDate = (select coalesce(ParseDT,'1/1/1900') from [Profile.Data].[Publication.PubMed.AllXML] where pmid = @pmid)
		if (@ParseDate < '1/1/2000')
		begin
			exec [Profile.Data].[Publication.Pubmed.ParsePubMedXML] 
			 @pmid
		end
 BEGIN TRY 
		BEGIN TRANSACTION
 
			if not exists (select * from [Profile.Data].[Publication.Group.Include] where GroupID = @GroupID and pmid = @pmid)
			begin
 
				declare @pubid uniqueidentifier
				declare @mpid varchar(50)

				set @pubid = (select newid())
				set @mpid = null
 

				insert into [Profile.Data].[Publication.Group.Include](pubid,GroupID,pmid,mpid)
					values (@pubid,@GroupID,@pmid,@mpid)
 
			end
 
		COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int
		--Check success
		IF @@TRANCOUNT > 0  ROLLBACK
 
		-- Raise an error with the details of the exception
		SELECT @ErrMsg =  ERROR_MESSAGE(),
					 @ErrSeverity = ERROR_SEVERITY()
 
		RAISERROR(@ErrMsg, @ErrSeverity, 1)
			 
	END CATCH		
 
	END
 
END
GO
PRINT N'Creating [Profile.Data].[Publication.SetGroupOption]...';


GO
CREATE PROCEDURE [Profile.Data].[Publication.SetGroupOption]
	@GroupID INT=NULL,
	@IncludeMemberPublications INT=0
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	DELETE FROM [Profile.Data].[Publication.Group.Option] WHERE GroupID = @GroupID
	INSERT INTO [Profile.Data].[Publication.Group.Option] (GroupID, IncludeMemberPublications) VALUES (@GroupID, @IncludeMemberPublications)
	
	EXEC [Profile.Data].[Publication.Entity.UpdateEntityOneGroup] @GroupID=@GroupID
END
GO
PRINT N'Creating [Profile.Module].[CustomViewAuthorInAuthorship.GetGroupList]...';


GO
CREATE PROCEDURE [Profile.Module].[CustomViewAuthorInAuthorship.GetGroupList]
	@NodeID bigint = NULL,
	@SessionID uniqueidentifier = NULL
AS
BEGIN

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @NodeID


	declare @AssociatedInformationResource bigint
	select @AssociatedInformationResource = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#associatedInformationResource') 


	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.pmcid vivo_pmcid, p.mpid prns_mpid, p.URL vivo_webpage
	from [RDF.].[Triple] t
		inner join [RDF.].[Node] a
			on t.subject = @NodeID and t.predicate = @AssociatedInformationResource
				and t.object = a.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on t.object = i.NodeID
				and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on m.InternalID = p.EntityID
	order by p.EntityDate desc

/*
	select i.NodeID, p.EntityID, i.Value rdf_about, p.EntityName rdfs_label, 
		p.Reference prns_informationResourceReference, p.EntityDate prns_publicationDate,
		year(p.EntityDate) prns_year, p.pmid bibo_pmid, p.mpid prns_mpid
	from [RDF.].[Triple] t
		inner join [RDF.].[Triple] v
			on t.subject = @NodeID and t.predicate = @AuthorInAuthorship
			and t.object = v.subject and v.predicate = @LinkedInformationResource
			and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			and ((v.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (v.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (v.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] a
			on t.object = a.NodeID
			and ((a.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (a.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (a.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.].[Node] i
			on v.object = i.NodeID
			and ((i.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (i.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (i.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		inner join [RDF.Stage].[InternalNodeMap] m
			on i.NodeID = m.NodeID
		inner join [Profile.Data].[Publication.Entity.InformationResource] p
			on m.InternalID = p.EntityID
	order by p.EntityDate desc
*/

END
GO
PRINT N'Creating [Profile.Module].[NetworkAuthorshipTimeline.Group.GetData]...';


GO
CREATE PROCEDURE [Profile.Module].[NetworkAuthorshipTimeline.Group.GetData]
	@NodeID BIGINT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	DECLARE @GroupID BIGINT
	SELECT @GroupID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID

    -- Insert statements for procedure here
	declare @gc varchar(max)

	declare @y table (
		y int,
		A int,
		B int
	)

	insert into @y (y,A,B)
		select n.n y, coalesce(t.A,0) A, coalesce(t.B,0) B
		from [Utility.Math].[N] left outer join (
			select (case when y < 1970 then 1970 else y end) y,
				sum(A) A,
				sum(B) B
			from (
				select pmid, pubyear y, 1 A, 0 B
				from (
					select g.PMID, YEAR(PubDate) PubYear from [Profile.Data].[Publication.Group.Include] i
					join [Profile.Data].[Publication.PubMed.General] g
					on i.PMID = g.PMID
					and i.GroupID = @GroupID
				) t
			) t
			group by y
		) t on n.n = t.y
		where n.n between 1980 and year(getdate())

	declare @x int

	select @x = max(A+B)
		from @y

	if coalesce(@x,0) > 0
	begin
		declare @v varchar(1000)
		declare @z int
		declare @k int
		declare @i int

		set @z = power(10,floor(log(@x)/log(10)))
		set @k = floor(@x/@z)
		if @x > @z*@k
			select @k = @k + 1
		if @k > 5
			select @k = floor(@k/2.0+0.5), @z = @z*2

		set @v = ''
		set @i = 0
		while @i <= @k
		begin
			set @v = @v + '|' + cast(@z*@i as varchar(50))
			set @i = @i + 1
		end
		set @v = '|0|'+cast(@x as varchar(50))
		--set @v = '|0|50|100'

		declare @h varchar(1000)
		set @h = ''
		select @h = @h + '|' + (case when y % 2 = 1 then '' else ''''+right(cast(y as varchar(50)),2) end)
			from @y
			order by y 

		declare @w float
		--set @w = @k*@z
		set @w = @x

		declare @d varchar(max)
		set @d = ''
		select @d = @d + cast(floor(0.5 + 100*A/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1) + '|'
		select @d = @d + cast(floor(0.5 + 100*B/@w) as varchar(50)) + ','
			from @y
			order by y
		set @d = left(@d,len(@d)-1)

		declare @c varchar(50)
		set @c = 'FB8072,80B1D3'
		--set @c = 'FB8072,B3DE69,80B1D3'
		--set @c = 'F96452,a8dc4f,68a4cc'
		--set @c = 'fea643,76cbbd,b56cb5'

		--select @v, @h, @d

		--set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=First+Author|Middle or Unkown|Last+Author&chco='+@c+'&chbh=10'
		--set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chdl=Major+Topic|Minor+Topic&chco='+@c+'&chbh=10'
		set @gc = '//chart.googleapis.com/chart?chs=595x100&chf=bg,s,ffffff|c,s,ffffff&chxt=x,y&chxl=0:' + @h + '|1:' + @v + '&cht=bvs&chd=t:' + @d + '&chco='+@c+'&chbh=10'


		declare @asText varchar(max)
		set @asText = '<table style="width:592px"><tr><th>Year</th><th>Count</th></tr>'
		select @asText = @asText + '<tr><td>' + cast(y as varchar(50)) + '</td><td>' + cast(A + B as varchar(50)) + '</td></tr>'
			from @y
			where A + B > 0
			order by y 
		select @asText = @asText + '</table>'

		declare @alt varchar(max)
		select @alt = 'Bar chart showing ' + cast(sum(A + B) as varchar(50))+ ' publications over ' + cast(count(*) as varchar(50)) + ' distinct years, with a maximum of ' + cast(@x as varchar(50)) + ' publications in ' from @y where A + B > 0
		select @alt = @alt + cast(y as varchar(50)) + ' and '
			from @y
			where A + B = @x
			order by y 
		select @alt = left(@alt, len(@alt) - 4)

		select @gc gc, @alt alt, @asText asText --, @w w

		--select * from @y order by y

	end

END
GO
PRINT N'Creating [Profile.Module].[NetworkMap.GetGroup]...';


GO
CREATE procedure [Profile.Module].[NetworkMap.GetGroup]
	@NodeID BIGINT=NULL,
	@which INT=0,
	@SessionID UNIQUEIDENTIFIER=NULL
AS
BEGIN

	DECLARE @GroupID INT
	SELECT @GroupID = GroupID FROM [Profile.Data].[vwGroup.General] WHERE GroupNodeID = @NodeID

	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET nocount  ON;
 
	DECLARE  @f  TABLE(
		PersonID INT,
		display_name NVARCHAR(255),
		latitude FLOAT,
		longitude FLOAT,
		address1 NVARCHAR(1000),
		address2 NVARCHAR(1000),
		URI VARCHAR(400)
	)
 
	INSERT INTO @f (	PersonID,
						display_name,
						latitude,
						longitude,
						address1,
						address2
					)
		SELECT	p.PersonID,
				p.displayname,
				l.latitude,
				l.longitude,
				CASE WHEN p.addressstring like '%,%' THEN LEFT(p.addressstring,CHARINDEX(',',p.addressstring) - 1)ELSE P.addressstring END address1,
				CASE WHEN p.addressstring like '%,%' THEN REPLACE(SUBSTRING(p.addressstring,CHARINDEX(',',p.addressstring) + 1,LEN(p.addressstring)),', USA','') ELSE p.addressstring END address2
		FROM [Profile.Data].vwperson p,
				(SELECT PersonID
					FROM [Profile.Data].[vwGroup.Member]
					WHERE GroupID = @GroupID
					and IsActive = 1
				) t,
				[Profile.Data].vwperson l
		 WHERE p.PersonID = t.PersonID
			 AND p.PersonID = l.PersonID
			 AND l.latitude IS NOT NULL
			 AND l.longitude IS NOT NULL
		 ORDER BY p.lastname, p.firstname
 
	UPDATE @f
		SET URI = p.Value + cast(m.NodeID as varchar(50))
		FROM @f, [RDF.Stage].InternalNodeMap m, [Framework.].Parameter p
		WHERE p.ParameterID = 'baseURI' AND m.InternalHash = [RDF.].fnValueHash(null,null,'http://xmlns.com/foaf/0.1/Person^^Person^^'+cast(PersonID as varchar(50)))
 
	DELETE FROM @f WHERE URI IS NULL
 
 
	IF @which = 0
	BEGIN
		SELECT PersonID, 
			display_name,
			latitude,
			longitude,
			address1,
			address2,
			URI
		FROM @f
		ORDER BY address1,
			address2,
			display_name
	END
	ELSE
	BEGIN
		SELECT DISTINCT	a.latitude	x1,
						a.longitude	y1,
						d.latitude	x2,
						d.longitude	y2,
						a.PersonID	a,
						d.PersonID	b,
						0 is_person,
						a.URI u1,
						d.URI u2
			FROM @f a,
					 [Profile.Data].[Publication.Person.Include] b,
					 [Profile.Data].[Publication.Person.Include] c,
					 @f d
		 WHERE a.PersonID = b.PersonID
			 AND b.pmid = c.pmid
			 AND b.PersonID < c.PersonID
			 AND c.PersonID = d.PersonID
	END
		
END
GO
PRINT N'Creating [Profile.Module].[NetworkRadial.Group.GetCoAuthors]...';


GO
CREATE procedure [Profile.Module].[NetworkRadial.Group.GetCoAuthors]
	@NodeID BIGINT,
	@SessionID UNIQUEIDENTIFIER=NULL,
	@OutputFormat VARCHAR(50)='JSON'
AS
BEGIN
	SET NOCOUNT ON;	
	
	DECLARE @GroupID INT
	SELECT @GroupID = CAST(m.InternalID AS INT)
		FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
		WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @NodeID
 
	SELECT TOP 120
					personid,
					distance,
					numberofpaths,
					weight,
					w2,
					lastname,
					firstname,
					p,
					k,
					cast(-1 as bigint) nodeid,
					cast('' as varchar(400)) uri,
					0 nodeindex
		INTO #network 
		FROM ( 
						SELECT p.personid, 
										1 as distance, 
										0 as numberofpaths, 
										0 as weight, 
										0.5 as w2, 
										p.lastname, 
										p.firstname, 
										p.numpublications p, 
										ROW_NUMBER() OVER (ORDER BY p.PersonID DESC) k 
							FROM [Profile.Cache].Person p
							JOIN [Profile.Data].[vwGroup.Member] g
							on p.PersonID = g.PersonID
							  AND p.IsActive = 1
							  and g.GroupID = @GroupID
					) t 
		--WHERE k <= 80 
	ORDER BY distance, k

	--UPDATE #network set distance = 0 where k = 1
	
	UPDATE n
		SET n.NodeID = m.NodeID, n.URI = p.Value + cast(m.NodeID as varchar(50))
		FROM #network n, [RDF.Stage].InternalNodeMap m, [Framework.].Parameter p
		WHERE p.ParameterID = 'baseURI' AND m.InternalHash = [RDF.].fnValueHash(null,null,'http://xmlns.com/foaf/0.1/Person^^Person^^'+cast(n.PersonID as varchar(50)))
 
	DELETE FROM #network WHERE IsNull(URI,'') = ''	
	
	UPDATE a
		SET a.nodeindex = b.ni
		FROM #network a, (
			SELECT *, row_number() over (order by distance desc, k desc)-1 ni
			FROM #network
		) b
		WHERE a.personid = b.personid

	SELECT c.personid1 id1, c.personid2	id2, c.n, CAST(c.w AS VARCHAR) w, 
			(CASE WHEN YEAR(firstpubdate)<1980 THEN 1980 ELSE YEAR(firstpubdate) END) y1, 
			(CASE WHEN YEAR(lastpubdate)<1980 THEN 1980 ELSE YEAR(lastpubdate) END) y2,
			0 k,
			a.nodeid n1, b.nodeid n2, a.uri u1, b.uri u2, a.nodeindex ni1, b.nodeindex ni2
		into #network2
		from #network a
			JOIN #network b on a.personid < b.personid  
			JOIN [Profile.Cache].[SNA.Coauthor] c ON a.personid = c.personid1 and b.personid = c.personid2  
 
	;with a as (
		select id1, id2, w, k from #network2
		union all
		select id2, id1, w, k from #network2
	), b as (
		select a.*, row_number() over (partition by a.id1 order by a.w desc, a.id2) s
		from a, 
			(select id1 from a group by id1 having max(k) = 0) b,
			(select id1 from a group by id1 having max(k) > 0) c
		where a.id1 = b.id1 and a.id2 = c.id1
	)
	update n
		set n.k = 2
		from #network2 n, b
		where (n.id1 = b.id1 and n.id2 = b.id2 and b.s = 1) or (n.id1 = b.id2 and n.id2 = b.id1 and b.s = 1)
 
	update n
		set n.k = 3
		from #network2 n, (
			select *, row_number() over (order by k desc, w desc) r 
			from #network2 
		) r
		where n.id1=r.id1 and n.id2=r.id2 and n.k=0 and r.r<=360
 
	IF @OutputFormat = 'XML'
	BEGIN
		SELECT (
			SELECT (
				SELECT personid "@id", nodeid "@nodeid", uri "@uri", distance "@d", p "@pubs", firstname "@fn", lastname "@ln", cast(w2 as varchar(50)) "@w2"
				FROM #network
				FOR XML PATH('NetworkPerson'),ROOT('NetworkPeople'),TYPE
			), (
				SELECT id1 "@id1", id2 "@id2", n "@n", cast(w as varchar(50)) "@w", y1 "@y1", y2 "@y2",
					n1 "@nodeid1", n2 "@nodeid2", u1 "@uri1", u2 "@uri2"
				FROM #network2
				WHERE k > 0
				FOR XML PATH('NetworkCoAuthor'),ROOT('NetworkCoAuthors'),TYPE
			)
			FOR XML PATH('LocalNetwork'), TYPE) [XML]
	END

	IF @OutputFormat = 'JSON'
	BEGIN
		SELECT
			'{'+CHAR(10)
			+'"NetworkPeople":['+CHAR(10)
			+SUBSTRING(ISNULL(CAST((
				SELECT	',{'
						+'"id":'+cast(personid as varchar(50))+','
						+'"nodeid":'+cast(nodeid as varchar(50))+','
						+'"uri":"'+uri+'",'
						+'"d":'+cast(distance as varchar(50))+',' 
						+'"pubs":'+cast(p as varchar(50))+',' 
						+'"fn":"'+firstname+'",' 
						+'"ln":"'+lastname+'",'
						+'"w2":'+cast(w2 as varchar(50))
						+'}'+CHAR(10)
				FROM #network
				ORDER BY nodeindex
				FOR XML PATH(''),TYPE
			) as VARCHAR(MAX)),''),2,9999999)
			+'],'+CHAR(10)
			+'"NetworkCoAuthors":['+CHAR(10)
			+SUBSTRING(ISNULL(CAST((
				SELECT	',{'
						+'"source":'+cast(ni2 as varchar(50))+','
						+'"target":'+cast(ni1 as varchar(50))+','
						+'"n":'+cast(n as varchar(50))+','
						+'"w":'+cast(w as varchar(50))+',' 
						+'"id1":'+cast(id1 as varchar(50))+','
						+'"id2":'+cast(id2 as varchar(50))+','
						+'"y1":'+cast(y1 as varchar(50))+',' 
						+'"y2":'+cast(y2 as varchar(50))+',' 
						+'"nodeid1":'+cast(n1 as varchar(50))+','
						+'"nodeid2":'+cast(n2 as varchar(50))+','
						+'"uri1":"'+u1+'",'
						+'"uri2":"'+u2+'"'
						+'}'+CHAR(10)
				FROM #network2
				ORDER BY ni2, ni1
				FOR XML PATH(''),TYPE
			) as VARCHAR(MAX)),''),2,9999999)
			+']'+CHAR(10)
			+'}' JSON
	END  
END
GO
PRINT N'Altering [RDF.].[GetDataRDF]...';


GO
ALTER PROCEDURE [RDF.].[GetDataRDF]
	@subject BIGINT=NULL,
	@predicate BIGINT=NULL,
	@object BIGINT=NULL,
	@offset BIGINT=NULL,
	@limit BIGINT=NULL,
	@showDetails BIT=1,
	@expand BIT=1,
	@SessionID UNIQUEIDENTIFIER=NULL,
	@NodeListXML XML=NULL,
	@ExpandRDFListXML XML=NULL,
	@returnXML BIT=1,
	@returnXMLasStr BIT=0,
	@dataStr NVARCHAR (MAX)=NULL OUTPUT,
	@dataStrDataType NVARCHAR (255)=NULL OUTPUT,
	@dataStrLanguage NVARCHAR (255)=NULL OUTPUT,
	@RDF XML=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*

	This stored procedure returns the data for a node in RDF format.

	Input parameters:
		@subject		The NodeID whose RDF should be returned.
		@predicate		The predicate NodeID for a network.
		@object			The object NodeID for a connection.
		@offset			Pagination - The first object node to return.
		@limit			Pagination - The number of object nodes to return.
		@showDetails	If 1, then additional properties will be returned.
		@expand			If 1, then object properties will be expanded.
		@SessionID		The SessionID of the user requesting the data.

	There are two ways to call this procedure. By default, @returnXML = 1,
	and the RDF is returned as XML. When @returnXML = 0, the data is instead
	returned as the strings @dataStr, @dataStrDataType, and @dataStrLanguage.
	This second method of calling this procedure is used by other procedures
	and is generally not called directly by the website.

	The RDF returned by this procedure is not equivalent to what is
	returned by SPARQL. This procedure applies security rules, expands
	nodes as defined by [Ontology.].[RDFExpand], and calculates network
	information on-the-fly.

	*/

	--declare @debugLogID int
	--insert into [RDF.].[GetDataRDF.DebugLog] (subject,predicate,object,offset,limit,showDetails,expand,SessionID,StartDate)
	--	select @subject,@predicate,@object,@offset,@limit,@showDetails,@expand,@SessionID,GetDate()
	--select @debugLogID = @@IDENTITY
	--insert into [RDF.].[GetDataRDF.DebugLog.ExpandRDFListXML] (LogID, ExpandRDFListXML)
	--	select @debugLogID, @ExpandRDFListXML

	
	declare @d datetime

	declare @baseURI nvarchar(400)
	select @baseURI = value from [Framework.].Parameter where ParameterID = 'baseURI'

	select @subject = null where @subject = 0
	select @predicate = null where @predicate = 0
	select @object = null where @object = 0
		
	declare @firstURI nvarchar(400)
	select @firstURI = @baseURI+cast(@subject as varchar(50))

	declare @firstValue nvarchar(400)
	select @firstValue = null
	
	declare @typeID bigint
	select @typeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')

	declare @labelID bigint
	select @labelID = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')	

	declare @validURI bit
	select @validURI = 1

	--*******************************************************************************************
	--*******************************************************************************************
	-- Define temp tables
	--*******************************************************************************************
	--*******************************************************************************************

	/*
		drop table #subjects
		drop table #types
		drop table #expand
		drop table #properties
		drop table #connections
	*/

	create table #subjects (
		subject bigint primary key,
		showDetail bit,
		expanded bit,
		uri nvarchar(400)
	)
	
	create table #types (
		subject bigint not null,
		object bigint not null,
		predicate bigint,
		showDetail bit,
		uri nvarchar(400)
	)
	create unique clustered index idx_sop on #types (subject,object,predicate)

	create table #expand (
		subject bigint not null,
		predicate bigint not null,
		uri nvarchar(400),
		property nvarchar(400),
		tagName nvarchar(1000),
		propertyLabel nvarchar(400),
		IsDetail bit,
		limit bigint,
		showStats bit,
		showSummary bit
	)
	alter table #expand add primary key (subject,predicate)

	create table #properties (
		uri nvarchar(400),
		subject bigint,
		predicate bigint,
		object bigint,
		showSummary bit,
		property nvarchar(400),
		tagName nvarchar(1000),
		propertyLabel nvarchar(400),
		Language nvarchar(255),
		DataType nvarchar(255),
		Value nvarchar(max),
		ObjectType bit,
		SortOrder int
	)

	create table #connections (
		subject bigint,
		subjectURI nvarchar(400),
		predicate bigint,
		predicateURI nvarchar(400),
		object bigint,
		Language nvarchar(255),
		DataType nvarchar(255),
		Value nvarchar(max),
		ObjectType bit,
		SortOrder int,
		Weight float,
		Reitification bigint,
		ReitificationURI nvarchar(400),
		connectionURI nvarchar(400)
	)
	
	create table #ClassPropertyCustom (
		ClassPropertyID int primary key,
		IncludeProperty bit,
		Limit int,
		IncludeNetwork bit,
		IncludeDescription bit
	)

	--*******************************************************************************************
	--*******************************************************************************************
	-- Setup variables used for security
	--*******************************************************************************************
	--*******************************************************************************************

	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT, @HasSecurityGroupNodes BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @Subject
	SELECT @HasSecurityGroupNodes = (CASE WHEN EXISTS (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END)


	--*******************************************************************************************
	--*******************************************************************************************
	-- Check if user has access to the URI
	--*******************************************************************************************
	--*******************************************************************************************

	if @subject is not null
		select @validURI = 0
			where not exists (
				select *
				from [RDF.].Node
				where NodeID = @subject
					and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
			)

	if @predicate is not null
		select @validURI = 0
			where not exists (
				select *
				from [RDF.].Node
				where NodeID = @predicate and ObjectType = 0
					and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
			)

	if @object is not null
		select @validURI = 0
			where not exists (
				select *
				from [RDF.].Node
				where NodeID = @object and ObjectType = 0
					and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
			)


	--*******************************************************************************************
	--*******************************************************************************************
	-- Get subject information when it is a literal
	--*******************************************************************************************
	--*******************************************************************************************

	select @dataStr = Value, @dataStrDataType = DataType, @dataStrLanguage = Language
		from [RDF.].Node
		where NodeID = @subject and ObjectType = 1
			and ( (ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )


	--*******************************************************************************************
	--*******************************************************************************************
	-- Seed temp tables
	--*******************************************************************************************
	--*******************************************************************************************

	---------------------------------------------------------------------------------------------
	-- Profile [seed with the subject(s)]
	---------------------------------------------------------------------------------------------
	if (@subject is not null) and (@predicate is null) and (@object is null)
	begin
		insert into #subjects(subject,showDetail,expanded,URI)
			select NodeID, @showDetails, 0, Value
				from [RDF.].Node
				where NodeID = @subject
					and ((ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		select @firstValue = URI
			from #subjects s, [RDF.].Node n
			where s.subject = @subject
				and s.subject = n.NodeID and n.ObjectType = 0
	end
	if (@NodeListXML is not null)
	begin
		insert into #subjects(subject,showDetail,expanded,URI)
			select n.NodeID, t.ShowDetails, 0, n.Value
			from [RDF.].Node n, (
				select NodeID, MAX(ShowDetails) ShowDetails
				from (
					select x.value('@ID','bigint') NodeID, IsNull(x.value('@ShowDetails','tinyint'),0) ShowDetails
					from @NodeListXML.nodes('//Node') as N(x)
				) t
				group by NodeID
				having NodeID not in (select subject from #subjects)
			) t
			where n.NodeID = t.NodeID and n.ObjectType = 0
	end
	
	---------------------------------------------------------------------------------------------
	-- Get all connections
	---------------------------------------------------------------------------------------------
	insert into #connections (subject, subjectURI, predicate, predicateURI, object, Language, DataType, Value, ObjectType, SortOrder, Weight, Reitification, ReitificationURI, connectionURI)
		select	s.NodeID subject, s.value subjectURI, 
				p.NodeID predicate, p.value predicateURI,
				t.object, o.Language, o.DataType, o.Value, o.ObjectType,
				t.SortOrder, t.Weight, 
				r.NodeID Reitification, r.Value ReitificationURI,
				@baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50))+'/'+cast(object as varchar(50)) connectionURI
			from [RDF.].Triple t
				inner join [RDF.].Node s
					on t.subject = s.NodeID
				inner join [RDF.].Node p
					on t.predicate = p.NodeID
				inner join [RDF.].Node o
					on t.object = o.NodeID
				left join [RDF.].Node r
					on t.reitification = r.NodeID
						and t.reitification is not null
						and ((r.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (r.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (r.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
			where @subject is not null and @predicate is not null
				and s.NodeID = @subject 
				and p.NodeID = @predicate 
				and o.NodeID = IsNull(@object,o.NodeID)
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((s.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (s.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (s.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((p.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (p.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (p.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))

	-- Make sure there are connections
	if (@subject is not null) and (@predicate is not null)
		select @validURI = 0
		where not exists (select * from #connections)

	---------------------------------------------------------------------------------------------
	-- Network [seed with network statistics and connections]
	---------------------------------------------------------------------------------------------
	if (@subject is not null) and (@predicate is not null) and (@object is null)
	begin
		select @firstURI = @baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50))
		-- Basic network properties
		;with networkProperties as (
			select 1 n, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' property, 'rdf:type' tagName, 'type' propertyLabel, 0 ObjectType
			union all select 2, 'http://profiles.catalyst.harvard.edu/ontology/prns#numberOfConnections', 'prns:numberOfConnections', 'number of connections', 1
			union all select 3, 'http://profiles.catalyst.harvard.edu/ontology/prns#maxWeight', 'prns:maxWeight', 'maximum connection weight', 1
			union all select 4, 'http://profiles.catalyst.harvard.edu/ontology/prns#minWeight', 'prns:minWeight', 'minimum connection weight', 1
			union all select 5, 'http://profiles.catalyst.harvard.edu/ontology/prns#predicateNode', 'prns:predicateNode', 'predicate node', 0
			union all select 6, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate', 'rdf:predicate', 'predicate', 0
			union all select 7, 'http://www.w3.org/2000/01/rdf-schema#label', 'rdfs:label', 'label', 1
			union all select 8, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#subject', 'rdf:subject', 'subject', 0
		), networkStats as (
			select	cast(isnull(count(*),0) as varchar(50)) numberOfConnections,
					cast(isnull(max(Weight),1) as varchar(50)) maxWeight,
					cast(isnull(min(Weight),1) as varchar(50)) minWeight,
					max(predicateURI) predicateURI
				from #connections
		), subjectLabel as (
			select IsNull(Max(o.Value),'') Label
			from [RDF.].Triple t, [RDF.].Node o
			where t.subject = @subject
				and t.predicate = @labelID
				and t.object = o.NodeID
				and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
				and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
		)
		insert into #properties (uri,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
			select	@firstURI,
					[RDF.].fnURI2NodeID(p.property), p.property, p.tagName, p.propertyLabel,
					(case p.n when 1 then 'http://profiles.catalyst.harvard.edu/ontology/prns#Network'
								when 2 then n.numberOfConnections
								when 3 then n.maxWeight
								when 4 then n.minWeight
								when 5 then @baseURI+cast(@predicate as varchar(50))
								when 6 then n.predicateURI
								when 7 then l.Label
								when 8 then @baseURI+cast(@subject as varchar(50))
								end),
					p.ObjectType,
					1
				from networkStats n, networkProperties p, subjectLabel l
		-- Limit the number of connections if the subject is not a person or a group
		select @limit = 10
			where (@limit is null) 
				and not exists (
					select *
					from [rdf.].[triple]
					where subject = @subject
						and predicate = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')
						and object in ( [RDF.].fnURI2NodeID('http://xmlns.com/foaf/0.1/Person') , [RDF.].fnURI2NodeID('http://xmlns.com/foaf/0.1/Group') )
				)
		-- Remove connections not within offset-limit window
		delete from #connections
			where (SortOrder < 1+IsNull(@offset,0)) or (SortOrder > IsNull(@limit,SortOrder) + (case when IsNull(@offset,0)<1 then 0 else @offset end))
		-- Add hasConnection properties
		insert into #properties (uri,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
			select	@baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50)),
					[RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#hasConnection'), 
					'http://profiles.catalyst.harvard.edu/ontology/prns#hasConnection', 'prns:hasConnection', 'has connection',
					connectionURI,
					0,
					SortOrder
				from #connections
	end

	---------------------------------------------------------------------------------------------
	-- Connection [seed with connection]
	---------------------------------------------------------------------------------------------
	if (@subject is not null) and (@predicate is not null) and (@object is not null)
	begin
		select @firstURI = @baseURI+cast(@subject as varchar(50))+'/'+cast(@predicate as varchar(50))+'/'+cast(@object as varchar(50))
	end

	---------------------------------------------------------------------------------------------
	-- Expanded Connections [seed with statistics, subject, object, and connectionDetails]
	---------------------------------------------------------------------------------------------
	if (@expand = 1 or @object is not null) and exists (select * from #connections)
	begin
		-- Connection statistics
		;with connectionProperties as (
			select 1 n, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type' property, 'rdf:type' tagName, 'type' propertyLabel, 0 ObjectType
			union all select 2, 'http://profiles.catalyst.harvard.edu/ontology/prns#connectionWeight', 'prns:connectionWeight', 'connection weight', 1
			union all select 3, 'http://profiles.catalyst.harvard.edu/ontology/prns#sortOrder', 'prns:sortOrder', 'sort order', 1
			union all select 4, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#object', 'rdf:object', 'object', 0
			union all select 5, 'http://profiles.catalyst.harvard.edu/ontology/prns#hasConnectionDetails', 'prns:hasConnectionDetails', 'connection details', 0
			union all select 6, 'http://profiles.catalyst.harvard.edu/ontology/prns#predicateNode', 'prns:predicateNode', 'predicate node', 0
			union all select 7, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate', 'rdf:predicate', 'predicate', 0
			union all select 8, 'http://www.w3.org/2000/01/rdf-schema#label', 'rdfs:label', 'label', 1
			union all select 9, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#subject', 'rdf:subject', 'subject', 0
			union all select 10, 'http://profiles.catalyst.harvard.edu/ontology/prns#connectionInNetwork', 'prns:connectionInNetwork', 'connection in network', 0
		)
		insert into #properties (uri,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
			select	connectionURI,
					[RDF.].fnURI2NodeID(p.property), p.property, p.tagName, p.propertyLabel,
					(case p.n	when 1 then 'http://profiles.catalyst.harvard.edu/ontology/prns#Connection'
								when 2 then cast(c.Weight as varchar(50))
								when 3 then cast(c.SortOrder as varchar(50))
								when 4 then c.value
								when 5 then c.ReitificationURI
								when 6 then @baseURI+cast(@predicate as varchar(50))
								when 7 then c.predicateURI
								when 8 then l.value
								when 9 then c.subjectURI
								when 10 then c.subjectURI+'/'+cast(@predicate as varchar(50))
								end),
					(case p.n when 4 then c.ObjectType else p.ObjectType end),
					1
				from #connections c, connectionProperties p
					left outer join (
						select o.value
							from [RDF.].Triple t, [RDF.].Node o
							where t.subject = @subject 
								and t.predicate = @labelID
								and t.object = o.NodeID
								and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
								and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)))
					) l on p.n = 8
				where (p.n < 5) 
					or (p.n = 5 and c.ReitificationURI is not null)
					or (p.n > 5 and @object is not null)
		if (@expand = 1)
		begin
			-- Connection subject
			insert into #subjects (subject, showDetail, expanded, URI)
				select NodeID, 0, 0, Value
					from [RDF.].Node
					where NodeID = @subject
			-- Connection objects
			insert into #subjects (subject, showDetail, expanded, URI)
				select object, 0, 0, value
					from #connections
					where ObjectType = 0 and object not in (select subject from #subjects)
			-- Connection details (reitifications)
			insert into #subjects (subject, showDetail, expanded, URI)
				select Reitification, 0, 0, ReitificationURI
					from #connections
					where Reitification is not null and Reitification not in (select subject from #subjects)
		end
	end

	--*******************************************************************************************
	--*******************************************************************************************
	-- Get property values
	--*******************************************************************************************
	--*******************************************************************************************

	-- Get custom settings to override the [Ontology.].[ClassProperty] default values
	insert into #ClassPropertyCustom (ClassPropertyID, IncludeProperty, Limit, IncludeNetwork, IncludeDescription)
		select p.ClassPropertyID, t.IncludeProperty, t.Limit, t.IncludeNetwork, t.IncludeDescription
			from [Ontology.].[ClassProperty] p
				inner join (
					select	x.value('@Class','varchar(400)') Class,
							x.value('@NetworkProperty','varchar(400)') NetworkProperty,
							x.value('@Property','varchar(400)') Property,
							(case x.value('@IncludeProperty','varchar(5)') when 'true' then 1 when 'false' then 0 else null end) IncludeProperty,
							x.value('@Limit','int') Limit,
							(case x.value('@IncludeNetwork','varchar(5)') when 'true' then 1 when 'false' then 0 else null end) IncludeNetwork,
							(case x.value('@IncludeDescription','varchar(5)') when 'true' then 1 when 'false' then 0 else null end) IncludeDescription
					from @ExpandRDFListXML.nodes('//ExpandRDF') as R(x)
				) t
				on p.Class=t.Class and p.Property=t.Property
					and ((p.NetworkProperty is null and t.NetworkProperty is null) or (p.NetworkProperty = t.NetworkProperty))

	-- Get properties and loop if objects need to be expanded
	declare @numLoops int
	declare @maxLoops int
	declare @actualLoops int
	declare @NewSubjects int
	select @numLoops = 0, @maxLoops = 10, @actualLoops = 0
	while (@numLoops < @maxLoops)
	begin
		-- Get the types of each subject that hasn't been expanded
		truncate table #types
		insert into #types(subject,object,predicate,showDetail,uri)
			select s.subject, t.object, null, s.showDetail, s.uri
				from #subjects s 
					inner join [RDF.].Triple t on s.subject = t.subject 
						and t.predicate = @typeID 
					inner join [RDF.].Node n on t.object = n.NodeID
						and ((n.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (n.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN n.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
						and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				where s.expanded = 0				   
		-- Get the subject types of each reitification that hasn't been expanded
		insert into #types(subject,object,predicate,showDetail,uri)
		select distinct s.subject, t.object, r.predicate, s.showDetail, s.uri
			from #subjects s 
				inner join [RDF.].Triple r on s.subject = r.reitification
				inner join [RDF.].Triple t on r.subject = t.subject 
					and t.predicate = @typeID 
				inner join [RDF.].Node n on t.object = n.NodeID
					and ((n.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (n.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN n.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					and ((r.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (r.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN r.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
			where s.expanded = 0
		-- Get the items that should be expanded
		truncate table #expand
		insert into #expand(subject, predicate, uri, property, tagName, propertyLabel, IsDetail, limit, showStats, showSummary)
			select p.subject, o._PropertyNode, max(p.uri) uri, o.property, o._TagName, o._PropertyLabel, min(o.IsDetail*1) IsDetail, 
					(case when min(o.IsDetail*1) = 0 then max(case when o.IsDetail=0 then IsNull(c.limit,o.limit) else null end) else max(IsNull(c.limit,o.limit)) end) limit,
					(case when min(o.IsDetail*1) = 0 then max(case when o.IsDetail=0 then IsNull(c.IncludeNetwork,o.IncludeNetwork)*1 else 0 end) else max(IsNull(c.IncludeNetwork,o.IncludeNetwork)*1) end) showStats,
					(case when min(o.IsDetail*1) = 0 then max(case when o.IsDetail=0 then IsNull(c.IncludeDescription,o.IncludeDescription)*1 else 0 end) else max(IsNull(c.IncludeDescription,o.IncludeDescription)*1) end) showSummary
				from #types p
					inner join [Ontology.].ClassProperty o
						on p.object = o._ClassNode 
						and ((p.predicate is null and o._NetworkPropertyNode is null) or (p.predicate = o._NetworkPropertyNode))
						and o.IsDetail <= p.showDetail
					left outer join #ClassPropertyCustom c
						on o.ClassPropertyID = c.ClassPropertyID
				where IsNull(c.IncludeProperty,1) = 1
				group by p.subject, o.property, o._PropertyNode, o._TagName, o._PropertyLabel
		-- Get the values for each property that should be expanded
		insert into #properties (uri,subject,predicate,object,showSummary,property,tagName,propertyLabel,Language,DataType,Value,ObjectType,SortOrder)
			select e.uri, e.subject, t.predicate, t.object, e.showSummary,
					e.property, e.tagName, e.propertyLabel, 
					o.Language, o.DataType, o.Value, o.ObjectType, t.SortOrder
			from #expand e
				inner join [RDF.].Triple t
					on t.subject = e.subject and t.predicate = e.predicate
						and (e.limit is null or t.sortorder <= e.limit)
						and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				inner join [RDF.].Node p
					on t.predicate = p.NodeID
						and ((p.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (p.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN p.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				inner join [RDF.].Node o
					on t.object = o.NodeID
						and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
		-- Get network properties
		if (@numLoops = 0)
		begin
			-- Calculate network statistics
			select e.uri, e.subject, t.predicate, e.property, e.tagName, e.PropertyLabel, 
					cast(isnull(count(*),0) as varchar(50)) numberOfConnections,
					cast(isnull(max(t.Weight),1) as varchar(50)) maxWeight,
					cast(isnull(min(t.Weight),1) as varchar(50)) minWeight,
					@baseURI+cast(e.subject as varchar(50))+'/'+cast(t.predicate as varchar(50)) networkURI
				into #networks
				from #expand e
					inner join [RDF.].Triple t
						on t.subject = e.subject and t.predicate = e.predicate
							and (e.showStats = 1)
							and ((t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					inner join [RDF.].Node p
						on t.predicate = p.NodeID
							and ((p.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (p.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN p.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
					inner join [RDF.].Node o
						on t.object = o.NodeID
							and ((o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (1 = CASE WHEN @HasSecurityGroupNodes = 0 THEN 0 WHEN o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes) THEN 1 ELSE 0 END))
				group by e.uri, e.subject, t.predicate, e.property, e.tagName, e.PropertyLabel
			-- Create properties from network statistics
			;with networkProperties as (
				select 1 n, 'http://profiles.catalyst.harvard.edu/ontology/prns#hasNetwork' property, 'prns:hasNetwork' tagName, 'has network' propertyLabel, 0 ObjectType
				union all select 2, 'http://profiles.catalyst.harvard.edu/ontology/prns#numberOfConnections', 'prns:numberOfConnections', 'number of connections', 1
				union all select 3, 'http://profiles.catalyst.harvard.edu/ontology/prns#maxWeight', 'prns:maxWeight', 'maximum connection weight', 1
				union all select 4, 'http://profiles.catalyst.harvard.edu/ontology/prns#minWeight', 'prns:minWeight', 'minimum connection weight', 1
				union all select 5, 'http://profiles.catalyst.harvard.edu/ontology/prns#predicateNode', 'prns:predicateNode', 'predicate node', 0
				union all select 6, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#predicate', 'rdf:predicate', 'predicate', 0
				union all select 7, 'http://www.w3.org/2000/01/rdf-schema#label', 'rdfs:label', 'label', 1
				union all select 8, 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type', 'rdf:type', 'type', 0
			)
			insert into #properties (uri,subject,predicate,property,tagName,propertyLabel,Value,ObjectType,SortOrder)
				select	(case p.n when 1 then n.uri else n.networkURI end),
						(case p.n when 1 then subject else null end),
						[RDF.].fnURI2NodeID(p.property), p.property, p.tagName, p.propertyLabel,
						(case p.n when 1 then n.networkURI 
									when 2 then n.numberOfConnections
									when 3 then n.maxWeight
									when 4 then n.minWeight
									when 5 then @baseURI+cast(n.predicate as varchar(50))
									when 6 then n.property
									when 7 then n.PropertyLabel
									when 8 then 'http://profiles.catalyst.harvard.edu/ontology/prns#Network'
									end),
						p.ObjectType,
						1
					from #networks n, networkProperties p
					where p.n = 1 or @expand = 1
		end
		-- Mark that all previous subjects have been expanded
		update #subjects set expanded = 1 where expanded = 0
		-- See if there are any new subjects that need to be expanded
		insert into #subjects(subject,showDetail,expanded,uri)
			select distinct object, 0, 0, value
				from #properties
				where showSummary = 1
					and ObjectType = 0
					and object not in (select subject from #subjects)
		select @NewSubjects = @@ROWCOUNT		
		insert into #subjects(subject,showDetail,expanded,uri)
			select distinct predicate, 0, 0, property
				from #properties
				where predicate is not null
					and predicate not in (select subject from #subjects)
		-- If no subjects need to be expanded, then we are done
		if @NewSubjects + @@ROWCOUNT = 0
			select @numLoops = @maxLoops
		select @numLoops = @numLoops + 1 + @maxLoops * (1 - @expand)
		select @actualLoops = @actualLoops + 1
	end
	-- Add tagName as a property of DatatypeProperty and ObjectProperty classes
	insert into #properties (uri, subject, showSummary, property, tagName, propertyLabel, Value, ObjectType, SortOrder)
		select p.uri, p.subject, 0, 'http://profiles.catalyst.harvard.edu/ontology/prns#tagName', 'prns:tagName', 'tag name', 
				n.prefix+':'+substring(p.uri,len(n.uri)+1,len(p.uri)), 1, 1
			from #properties p, [Ontology.].Namespace n
			where p.property = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type'
				and p.value in ('http://www.w3.org/2002/07/owl#DatatypeProperty','http://www.w3.org/2002/07/owl#ObjectProperty')
				and p.uri like n.uri+'%'
	--select @actualLoops
	--select * from #properties order by (case when uri = @firstURI then 0 else 1 end), uri, tagName, value


	--*******************************************************************************************
	--*******************************************************************************************
	-- Handle the special case where a local node is storing a copy of an external URI
	--*******************************************************************************************
	--*******************************************************************************************

	if (@firstValue IS NOT NULL) AND (@firstValue <> @firstURI)
		insert into #properties (uri, subject, predicate, object, 
				showSummary, property, 
				tagName, propertyLabel, 
				Language, DataType, Value, ObjectType, SortOrder
			)
			select @firstURI uri, @subject subject, predicate, object, 
					showSummary, property, 
					tagName, propertyLabel, 
					Language, DataType, Value, ObjectType, 1 SortOrder
				from #properties
				where uri = @firstValue
					and not exists (select * from #properties where uri = @firstURI)
			union all
			select @firstURI uri, @subject subject, null predicate, null object, 
					0 showSummary, 'http://www.w3.org/2002/07/owl#sameAs' property,
					'owl:sameAs' tagName, 'same as' propertyLabel, 
					null Language, null DataType, @firstValue Value, 0 ObjectType, 1 SortOrder

	--*******************************************************************************************
	--*******************************************************************************************
	-- Generate an XML string from the node properties table
	--*******************************************************************************************
	--*******************************************************************************************

	declare @description nvarchar(max)
	select @description = ''
	-- sort the tags
	select *, 
			row_number() over (partition by uri order by i) j, 
			row_number() over (partition by uri order by i desc) k 
		into #propertiesSorted
		from (
			select *, row_number() over (order by (case when uri = @firstURI then 0 else 1 end), uri, tagName, SortOrder, value) i
				from #properties
		) t
	create unique clustered index idx_i on #propertiesSorted(i)
	-- handle special xml characters in the uri and value strings
	update #propertiesSorted
		set uri = replace(replace(replace(uri,'&','&amp;'),'<','&lt;'),'>','&gt;')
		where uri like '%[&<>]%'
	update #propertiesSorted
		set value = replace(replace(replace(value,'&','&amp;'),'<','&lt;'),'>','&gt;')
		where value like '%[&<>]%'
	-- concatenate the tags
	select @description = (
			select (case when j=1 then '<rdf:Description rdf:about="' + uri + '">' else '' end)
					+'<'+tagName
					+(case when ObjectType = 0 then ' rdf:resource="'+value+'"/>' else '>'+value+'</'+tagName+'>' end)
					+(case when k=1 then '</rdf:Description>' else '' end)
			from #propertiesSorted
			order by i
			for xml path(''), type
		).value('(./text())[1]','nvarchar(max)')
	-- default description if none exists
	if (@description IS NULL) OR (@validURI = 0)
		select @description = '<rdf:Description rdf:about="' + @firstURI + '"'
			+IsNull(' xml:lang="'+@dataStrLanguage+'"','')
			+IsNull(' rdf:datatype="'+@dataStrDataType+'"','')
			+IsNull(' >'+replace(replace(replace(@dataStr,'&','&amp;'),'<','&lt;'),'>','&gt;')+'</rdf:Description>',' />')


	--*******************************************************************************************
	--*******************************************************************************************
	-- Return as a string or as XML
	--*******************************************************************************************
	--*******************************************************************************************

	select @dataStr = IsNull(@dataStr,@description)

	declare @x as varchar(max)
	select @x = '<rdf:RDF'
	select @x = @x + ' xmlns:'+Prefix+'="'+URI+'"' 
		from [Ontology.].Namespace
	select @x = @x + ' >' + @description + '</rdf:RDF>'

	if @returnXML = 1 and @returnXMLasStr = 0
		select cast(replace(@x,char(13),'&#13;') as xml) RDF

	if @returnXML = 1 and @returnXMLasStr = 1
		select @x RDF

	--update [RDF.].[GetDataRDF.DebugLog]
	--	set DurationMS = DATEDIFF(ms,StartDate,GetDate())
	--	where LogiD = @debugLogID

	/*	
		declare @d datetime
		select @d = getdate()
		select datediff(ms,@d,getdate())
	*/
		
END
GO
PRINT N'Altering [RDF.].[GetPresentationXML]...';


GO
ALTER PROCEDURE [RDF.].[GetPresentationXML]
@subject BIGINT=NULL, @predicate BIGINT=NULL, @object BIGINT=NULL, @subjectType BIGINT=NULL, @objectType BIGINT=NULL, @SessionID UNIQUEIDENTIFIER=NULL, @EditMode BIT=0, @returnXML BIT=1, @PresentationXML XML=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	declare @typeID bigint
	select @typeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')

	select @subject = null where @subject = 0
	select @predicate = null where @predicate = 0
	select @object = null where @object = 0

	declare @SecurityGroupListXML xml
	select @SecurityGroupListXML = NULL

	declare @NetworkNode bigint
	declare @ConnectionNode bigint
	select	@NetworkNode = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#Network'),
			@ConnectionNode = [RDF.].fnURI2NodeID('http://profiles.catalyst.harvard.edu/ontology/prns#Connection')


	-------------------------------------------------------------------------------
	-- Determine the PresentationType (P = profile, N = network, C = connection)
	-------------------------------------------------------------------------------

	declare @PresentationType char(1)
	select @PresentationType = (case when IsNull(@object,@objectType) is not null AND @predicate is not null AND IsNull(@subject,@subjectType) is not null then 'C'
									when @predicate is not null AND IsNull(@subject,@subjectType) is not null then 'N'
									when IsNull(@subject,@subjectType) is not null then 'P'
									else NULL end)

	-------------------------------------------------------------------------------
	-- Determine whether the user can edit this profile
	-------------------------------------------------------------------------------

	DECLARE @CanEdit BIT
	SELECT @CanEdit = 0
	DECLARE @SecurityGroupID BIGINT, @HasSpecialViewAccess BIT, @HasSpecialEditAccess BIT
	EXEC [RDF.Security].GetSessionSecurityGroup @SessionID, @SecurityGroupID OUTPUT, @HasSpecialViewAccess OUTPUT, @HasSpecialEditAccess OUTPUT
	CREATE TABLE #SecurityGroupNodes (SecurityGroupNode BIGINT PRIMARY KEY)
	IF (@PresentationType = 'P') AND (@SessionID IS NOT NULL)
	BEGIN
		-- Get SecurityGroup nodes
		INSERT INTO #SecurityGroupNodes (SecurityGroupNode) EXEC [RDF.Security].GetSessionSecurityGroupNodes @SessionID, @Subject
		SELECT @CanEdit = 1
			FROM [RDF.].Node
			WHERE NodeID = @subject
				AND ( (EditSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (EditSecurityGroup > 0 AND @HasSpecialEditAccess = 1) OR (EditSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
		-- Get names/descriptions of different SecurityGroups
		IF @CanEdit = 1 AND @EditMode = 1
		BEGIN
			;WITH a AS (
				SELECT 1 x, m.NodeID SecurityGroupID, 'Only Me' Label, 'Only me and special authorized users who manage this website.' Description
					FROM [User.Session].[Session] s, [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
					WHERE s.SessionID = @SessionID AND s.UserID IS NOT NULL
						AND m.InternalID = s.UserID AND m.Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User' AND m.InternalType = 'User'
						AND n.NodeID = @Subject AND n.EditSecurityGroup = m.NodeID 
			), b AS (
				SELECT 2 x, n.EditSecurityGroup SecurityGroupID, 'Owner' Label, 'Only ' + IsNull(Max(o.Value),'') + ' and special authorized users who manage this website.' Description
					FROM [RDF.].Node n, [RDF.].Triple t, [RDF.].Node o, [RDF.Stage].[InternalNodeMap] m
					WHERE n.NodeID = @Subject AND n.EditSecurityGroup > 0
						AND n.EditSecurityGroup NOT IN (SELECT SecurityGroupID FROM a)
						AND n.NodeID = m.NodeID
						AND m.Class = 'http://xmlns.com/foaf/0.1/Person'
						AND t.Subject = n.NodeID 
						AND t.Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label') 
						AND t.Object = o.NodeID
						AND ( (n.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (n.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (n.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
						AND ( (t.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (t.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (t.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
						AND ( (o.ViewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (o.ViewSecurityGroup > 0 AND @HasSpecialViewAccess = 1) OR (o.ViewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
					GROUP BY n.EditSecurityGroup
			), c AS (
				SELECT 3 x, n.EditSecurityGroup SecurityGroupID, 'Owner' Label, 'Only managers of this profile and special authorized users who manage this website.' Description
					FROM [RDF.].Node n
					WHERE n.NodeID = @Subject AND n.EditSecurityGroup > 0
						AND n.EditSecurityGroup NOT IN (SELECT SecurityGroupID FROM a UNION SELECT SecurityGroupID FROM b)
					GROUP BY n.EditSecurityGroup
			), d AS (
				SELECT 4 x, SecurityGroupID, Label, Description
					FROM [RDF.Security].[Group]
					WHERE SecurityGroupID between @SecurityGroupID and -1
				UNION ALL SELECT * FROM a
				UNION ALL SELECT * FROM b
				UNION ALL SELECT * FROM c
			)
			SELECT @SecurityGroupListXML = (
				SELECT	SecurityGroupID "@ID",
						Label "@Label",
						Description "@Description"
					FROM d
					ORDER BY x, SecurityGroupID
					FOR XML PATH('SecurityGroup'), TYPE
			)
		END
	END

	-------------------------------------------------------------------------------
	-- Get the PresentationID based on type
	-------------------------------------------------------------------------------

	declare @PresentationID int
	select @PresentationID = (
			select top 1 PresentationID
				from [Ontology.Presentation].[XML]
				where type = (case when @EditMode = 1 then 'E' else IsNull(@PresentationType,'P') end)
					AND	(_SubjectNode IS NULL
							OR _SubjectNode = @subjectType
							OR _SubjectNode IN (select object from [RDF.].Triple where @subject is not null and subject=@subject and predicate=@typeID)
						)
					AND	(_PredicateNode IS NULL
							OR _PredicateNode = @predicate
						)
					AND	(_ObjectNode IS NULL
							OR _ObjectNode = @objectType
							OR _ObjectNode IN (select object from [RDF.].Triple where @object is not null and subject=@object and predicate=@typeID)
						)
				order by	(case when _ObjectNode is null then 1 else 0 end),
							(case when _PredicateNode is null then 1 else 0 end),
							(case when _SubjectNode is null then 1 else 0 end),
							PresentationID
		)

	-------------------------------------------------------------------------------
	-- Get the PropertyListXML based on type
	-------------------------------------------------------------------------------

	declare @PropertyListXML xml
	if @EditMode = 0
	begin
		-- View properties
		select @PropertyListXML = (
			select PropertyGroupURI "@URI", _PropertyGroupLabel "@Label", SortOrder "@SortOrder", x.query('.')
			from (
				select PropertyGroupURI, _PropertyGroupLabel, SortOrder,
				(
					select	a.URI "@URI", 
							a.TagName "@TagName", 
							a.Label "@Label", 
							p.SortOrder "@SortOrder",
							(case when a.CustomDisplay = 1 then 'true' else 'false' end) "@CustomDisplay",
							cast(a.CustomDisplayModule as xml)
					from [ontology.].PropertyGroupProperty p, (
						select NodeID,
							max(URI) URI, 
							max(TagName) TagName, 
							max(Label) Label,
							max(CustomDisplay) CustomDisplay,
							max(CustomDisplayModule) CustomDisplayModule
						from (
								select
									c._PropertyNode NodeID,
									c.Property URI,
									c._TagName TagName,
									c._PropertyLabel Label,
									cast(c.CustomDisplay as tinyint) CustomDisplay,
									IsNull(cast(c.CustomDisplayModule as nvarchar(max)),cast(p.CustomDisplayModule as nvarchar(max))) CustomDisplayModule
								from [Ontology.].ClassProperty c
									left outer join [Ontology.].PropertyGroupProperty p
									on c.Property = p.PropertyURI
								where c._ClassNode in (
									select object 
										from [RDF.].Triple 
										where subject=@subject and predicate=@typeID and @predicate is null and @object is null
									union all
									select @NetworkNode
										where @subject is not null and @predicate is not null and @object is null
									union all
									select @ConnectionNode
										where @subject is not null and @predicate is not null and @object is not null
								)
								and 1 = (case	when c._NetworkPropertyNode is null and @predicate is null then 1
												when c._NetworkPropertyNode is null and @predicate is not null and @object is null and c._ClassNode = @NetworkNode then 1
												when c._NetworkPropertyNode is null and @predicate is not null and @object is not null and c._ClassNode = @ConnectionNode then 1
												when c._NetworkPropertyNode = @predicate and @object is not null then 1
												else 0 end)
							) t
						group by NodeID
					) a
					where p._PropertyNode = a.NodeID and p._PropertyGroupNode = g._PropertyGroupNode
					order by p.SortOrder
					for xml path('Property'), type
				) x
				from [ontology.].PropertyGroup g
			) t
			where x is not null
			order by SortOrder
			for xml path('PropertyGroup'), type
		)
	end
	else
	begin
		-- Edit properties
		select @PropertyListXML = (
			select PropertyGroupURI "@URI", _PropertyGroupLabel "@Label", SortOrder "@SortOrder", x.query('.')
			from (
				select PropertyGroupURI, _PropertyGroupLabel, SortOrder,
				(
					select	a.URI "@URI", 
							a.TagName "@TagName", 
							a.Label "@Label", 
							p.SortOrder "@SortOrder",
							IsNull(s.ViewSecurityGroup,a.ViewSecurityGroup) "@ViewSecurityGroup",
							(case when a.CustomEdit = 1 then 'true' else 'false' end) "@CustomEdit",
							(case when a.EditPermissions = 1 then 'true' else 'false' end) "@EditPermissions",
							(case when a.EditExisting = 1 then 'true' else 'false' end) "@EditExisting",
							(case when a.EditAddNew = 1 then 'true' else 'false' end) "@EditAddNew",
							(case when a.EditAddExisting = 1 then 'true' else 'false' end) "@EditAddExisting",
							(case when a.EditDelete = 1 then 'true' else 'false' end) "@EditDelete",
							a.MinCardinality "@MinCardinality",
							a.MaxCardinality "@MaxCardinality",
							a.ObjectType "@ObjectType",
							(case when a.HasDataFeed = 1 then 'true' else 'false' end) "@HasDataFeed",
							cast(a.CustomEditModule as xml)
					from [ontology.].PropertyGroupProperty p inner join (
						select NodeID,
							max(URI) URI, 
							max(TagName) TagName, 
							max(Label) Label,
							max(ViewSecurityGroup) ViewSecurityGroup,
							max(CustomEdit) CustomEdit,
							max(EditPermissions) EditPermissions,
							max(EditExisting) EditExisting,
							max(EditAddNew) EditAddNew,
							max(EditAddExisting) EditAddExisting,
							max(EditDelete) EditDelete,
							min(MinCardinality) MinCardinality,
							max(MaxCardinality) MaxCardinality,
							max(cast(ObjectType as tinyint)) ObjectType,
							max(HasDataFeed) HasDataFeed,
							max(CustomEditModule) CustomEditModule
						from (
								select
									c._PropertyNode NodeID,
									c.Property URI,
									c._TagName TagName,
									c._PropertyLabel Label,
									c.ViewSecurityGroup,
									cast(c.CustomEdit as tinyint) CustomEdit,
									(case when ( (EditPermissionsSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (EditPermissionsSecurityGroup > 0 AND @HasSpecialEditAccess = 1) OR (EditPermissionsSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) ) then 1 else 0 end) EditPermissions,
									(case when ( (EditExistingSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (EditExistingSecurityGroup > 0 AND @HasSpecialEditAccess = 1) OR (EditExistingSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) ) then 1 else 0 end) EditExisting,
									(case when ( (EditAddNewSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (EditAddNewSecurityGroup > 0 AND @HasSpecialEditAccess = 1) OR (EditAddNewSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) ) then 1 else 0 end) EditAddNew,
									(case when ( (EditAddExistingSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (EditAddExistingSecurityGroup > 0 AND @HasSpecialEditAccess = 1) OR (EditAddExistingSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) ) then 1 else 0 end) EditAddExisting,
									(case when ( (EditDeleteSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (EditDeleteSecurityGroup > 0 AND @HasSpecialEditAccess = 1) OR (EditDeleteSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) ) then 1 else 0 end) EditDelete,
									c.MinCardinality,
									c.MaxCardinality,
									c._ObjectType ObjectType,
									(case when d._PropertyNode is null then 0 else 1 end) HasDataFeed,
									IsNull(cast(c.CustomEditModule as nvarchar(max)),cast(p.CustomEditModule as nvarchar(max))) CustomEditModule
								from [Ontology.].ClassProperty c
									left outer join (
										select distinct _ClassNode, _PropertyNode
										from [Ontology.].DataMap
										where NetworkProperty is null and _ClassNode is not null and _PropertyNode is not null and IsAutoFeed = 1
									) d
										on c._ClassNode = d._ClassNode and c._PropertyNode = d._PropertyNode
									left outer join [Ontology.].PropertyGroupProperty p
										on c.Property = p.PropertyURI
								where c._ClassNode in (
									select object 
										from [RDF.].Triple 
										where subject=@subject and predicate=@typeID and @predicate is null and @object is null
								)
								and c.Property is not null
								and c.NetworkProperty is null
								and ( (EditSecurityGroup BETWEEN @SecurityGroupID AND -1) OR (EditSecurityGroup > 0 AND @HasSpecialEditAccess = 1) OR (EditSecurityGroup IN (SELECT * FROM #SecurityGroupNodes)) )
							) t
						group by NodeID
					) a
					on p._PropertyNode = a.NodeID and p._PropertyGroupNode = g._PropertyGroupNode
					left outer join [RDF.Security].NodeProperty s
					on s.NodeID = @subject and s.Property = p._PropertyNode 
					order by p.SortOrder
					for xml path('Property'), type
				) x
				from [ontology.].PropertyGroup g
			) t
			where x is not null
			order by SortOrder
			for xml path('PropertyGroup'), type
		)
	end	

	-------------------------------------------------------------------------------
	-- Combine the PresentationXML with property information
	-------------------------------------------------------------------------------

	select @PresentationXML = (
		select
			PresentationXML.value('Presentation[1]/@PresentationClass[1]','varchar(max)') "@PresentationClass",
			PresentationXML.value('Presentation[1]/PageOptions[1]/@Columns[1]','varchar(max)') "PageOptions/@Columns",
			(case when @CanEdit = 1 then 'true' else NULL end) "PageOptions/@CanEdit",
			(case when @CanEdit = 1 then 'true' else NULL end) "CanEdit",
			PresentationXML.query('Presentation[1]/WindowName[1]'),
			PresentationXML.query('Presentation[1]/PageColumns[1]'),
			PresentationXML.query('Presentation[1]/PageTitle[1]'),
			PresentationXML.query('Presentation[1]/PageBackLinkName[1]'),
			PresentationXML.query('Presentation[1]/PageBackLinkURL[1]'),
			PresentationXML.query('Presentation[1]/PageSubTitle[1]'),
			PresentationXML.query('Presentation[1]/PageDescription[1]'),
			PresentationXML.query('Presentation[1]/PanelTabType[1]'),
			PresentationXML.query('Presentation[1]/PanelList[1]'),
			PresentationXML.query('Presentation[1]/ExpandRDFList[1]'),
			@PropertyListXML "PropertyList",
			@SecurityGroupListXML "SecurityGroupList"
		from [Ontology.Presentation].[XML]
		where presentationid = @PresentationID
		for xml path('Presentation'), type
	)
	
	if @returnXML = 1
		select @PresentationXML PresentationXML

END
GO
PRINT N'Creating [Profile.Data].[Group.AddUpdateGroup]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.AddUpdateGroup]
	@ExistingGroupID INT=NULL, 
	@ExistingGroupNodeID BIGINT=NULL,
	@ExistingGroupURI VARCHAR(400)=NULL,
	@GroupName VARCHAR(MAX)=NULL,
	@EndDate DATETIME=NULL,
	@ViewSecurityGroup BIGINT=NULL,
	@SessionID UNIQUEIDENTIFIER=NULL, 
	@Error BIT=NULL OUTPUT, 
	@NodeID BIGINT=NULL OUTPUT
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	
	This stored procedure either creates or updates a Group.
	Groups can be specified either by GroupID, NodeID or URI.
	
	*/
	
	SELECT @Error = 0

	-------------------------------------------------
	-- Validate and prepare variables
	-------------------------------------------------
	
	-- Convert URIs and NodeIDs to GroupID
 	IF (@ExistingGroupNodeID IS NULL) AND (@ExistingGroupURI IS NOT NULL)
		SELECT @ExistingGroupNodeID = [RDF.].fnURI2NodeID(@ExistingGroupURI)
 	IF (@ExistingGroupID IS NULL) AND (@ExistingGroupNodeID IS NOT NULL)
		SELECT @ExistingGroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @ExistingGroupNodeID

	-------------------------------------------------
	-- Create a new group if needed
	-------------------------------------------------

	IF @ExistingGroupID IS NULL
	BEGIN
		-- Create the GroupID
		INSERT INTO [Profile.Data].[Group.General] (GroupName, ViewSecurityGroup, CreateDate, EndDate)
			SELECT ISNULL(NULLIF(@GroupName,''),'New Group'), ISNULL(@ViewSecurityGroup,0), GetDate(), ISNULL(@EndDate,DATEADD(yy,10,CAST(GetDate() AS DATE)))
		SELECT @ExistingGroupID = @@IDENTITY
		-- Create the NodeID (hidden by default)
		EXEC [RDF.].GetStoreNode @Class = 'http://xmlns.com/foaf/0.1/Group', @InternalType = 'Group', @InternalID = @ExistingGroupID,
			@ViewSecurityGroup = 0, @EditSecurityGroup = -40,
			@SessionID = @SessionID, @Error = @Error OUTPUT, @NodeID = @NodeID OUTPUT
		UPDATE [RDF.].[Node] SET EditSecurityGroup = @NodeID WHERE NodeID = @NodeID
		-- Add the class types
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://xmlns.com/foaf/0.1/Agent',
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://www.w3.org/1999/02/22-rdf-syntax-ns#type',
									@ObjectURI = 'http://xmlns.com/foaf/0.1/Group',
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		/*
		-- Add a hasGroupSettings property
		DECLARE @BooleanTrueNodeID BIGINT
		EXEC [RDF.].GetStoreNode	@Value = 'true', 
									@Language = NULL,
									@DataType = 'http://www.w3.org/2001/XMLSchema#boolean',
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @BooleanTrueNodeID OUTPUT
		EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
									@PredicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#hasGroupSettings',
									@ObjectID = @BooleanTrueNodeID,
									@ViewSecurityGroup = -1,
									@Weight = 1,
									@SessionID = @SessionID,
									@Error = @Error OUTPUT
		*/
		-- Set the ViewSecurityGroup to the NodeID to make it private by default
		SELECT @ViewSecurityGroup = ISNULL(@ViewSecurityGroup,@NodeID)
		-- Make sure the group has a valid name
		SELECT @GroupName = ISNULL(NULLIF(@GroupName,''),'New Group '+CAST(@ExistingGroupID AS VARCHAR(50)))
		-- Give all admins access to the group
		EXEC [Profile.Data].[Group.UpdateSecurityMembership]
	END

	-------------------------------------------------
	-- Update an existing group
	-------------------------------------------------

	-- Get the group's NodeID
	IF @NodeID IS NULL
		SELECT @NodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://xmlns.com/foaf/0.1/Group' AND InternalType = 'Group' AND InternalID = CAST(@ExistingGroupID AS VARCHAR(50))

	-- Update the ViewSecurityGroup
	IF @ViewSecurityGroup IS NOT NULL
	BEGIN
		UPDATE [Profile.Data].[Group.General] 
			SET ViewSecurityGroup = @ViewSecurityGroup 
			WHERE GroupID = @ExistingGroupID
		UPDATE [RDF.].[Node] 
			SET ViewSecurityGroup = @ViewSecurityGroup 
			WHERE NodeID = @NodeID

		DECLARE @contributingRole BIGINT
		SELECT @contributingRole = NodeID FROM [RDF.].Node 
			WHERE ValueHash = [RDF.].fnValueHash(null, null, 'http://vivoweb.org/ontology/core#contributingRole')

		UPDATE n 
			SET n.ViewSecurityGroup = @ViewSecurityGroup 
			FROM [RDF.].Node n 
			JOIN [RDF.].Triple t
			ON n.NodeID = t.Object AND t.Subject = @NodeID AND Predicate = @contributingRole
	END

	-- Update the EndDate
	IF @EndDate IS NOT NULL
	BEGIN
		UPDATE [Profile.Data].[Group.General] 
			SET EndDate = @EndDate 
			WHERE GroupID = @ExistingGroupID
	END

	-- Update the label
	IF NULLIF(@GroupName,'')<>''
	BEGIN
		-- Update the General table
		UPDATE [Profile.Data].[Group.General] 
			SET GroupName = @GroupName 
			WHERE GroupID = @ExistingGroupID
		-- Get the NodeID for the label
		DECLARE @labelNodeID BIGINT
		EXEC [RDF.].GetStoreNode	@Value = @GroupName, 
									@Language = NULL,
									@DataType = NULL,
									@SessionID = @SessionID, 
									@Error = @Error OUTPUT, 
									@NodeID = @labelNodeID OUTPUT
		-- Check if a label already exists
		DECLARE @ExistingTripleID BIGINT
		SELECT @ExistingTripleID = TripleID
			FROM [RDF.].[Triple]
			WHERE Subject = @NodeID AND Predicate = [RDF.].fnURI2NodeID('http://www.w3.org/2000/01/rdf-schema#label')
		IF @ExistingTripleID IS NOT NULL
		BEGIN
			-- Update an existing label
			UPDATE [RDF.].[Triple]
				SET Object = @labelNodeID
				WHERE TripleID = @ExistingTripleID
		END
		ELSE
		BEGIN
			-- Create a new label
			EXEC [RDF.].GetStoreTriple	@SubjectID = @NodeID,
										@PredicateURI = 'http://www.w3.org/2000/01/rdf-schema#label',
										@ObjectID = @labelNodeID,
										@SessionID = @SessionID,
										@Error = @Error OUTPUT
		END
	END

END
GO
PRINT N'Creating [Profile.Data].[Group.DeleteRestoreGroup]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.DeleteRestoreGroup]
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL,
	@RestoreGroup BIT=0,
	@SessionID UNIQUEIDENTIFIER=NULL, 
	@Error BIT=NULL OUTPUT, 
	@NodeID BIGINT=NULL OUTPUT	
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	
	This stored procedure either deletes or restores a Group.
	Groups can be specified either by GroupID, NodeID or URI.
	
	*/
	
	SELECT @Error = 0

	-------------------------------------------------
	-- Validate and prepare variables
	-------------------------------------------------

	-- Check that the group is only specified in one way
	IF (CASE WHEN @GroupID IS NULL THEN 0 ELSE 1 END)+(CASE WHEN @GroupNodeID IS NULL THEN 0 ELSE 1 END)+(CASE WHEN @GroupURI IS NULL THEN 0 ELSE 1 END) <> 1
		RETURN;
	
	-- Convert URIs and NodeIDs to GroupID
 	IF (@GroupURI IS NOT NULL)
		SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 	IF (@GroupNodeID IS NOT NULL)
		SELECT @GroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID
 
 	IF (@GroupNodeID IS NULL)
		select @GroupNodeID = NodeID from [RDF.Stage].[InternalNodeMap] where status=3 and class = 'http://xmlns.com/foaf/0.1/Group' and InternalID = @GroupID

	-- Make sure both a GroupID and GroupNodeID exist
	IF (@GroupID IS NULL) OR (@GroupNodeID IS NULL)
		RETURN;
select @GroupID, @GroupNodeID

	DECLARE @contributingRoleID BIGINT
	SELECT @contributingRoleID = [RDF.].fnURI2NodeID('http://vivoweb.org/ontology/core#contributingRole')

	-------------------------------------------------
	-- Delete a group
	-------------------------------------------------

    IF @RestoreGroup = 0
	BEGIN
		-- Delete the group membership role nodes
		UPDATE n
			SET n.ViewSecurityGroup = 0
			FROM [RDF.].[Triple] t
				INNER JOIN [RDF.].[Node] n
					ON t.Object = n.NodeID
			WHERE Subject = @GroupNodeID AND Predicate = @contributingRoleID
		-- Delete the group node
		UPDATE [RDF.].[Node]
			SET ViewSecurityGroup = 0
			WHERE NodeID = @GroupNodeID
		-- Delete the group
		UPDATE [Profile.Data].[Group.General]
			SET ViewSecurityGroup = 0
			WHERE GroupID = @GroupID
		-- Remove access rights
		EXEC [Profile.Data].[Group.UpdateSecurityMembership]
	END

	-------------------------------------------------
	-- Restore a group, making it private
	-------------------------------------------------

    IF @RestoreGroup = 1
	BEGIN
		-- Restore the group
		UPDATE [Profile.Data].[Group.General]
			SET ViewSecurityGroup = @GroupNodeID
			WHERE GroupID = @GroupID
		-- Restore the group node
		UPDATE [RDF.].[Node]
			SET ViewSecurityGroup = @GroupNodeID
			WHERE NodeID = @GroupNodeID
		-- Restore the group membership role nodes (where IsActive=1)
		UPDATE n
			SET n.ViewSecurityGroup = @GroupNodeID
			FROM [RDF.].[Triple] t
				INNER JOIN [RDF.].[Node] n
					ON t.Object = n.NodeID
			WHERE Subject = @GroupNodeID AND Predicate = @contributingRoleID
				AND n.NodeID IN (
					SELECT m.NodeID
					FROM [Profile.Data].[Group.Member] g
						INNER JOIN [RDF.Stage].InternalNodeMap m
							ON m.Class = 'http://vivoweb.org/ontology/core#MemberRole' AND m.InternalType = 'MemberRole' AND m.InternalID = g.MemberRoleID
					WHERE g.GroupID = @GroupID AND g.IsActive = 1
				)
		-- Restore access rights
		EXEC [Profile.Data].[Group.UpdateSecurityMembership]
	END

END
GO
PRINT N'Creating [Profile.Data].[Group.Manager.AddManager]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.Manager.AddManager]
	-- Group
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL,
	-- User
	@UserID INT=NULL,
	@UserNodeID BIGINT=NULL,
	@UserURI VARCHAR(400)=NULL,
	-- Other
	@SessionID UNIQUEIDENTIFIER=NULL, 
	@Error BIT=NULL OUTPUT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	
	This stored procedure adds a Group Manager.
	Specify:
	1) A Group by either GroupID, NodeID or URI.
	2) A User by UserID, NodeID, or URI.
	
	*/
	
	SELECT @Error = 0

	-------------------------------------------------
	-- Validate and prepare variables
	-------------------------------------------------
	
	-- Convert URIs and NodeIDs to GroupID
 	IF (@GroupNodeID IS NULL) AND (@GroupURI IS NOT NULL)
		SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 	IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
		SELECT @GroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID
	IF @GroupNodeID IS NULL
		SELECT @GroupNodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://xmlns.com/foaf/0.1/Group' AND InternalType = 'Group' AND InternalID = @GroupID

	-- Convert URIs and NodeIDs to UserID
 	IF (@UserNodeID IS NULL) AND (@UserURI IS NOT NULL)
		SELECT @UserNodeID = [RDF.].fnURI2NodeID(@UserURI)
 	IF (@UserID IS NULL) AND (@UserNodeID IS NOT NULL)
		SELECT @UserID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @UserNodeID
	IF @UserNodeID IS NULL
		SELECT @UserNodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User' AND InternalType = 'User' AND InternalID = @UserID

	-- Check that both a Group and a User exist
	IF (@GroupID IS NULL) OR (@UserID IS NULL) OR (@GroupNodeID IS NULL) OR (@UserNodeID IS NULL)
		RETURN;

	-------------------------------------------------
	-- Add the manager
	-------------------------------------------------

	INSERT INTO [Profile.Data].[Group.Manager] (GroupID, UserID)
		SELECT @GroupID, @UserID
		WHERE NOT EXISTS (SELECT * FROM [Profile.Data].[Group.Manager] WHERE GroupID=@GroupID AND UserID=@UserID)

	EXEC [RDF.].GetStoreTriple	@SubjectID = @GroupNodeID,
								@PredicateURI = 'http://profiles.catalyst.harvard.edu/ontology/prns#hasGroupManager',
								@ObjectID = @UserNodeID,
								@ViewSecurityGroup = -1,
								@Weight = 1,
								@SessionID = @SessionID,
								@Error = @Error OUTPUT

	EXEC [Profile.Data].[Group.UpdateSecurityMembership]

END
GO
PRINT N'Creating [Profile.Data].[Group.Manager.DeleteManager]...';


GO
CREATE PROCEDURE [Profile.Data].[Group.Manager.DeleteManager]
	-- Group
	@GroupID INT=NULL, 
	@GroupNodeID BIGINT=NULL,
	@GroupURI VARCHAR(400)=NULL,
	-- User
	@UserID INT=NULL,
	@UserNodeID BIGINT=NULL,
	@UserURI VARCHAR(400)=NULL,
	-- Other
	@SessionID UNIQUEIDENTIFIER=NULL, 
	@Error BIT=NULL OUTPUT 
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

	/*
	
	This stored procedure deletes a Group Manager.
	Specify:
	1) A Group by either GroupID, NodeID or URI.
	2) A User by UserID, NodeID, or URI.
	
	*/
	
	SELECT @Error = 0

	-------------------------------------------------
	-- Validate and prepare variables
	-------------------------------------------------
	
	-- Convert URIs and NodeIDs to GroupID
 	IF (@GroupNodeID IS NULL) AND (@GroupURI IS NOT NULL)
		SELECT @GroupNodeID = [RDF.].fnURI2NodeID(@GroupURI)
 	IF (@GroupID IS NULL) AND (@GroupNodeID IS NOT NULL)
		SELECT @GroupID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @GroupNodeID
	IF @GroupNodeID IS NULL
		SELECT @GroupNodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://xmlns.com/foaf/0.1/Group' AND InternalType = 'Group' AND InternalID = @GroupID

	-- Convert URIs and NodeIDs to UserID
 	IF (@UserNodeID IS NULL) AND (@UserURI IS NOT NULL)
		SELECT @UserNodeID = [RDF.].fnURI2NodeID(@UserURI)
 	IF (@UserID IS NULL) AND (@UserNodeID IS NOT NULL)
		SELECT @UserID = CAST(m.InternalID AS INT)
			FROM [RDF.Stage].[InternalNodeMap] m, [RDF.].Node n
			WHERE m.Status = 3 AND m.ValueHash = n.ValueHash AND n.NodeID = @UserNodeID
	IF @UserNodeID IS NULL
		SELECT @UserNodeID = NodeID
			FROM [RDF.Stage].InternalNodeMap
			WHERE Class = 'http://profiles.catalyst.harvard.edu/ontology/prns#User' AND InternalType = 'User' AND InternalID = @UserID

	-- Check that both a GroupID and a UserID exist
	IF (@GroupID IS NULL) OR (@UserID IS NULL)
		RETURN;

	-------------------------------------------------
	-- Delete the manager
	-------------------------------------------------

	DELETE
		FROM [Profile.Data].[Group.Manager]
		WHERE GroupID=@GroupID AND UserID=@UserID

	DECLARE @hasGroupManagerNodeID BIGINT
	SELECT @hasGroupManagerNodeID = [RDF.].fnURI2NodeID('http://www.w3.org/1999/02/22-rdf-syntax-ns#type')

	IF (@GroupNodeID IS NOT NULL) AND (@UserNodeID IS NOT NULL)
		DELETE
			FROM [RDF.].[Triple]
			WHERE Subject = @GroupNodeID AND Predicate = @hasGroupManagerNodeID AND Object = @UserNodeID

	EXEC [Profile.Data].[Group.UpdateSecurityMembership]

END
GO
PRINT N'Refreshing [Ontology.].[AddProperty]...';


GO
EXECUTE sp_refreshsqlmodule N'[Ontology.].[AddProperty]';


GO
PRINT N'Refreshing [Ontology.].[CleanUp]...';


GO
EXECUTE sp_refreshsqlmodule N'[Ontology.].[CleanUp]';


GO
PRINT N'Refreshing [ORNG.].[AddAppToOntology]...';


GO
EXECUTE sp_refreshsqlmodule N'[ORNG.].[AddAppToOntology]';


GO
PRINT N'Refreshing [Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Data].[Publication.Pubmed.LoadDisambiguationResults]';


GO
PRINT N'Refreshing [Profile.Import].[Beta.LoadData]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Import].[Beta.LoadData]';


GO
PRINT N'Refreshing [ORCID.].[AuthorInAuthorshipForORCID.GetList]...';


GO
EXECUTE sp_refreshsqlmodule N'[ORCID.].[AuthorInAuthorshipForORCID.GetList]';


GO
PRINT N'Refreshing [Profile.Module].[CustomViewAuthorInAuthorship.GetList]...';


GO
EXECUTE sp_refreshsqlmodule N'[Profile.Module].[CustomViewAuthorInAuthorship.GetList]';


GO
PRINT N'Refreshing [Search.].[LookupNodes]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.].[LookupNodes]';


GO
PRINT N'Refreshing [Search.].[GetNodes]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.].[GetNodes]';


GO
PRINT N'Refreshing [Search.Cache].[Public.GetConnection]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.Cache].[Public.GetConnection]';


GO
PRINT N'Refreshing [Search.Cache].[Private.GetConnection]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.Cache].[Private.GetConnection]';


GO
PRINT N'Refreshing [Search.].[GetConnection]...';


GO
EXECUTE sp_refreshsqlmodule N'[Search.].[GetConnection]';


GO
PRINT N'Update complete.';


GO
