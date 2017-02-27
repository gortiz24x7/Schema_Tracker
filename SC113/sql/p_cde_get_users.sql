-- 2070227 TEST JENKINS 00
USE spin_north_america
go

IF OBJECT_ID('p_cde_get_users') IS NOT NULL
BEGIN
	DROP PROCEDURE p_cde_get_users

	IF OBJECT_ID('p_cde_get_users') IS NOT NULL
	BEGIN
		PRINT '<<< FAILED DROPPING PROCEDURE p_cde_get_users >>>'
	END
	ELSE
	BEGIN
	        PRINT '<<< DROPPED PROCEDURE p_cde_get_users >>>'
	END
END
go
USE spin_north_america
go

IF OBJECT_ID('p_cde_get_users') IS NOT NULL
BEGIN
	DROP PROCEDURE p_cde_get_users

	IF OBJECT_ID('p_cde_get_users') IS NOT NULL
	BEGIN
		PRINT '<<< FAILED DROPPING PROCEDURE p_cde_get_users >>>'
	END
	ELSE
	BEGIN
	        PRINT '<<< DROPPED PROCEDURE p_cde_get_users >>>'
	END
END
go

CREATE PROCEDURE p_cde_get_users

	@app_nm varchar(30) = 'Telematics'	-- (in/opt) Application name
AS
/*******************************************************************
** Element                                     
** Project Name     : Core Data Extract (CDE)
** 
** Stored Procedure : p_cde_get_users
** 
** Creation Date    : 04/06/2016
** Author           : Joel Friedman
**
** Return Status    : 0       - Success
**                    >19,999 - User-defined error
**                    <0      - Sybase error
**
** Description      : Pull a list of Interactive users and decorate the rows with
**                    additional information.
**
** Comments         : All of the results are limited by inclusion in the
**                    "PHH Interactive" application list (per application_function).
**
**                    The parent function codes, aka profiles, are stored in a work
**                    table: core_data_user_profiles, just add rows to this table
**                    to pull additional profiles. Currently the list is:
**                    
**                       INSERT core_data_user_profiles VALUES ('TELEMATICS_MOBI') 
**                       INSERT core_data_user_profiles VALUES ('TELEMATICS_NWF')
**					  Values updated as per Kim and SA's requirements: 1/23/2017
**						TELEMATICS_MOBI_PRIME
**						TELEMATICS_MOBI_INT_OPS_CONTEN
**						TELEMATICS_MOBI_INT_OPS_DEFAUL
**						TELEMATICS_NWF_TELEMONITOR
**						TELEMATICS_NWF_TELEMONITORADMI
**						TELEMATICS_NWF_TELEMONITORPOI
**						TELEMATICS_NWF_TELEMONITORVCL
**
** Revision(s)      : [10/06/2016:J.Friedman] Removed the password
**                    population. Added parent_function_cd to the core_date_users
**                    data population.
**
**                    [10/06/2016:J.Friedman] Pull bkdn from person table
** 					: [01/25/2017:J.G.Padilla Adjusting Logic based on function_ancestors  logic 
*******************************************************************/

-- Clear the table

SET ROWCOUNT 5000

DELETE trnd1_spin_work..core_data_users

WHILE @@rowcount = 5000
BEGIN
	DELETE trnd1_spin_work..core_data_users
END

SET ROWCOUNT 0

-- Pull in the login information from the user_function table

INSERT	trnd1_spin_work..core_data_users
(
		login,
		function_cd,
		program_cd,
		last_nm,
		first_nm,
		mid_init,
		spin_org_id,
		corp_cd,
		cli_no,
		cli_nm,
		full_bkdn,
		full_bkdn_nm,
		bkdn_delim,
		rev_bkdn
)
SELECT uf.login, 
        fa.function_cd ,
        uf.function_cd ,
        lp.lst_nm,
		lp.frst_nm,
		ISNULL(RTRIM(lp.mi), ' ') ,	-- mid_init
        c.spin_org_id,
        pla.corp_cd,
		pla.cli_no,
		c.cli_nm,
		pla.bkdn,
		c.cli_nm ,	 				-- full_bkdn_nm (default)
        cbs.bkdn_mask_delim,        
		REVERSE(pla.bkdn) as rev_bkdn	-- rev_bkdn
FROM logd1_loginprofiles..user_function uf
JOIN logd1_loginprofiles..function_ancestors fa    
      ON fa.parent_function_cd = uf.function_cd

JOIN trnd1_spin_work..core_data_user_profiles cdup
    ON	cdup.parent_function_cd = fa.parent_function_cd

JOIN logd1_loginprofiles..application_function af
    ON af.function_cd = fa.function_cd

JOIN logd1_loginprofiles..application a
    ON a.app_id = af.app_id        
