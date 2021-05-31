--Create test user

Create User perm_test1 Without login


CREATE SCHEMA fred


--Assigning Permissions

REVOKE select ON cso.DimProduct TO perm_test1




--Test Query
EXECUTE AS USER = 'perm_test1';  

SELECT  top 10 * FROM cso.DimProduct;  

REVERT;  

--Removing Permissions
REVOKE select on cso.DimProduct FROM perm_test1


--Showing impact of Deny

DENY select ON cso.DimProduct TO perm_test1

CREATE ROLE denied_user;

sp_addrolemember 'denied_user', 'perm_test1';

GRANT SELECT ON cso.DimProduct TO denied_user;


--Test Query
EXECUTE AS USER = 'perm_test1';  

SELECT TOP 10 * FROM cso.DimProduct;  

REVERT;  

--remove deny
REVOKE SELECT ON  FROM denied_user;

--Test Query
EXECUTE AS USER = 'perm_test1';  

EXEC test.helloworld
REVERT; 




CREATE SCHEMA test

CREATE PROC test.helloworld
AS
BEGIN
	Print 'Hello World'
END

REVOKE EXECUTE ON test.helloworld TO perm_test1


CREATE VIEW cso.top10prod
AS
SELECT top 10 * from cso.DimProduct

GRANT SELECT ON cso.top10prod TO perm_test1

-- Clean up
DROP USER perm_test1;
DROP ROLE denied_user;


EXECUTE AS USER = 'perm_test1';  

SELECT   * FROM cso.Top10Prod;  

REVERT;  


GRANT SELECT ON SCHEMA::cso TO perm_test1