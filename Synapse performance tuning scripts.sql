--Using to gain information on all running queries

SELECT *
FROM sys.dm_pdw_exec_requests
WHERE status not in ('Completed','Failed','Cancelled')
  AND session_id <> session_id()
ORDER BY submit_time DESC;


--Finding longest running queries

SELECT TOP 10 *
FROM sys.dm_pdw_exec_requests
ORDER BY total_elapsed_time DESC;

--View query execution plann

SELECT * FROM sys.dm_pdw_request_steps 
WHERE request_id = 'QID####' ORDER BY step_index;