JOIN	logd1_loginprofiles..login_profile lp
	ON	lp.login =uf.login         
JOIN	logd1_loginprofiles..login_pswrd_status lps
	ON	lps.login = lp.login
JOIN	logd1_loginprofiles..phh_login_access pla
	ON	lp.login = pla.login 
JOIN spin_north_america..cli_no_xref cnx
    ON cnx.corp_cd = pla.corp_cd
        AND cnx.cli_no = pla.cli_no
        AND cnx.cli_del_from_src_ind = 'N'
JOIN	spin_north_america..client c
	ON	c.SPIN_org_id = cnx.SPIN_org_id    
JOIN spin_north_america..client_breakdown_structure cbs
    ON  cbs.SPIN_org_id = c.SPIN_org_id   
        AND cbs.corp_cd = c.corp_cd
        AND cbs.cli_no = c.cli_no
        AND cbs.bkdn_typ_cd = 'BLG'
        AND cbs.cli_del_from_src_ind = 'N'
WHERE  a.app_nm = @app_nm --'Telematics'--= 'Profiles'
  AND  cnx.cli_del_from_src_ind = 'N'
  AND lps.disable_ind = 0
  
-- Decorate the rows with available person data

UPDATE trnd1_spin_work..core_data_users
  SET	spin_psn_id = p.spin_psn_id,
		last_nm     = ISNULL(RTRIM(p.last_nm), u.last_nm),
		first_nm    = ISNULL(RTRIM(p.first_nm), u.first_nm),
		mid_init    = ISNULL(LEFT(p.mid_nm, 1), u.mid_init),
		mid_nm      = ISNULL(RTRIM(p.mid_nm), u.mid_nm),
		nick_nm     = ISNULL(RTRIM(p.nick_nm), u.nick_nm),
		nm_prefix   = ISNULL(RTRIM(p.nm_prefix), u.nm_prefix),
		nm_suffix   = ISNULL(RTRIM(p.nm_suffix), u.nm_suffix),
		full_bkdn   = ISNULL(RTRIM(p.bkdn), u.full_bkdn)
FROM	trnd1_spin_work..core_data_users u
JOIN	spin_north_america..person_profile pp
 	ON	pp.login = u.login 
JOIN	spin_north_america..person p
	ON	p.spin_psn_id = pp.SPIN_psn_id

-- Decorate the rows with available person communication data

UPDATE trnd1_spin_work..core_data_users
  SET	comm_val = RTRIM(pc.comm_val)
FROM	trnd1_spin_work..core_data_users u
JOIN	spin_north_america..person_communication pc
	ON	pc.spin_psn_id = u.SPIN_psn_id
	AND	pc.comm_typ_cd = u.comm_typ_cd
WHERE	RTRIM(pc.comm_val) IS NOT NULL

-- Decorate the rows with available login email xref value, if there is no address yet

UPDATE trnd1_spin_work..core_data_users
  SET	comm_val = RTRIM(lex.email_address)
FROM	trnd1_spin_work..core_data_users u
  JOIN	spin_north_america..login_email_xref lex
	ON	u.login = lex.loginname
WHERE	comm_val IS NULL

-- Decorate the rows with the full breakdown name

UPDATE trnd1_spin_work..core_data_users
  SET	full_bkdn_nm = ISNULL(RTRIM(cb.bkdn_nm), u.full_bkdn_nm)
FROM	trnd1_spin_work..core_data_users u
JOIN	spin_north_america..client_breakdown cb
	ON	cb.spin_org_id   = u.spin_org_id
	AND	cb.bkdn          = u.full_bkdn
WHERE	cb.bkdn_stat_ind = 'A'

-- Decorate the rows with the leaf-level breakdown

UPDATE trnd1_spin_work..core_data_users
  SET	low_lvl_bkdn = 
			CASE CHARINDEX(bkdn_delim, rev_bkdn)
				WHEN 0 THEN full_bkdn
				ELSE REVERSE(LEFT(rev_bkdn, CHARINDEX(bkdn_delim, rev_bkdn)-1))	-- Grab everything after the last bkdn delimiter
			END
-- Done

RETURN 0
go

IF OBJECT_ID('p_cde_get_users') IS NOT NULL
BEGIN
    PRINT '<<< CREATED PROCEDURE p_cde_get_users >>>'

	EXEC sp_procxmode 'p_cde_get_users','anymode'
    GRANT EXECUTE ON dbo.p_cde_get_users TO security_reference_role
	GRANT EXECUTE ON dbo.p_cde_get_users TO cash_app_load_role
END
ELSE
BEGIN
    PRINT '<<< FAILED CREATING PROCEDURE p_cde_get_users >>>'
END
go
