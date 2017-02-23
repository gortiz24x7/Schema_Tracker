USE spin_north_america
GO

IF OBJECT_ID('asset_core_enroll') IS NOT NULL
BEGIN
	DROP VIEW asset_core_enroll

	IF OBJECT_ID('asset_core_enroll') IS NOT NULL
	BEGIN
		PRINT '<<< FAILED DROPPING PROCEDURE asset_core_enroll >>>'
	END
	ELSE
	BEGIN
	        PRINT '<<< DROPPED PROCEDURE asset_core_enroll >>>'
	END
END
go

CREATE VIEW dbo.asset_core_enroll
as (
SELECT          dx.SPIN_asset_id, 
                afe.dan, 
                afe.SPIN_org_id,
                cnx.corp_cd, 
                cnx.cli_no AS Client_No,                 
                ape.pgm_cd, 
                c.contract_nm,
                c.contract_sta_cd, 
                c.contract_no, 
                ape.eff_dt AS pgm_eff_dt, 
                ape.exp_dt AS pgm_exp_dt,
                afe.fee_cd,                 
                afe.fee_eff_dt , 
                afe.exp_dt AS fee_exp_dt,
                afe.contract_id, 
				0 AS spin_psn_id
FROM spin_north_america_i2..asset_pgm_enroll_hist ape    
JOIN spin_north_america_i2.dbo.asset_fee_enroll_hist afe
    ON ape.SPIN_org_id = afe.SPIN_org_id
        AND ape.enroll_asset_id = afe.enroll_asset_id
        AND ape.pgm_cd = afe.pgm_cd
        AND ape.SPIN_org_id = afe.SPIN_org_id
JOIN spin_north_america_i2..contract c
    ON ape.contract_id = c.contract_id
        AND ape.SPIN_org_id = c.SPIN_org_id
        AND ape.pgm_cd = c.pgm_cd
JOIN spin_north_america_i2..cli_no_xref cnx
    ON ape.SPIN_org_id = cnx.SPIN_org_id
        AND ape.corp_cd = cnx.corp_cd        
JOIN cord1_asset_cur.dbo.dan_xref dx
    ON dx.corp_cd = afe.corp_cd
        AND dx.dan = afe.dan        
        AND dx.ast_del_from_src_ind = 'N'
WHERE ape.record_expired_ind = 'N'
  AND cnx.cli_del_from_src_ind = 'N'
  and ape.pgm_cd in ('TV','TG','TE','TZ','TF','TQ','T0',
	'AB','DB','SC', 'MB',
	'T9','VL')	  
UNION
SELECT DISTINCT  --0 AS enroll_ast_id,
        0 AS SPIN_asset_id,
        '0000' AS dan,
        p.SPIN_org_id,
        p.corp_cd,
        p.cli_no AS Client_No,
        pgm_cd,
        ' ' AS contract_nm,
        'A' AS contract_sta_cd, 
        --ch.contract_agrmnt_sta_cd, 
        ch.contract_no,
        ch.current_cont_dt as pgm_eff_dt,
        --ch.add_dt AS pgm_eff_dt,        
        CAST(NULL AS DATETIME) AS pgm_exp_dt,
        LTRIM(RTRIM(CAST(pd.psn_data_cd AS CHAR)))|| '-'|| ch.pgm_cd || '-' || cast(coalesce (pd.numeric_val,0) as char) AS fee_cd,        
            case pd.SPIN_audit_insert_dt when NULL then p.SPIN_audit_insert_dt ELSE  pd.SPIN_audit_insert_dt END AS fee_eff_dt,
        CAST(NULL AS date) AS fee_exp_dt,
        0 AS contract_id, 
	    p.spin_psn_id
FROM spin_north_america_i2..person p
 JOIN spin_north_america_i2..person_data pd
    ON p.spin_psn_id = pd.spin_psn_id
        and pd.psn_data_cd in (85,116)
        --and pd.numeric_val = 1
 JOIN spin_north_america_i2..contract  ch
    ON ch.SPIN_org_id = p.SPIN_org_id        
WHERE p.psn_del_from_src_ind = 'N'
  and ch.pgm_cd in  ('MB', 'SC','DB') 
union
SELECT distinct  
        0 AS SPIN_asset_id,
        '0000' AS dan,
        p.SPIN_org_id,
        p.corp_cd,
        p.cli_no AS Client_No,
        ccb.contract_typ_cd AS pgm_cd,
        ' ' AS contract_nm,
        'A' AS contract_sta_cd,         
        ccb.cont_no AS contract_no,
        p.spin_audit_insert_dt AS pgm_eff_dt,
        CAST(NULL AS DATETIME) AS pgm_exp_dt,
        ltrim(rtrim(CAST(pd.psn_data_cd AS CHAR)))|| '-'|| ccb.contract_typ_cd || '-' || cast(coalesce (pd.numeric_val,0) as char) AS fee_cd,        
            CASE pd.SPIN_audit_insert_dt WHEN NULL THEN p.SPIN_audit_insert_dt ELSE  pd.SPIN_audit_insert_dt END AS fee_eff_dt,
        CAST(NULL AS date) AS fee_exp_dt,
        0 AS contract_id,
		p.spin_psn_id
FROM spin_north_america_i2..person p
 JOIN spin_north_america_i2..person_data pd
    ON p.spin_psn_id = pd.spin_psn_id
        and pd.psn_data_cd in (85,116)
        --and pd.numeric_val = 1
 JOIN spin_north_america..contract_client_breakdown ccb
    ON p.SPIN_org_id = ccb.SPIN_org_id
        and p.cli_no = ccb.cli_no
        and p.bkdn = ccb.bkdn         
WHERE p.corp_cd = 'FA'
AND  ccb.contract_typ_cd  in ('MB', 'SC','DB')    
)

GO
GRANT SELECT ON dbo.asset_core_enroll TO cash_app_load_role
GO
GRANT SELECT On dbo.asset_core_enroll TO spin_read_role
GO
GRANT SELECT ON dbo.asset_core_enroll TO spin_super_role
GO


