-- Added TEST Row
USE trnd1_spin_work
GO
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TELEMATICS_NWF_TELEMONITOR')
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TELEMATICS_NWF_TELEMONITORADMI')
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TELEMATICS_NWF_TELEMONITORPOI')
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TELEMATICS_NWF_TELEMONITORVCL')
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TELEMATICS_MOBI_PRIME')
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TELEMATICS_MOBI_INT_OPS_CONTEN')
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TELEMATICS_MOBI_INT_OPS_DEFAUL')
INSERT INTO trnd1_spin_work..core_data_user_profiles
VALUES ('TEST')
GO
grant select  on dbo.core_data_user_profiles to spin_read_role
GO
