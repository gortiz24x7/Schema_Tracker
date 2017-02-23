use logd1_loginprofiles
GO
CREATE TABLE dbo.application_function  ( 
	app_id            	int NOT NULL,
	function_cd       	varchar(30) NOT NULL,
	audit_insert_date 	datetime NULL,
	audit_insert_login	char(30) NULL,
	audit_update_date 	datetime NULL,
	audit_update_login	char(30) NULL,
	function_id       	int NULL,
	CONSTRAINT application_function_pk PRIMARY KEY NONCLUSTERED(app_id,function_cd)	
	)
GO
ALTER TABLE dbo.application_function
	ADD CONSTRAINT application_function_fk2
	FOREIGN KEY(app_id)
	REFERENCES dbo.application(app_id)
GO
ALTER TABLE dbo.application_function
	ADD CONSTRAINT applicatio_function_fk1
	FOREIGN KEY(function_cd)
	REFERENCES dbo.function(function_cd)
GO
sp_bindefault 'cur_dt_d', 'dbo.application_function.audit_insert_date'
GO
sp_bindefault 'login_d', 'dbo.application_function.audit_insert_login'
GO
CREATE NONCLUSTERED INDEX application_function_cd
	ON dbo.application_function(function_cd)	
GO
CREATE UNIQUE NONCLUSTERED INDEX application_function_i02
	ON dbo.application_function(app_id, function_id)	
GO
CREATE NONCLUSTERED INDEX application_function_i01
	ON dbo.application_function(function_id)	
GO
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON dbo.application_function TO datafix
GO
GRANT SELECT ON dbo.application_function TO read_only
GO
GRANT SELECT, INSERT, UPDATE, DELETE, REFERENCES ON dbo.application_function TO security_application_role
GO
GRANT SELECT ON dbo.application_function TO spin_read_role
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON dbo.application_function TO spin_super_role
GO

