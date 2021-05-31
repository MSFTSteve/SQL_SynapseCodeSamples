SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
FROM sys.masked_columns AS c  
JOIN sys.tables AS tbl   
    ON c.[object_id] = tbl.[object_id]  
WHERE is_masked = 1;  


--CREATE USERS

CREATE USER testuser WITHOUT LOGIN;
CREATE USER HRManager WITHOUT LOGIN;
CREATE USER MarketingUser WITHOUT LOGIN;
CREATE USER schemaOwner WITHOUT LOGIN;

--Assing Read Permissions

GRANT SELECT ON cso.DimCustomer TO TestUser;
GRANT SELECT ON cso.DimCustomer TO HRManager;
GRANT SELECT ON cso.DimCustomer TO MarketingUser;
GRANT SELECT ON cso.DimCustomer TO schemaOwner;
GRANT SELECT ON cso.DimEmployee TO TestUser;
GRANT SELECT ON cso.DimEmployee TO HRManager;
GRANT SELECT ON cso.DimEmployee TO MarketingUser;
GRANT SELECT ON cso.DimEmployee TO schemaOwner;

--Add data masking to the DimCustomer Table

ALTER TABLE cso.DimCustomer ALTER COLUMN BirthDate ADD MASKED WITH (FUNCTION = 'default()');

ALTER TABLE cso.DimCustomer ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'Email()');

  
  -- impersonate for testing:
EXECUTE AS USER = 'TestUser';  

SELECT USER_NAME();

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer  

REVERT;  

--Show issues with UNMASK

GRANT UNMASK TO TestUser

EXECUTE AS USER = 'TestUser';  

SELECT USER_NAME();

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 
SELECT Top 10 EmployeeKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimEmployee;

REVERT;

--Show granular unmasking at column, table and schema level

--Grant Unmask at the column level

GRANT UNMASK ON cso.DimCustomer(EmailAddress) TO MarketingUser;


--Test MakretingUser

EXECUTE AS USER = 'MarketingUser';  

SELECT user_name();

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 

REVERT;

--Set unmask at the table level

GRANT UNMASK ON cso.DimCustomer TO HRManager;

--Test HRManager

EXECUTE AS USER = 'HRManager';  

SELECT user_name();
SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 
SELECT Top 10 EmployeeKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimEmployee;

REVERT;

--set unmask at the schema level

GRANT UNMASK ON SCHEMA::cso TO schemaowner;

--TEST schemaowner


EXECUTE AS USER = 'schemaowner';  

SELECT user_name();
SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 
SELECT Top 10 EmployeeKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimEmployee;

REVERT;

--Demo View Effect


REVOKE UNMASK FROM TestUser;

--CREATE VIEW on masked table

GO;

CREATE VIEW cso.testview
AS
SELECT TOP 5 CustomerKey, FirstName, LastName, BirthDate, EmailAddress, substring(emailAddress, 1, 5) AS substTest FROM cso.DimCustomer;


GO;

GRANT SELECT ON cso.testview TO TestUser;


EXECUTE AS USER = 'TestUser';  

SELECT USER_NAME();

SELECT * FROM cso.testview;

REVERT;  

GRANT UNMASK ON cso.DimCustomer(EmailAddress) TO TestUser;


--****CLEANUP*********
--REMOVE unmask permissions

REVOKE UNMASK FROM TestUser
REVOKE UNMASK ON cso.DimCustomer(EmailAddress) TO MarketingUser;
REVOKE UNMASK ON cso.DimCustomer FROM HRManager;
REVOKE UNMASK ON SCHEMA::cso FROM schemaowner;

--Clean up masking
ALTER TABLE cso.DimCustomer  
ALTER COLUMN BirthDate DROP MASKED;  

ALTER TABLE cso.DimCustomer  
ALTER COLUMN EmailAddress DROP MASKED;  



--Cleanup Users
DROP USER testuser; 
DROP USER HRManager; 
DROP USER MarketingUser; 
DROP USER schemaOwner; 

--remove view
DROP VIEW cso.testview;