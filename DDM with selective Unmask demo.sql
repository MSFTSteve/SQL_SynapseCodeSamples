SELECT c.name, tbl.name as table_name, c.is_masked, c.masking_function  
FROM sys.masked_columns AS c  
JOIN sys.tables AS tbl   
    ON c.[object_id] = tbl.[object_id]  
WHERE is_masked = 1;  



--Clean up masking
ALTER TABLE cso.DimCustomer  
ALTER COLUMN BirthDate DROP MASKED;  

ALTER TABLE cso.DimCustomer  
ALTER COLUMN EmailAddress DROP MASKED;  


--Add data masking to the DimCustomer Table

ALTER TABLE cso.DimCustomer ALTER COLUMN BirthDate ADD MASKED WITH (FUNCTION = 'default()');

ALTER TABLE cso.DimCustomer ALTER COLUMN EmailAddress ADD MASKED WITH (FUNCTION = 'Email()');

  
  -- impersonate for testing:
EXECUTE AS USER = 'TestUser';  

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer  

REVERT;  

--Show issues with UNMASK

GRANT UNMASK TO TestUser;

EXECUTE AS USER = 'TestUser';  

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 
SELECT Top 10 EmployeeKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimEmployee;

REVERT;


--Show granular unmasking at column, table and schema level

GRANT UNMASK ON cso.DimCustomer(EmailAddress) TO MarketingUser;
GRANT UNMASK ON cso.DimCustomer TO HRManager;
GRANT UNMASK ON SCHEMA::cso TO schemaowner;



--Test MakretingUser

EXECUTE AS USER = 'MarketingUser';  

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 

REVERT;

--Test HRManager

EXECUTE AS USER = 'HRManager';  

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 

REVERT;



--TEST schemaowner


EXECUTE AS USER = 'schemaowner';  

SELECT Top 10 CustomerKey, FirstName, LastName, BirthDate, EmailAddress FROM cso.DimCustomer; 

REVERT;

--REMOVE unmask permissions

REVOKE UNMASK ON cso.DimCustomer(EmailAddress) TO MarketingUser;