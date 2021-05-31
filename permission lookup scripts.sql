select suser_sname()


CREATE USER managergroup@microsoft.com FROM EXTERNAL PROVIDER

CREATE LOGIN sqltest
WITH PASSWORD = 'P@ssw0rd'


server.db.schema.object

--see all permissions on a object


SELECT u.name, p.permission_name, p.state_desc FROM sys.database_permissions  p
JOIN sysusers u
ON p.grantee_principal_id = u.uid
    WHERE major_id = OBJECT_ID('cso.DimCustomer');  

--Return explicit granted or denied permissions
SELECT   
    perms.state_desc AS State,   
    permission_name AS [Permission],   
    obj.name AS [on Object],   
    dPrinc.name AS [to User Name]  
FROM sys.database_permissions AS perms  
JOIN sys.database_principals AS dPrinc  
    ON perms.grantee_principal_id = dPrinc.principal_id  
JOIN sys.objects AS obj  
    ON perms.major_id = obj.object_id;

--return members of Role

SELECT sRole.name AS [Server Role Name] , sPrinc.name AS [Members]  
FROM sys.server_role_members AS sRo  
JOIN sys.server_principals AS sPrinc  
    ON sRo.member_principal_id = sPrinc.principal_id  
JOIN sys.server_principals AS sRole  
    ON sRo.role_principal_id = sRole.principal_id;

--return members of database Role

SELECT dRole.name AS [Database Role Name], dPrinc.name AS [Members]  
FROM sys.database_role_members AS dRo  
JOIN sys.database_principals AS dPrinc  
    ON dRo.member_principal_id = dPrinc.principal_id  
JOIN sys.database_principals AS dRole  
    ON dRo.role_principal_id = dRole.principal_id;  

--View Permissions set at the Schema level

	SELECT state_desc
    ,permission_name
    ,class_desc
    ,SCHEMA_NAME(major_id)
    ,USER_NAME(grantee_principal_id)
FROM sys.database_permissions AS PERM
JOIN sys.database_principals AS Prin
    ON PERM.major_ID = Prin.principal_id
        AND class_desc = 'SCHEMA'
WHERE major_id = SCHEMA_ID('TestSchema')
    --AND grantee_principal_id = user_id('TestUser') --This line will not work in Azure Synapse
    --AND    permission_name = 'SELECT'




	DECLARE @SCHEMA varchar(255) = 'cso'
SELECT DISTINCT
CASE WHEN prmssn.state = 'D' then 'Deny'  WHEN prmssn.state = 'R' THEN 'REVOKE' WHEN prmssn.state = 'G' THEN 'Grant'   ELSE  ' Grant With Grant Option' end as permissionstate,
grantor_principal.name AS [Grantor],
prmssn.permission_name AS [name],
class_desc,Grantees.grantee
FROM
sys.schemas AS s
INNER JOIN sys.database_permissions AS prmssn ON prmssn.major_id=s.schema_id AND prmssn.minor_id=0 AND prmssn.class=3
INNER JOIN sys.database_principals AS grantor_principal ON grantor_principal.principal_id = prmssn.grantor_principal_id
INNER JOIN sys.database_principals AS grantee_principal ON grantee_principal.principal_id = prmssn.grantee_principal_id
INNER JOIN (SELECT
grantee_principal.name AS [Grantee]
FROM
sys.schemas AS s
INNER JOIN sys.database_permissions AS prmssn ON prmssn.major_id=s.schema_id AND prmssn.minor_id=0 AND prmssn.class=3
INNER JOIN sys.database_principals AS grantee_principal ON grantee_principal.principal_id = prmssn.grantee_principal_id
WHERE
(s.name= @SCHEMA)) as Grantees
on Grantees.grantee = grantee_principal.name
WHERE
((s.name=@SCHEMA))
