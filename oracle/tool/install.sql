-- SYS user scripts for tool schema
@ 00-tool-table-space-sys.sql;
@ 01-tool-user-create-sys.sql;
@ 02-inital-grants-tool-sys.sql;
@ 03-dbms_sesion-grants-tool-sys.sql;

-- tool user
-- tables
@ tables/apex_app_monitor.sql;
@ tables/apex_comp_maping.sql;
@ tables/ddl_log.sql;
@ tables/config.sql;
@ tables/os_users_mapping.sql;
@ tables/log.sql;

-- sequences
@ sequences/seq_id.sql;

-- scripts
@ scripts/00.apex_comp_maping.sql;
@ scripts/01.context_tool.sql;
@ scripts/02.al_ddl_log_apx.sql;
@ scripts/03.al_apex_comp_maping_add_col.sql;
@ scripts/04.upd_apex_col_name.sql;
@ scripts/05.upd_apex_comp_map_brea_entry_menu.sql;
@ scripts/06.ins_version_control_structure.sql;
@ scripts/07.constraint_apex_comp_map_vc.sql;
@ scripts/08.al_ddl_log_db_obj_type.sql;
@ scripts/09.upd_code_to_upper_case_vcs.sql;
@ scripts/10.ins_config_root_dir.sql;
@ scripts/11.del_vcse_ax_root_fld_shema.sql;
@ scripts/12.upd_code_vcse.sql;
@ scripts/13.del_code_vcse_job_seq.sql;
@ scripts/14.at_vcse_add_col_file_ext.sql;
@ scripts/15.upd_vcse_pck_file_ext.sql;
@ scripts/16.al_ddl_log_pkey.sql;
@ scripts/17.update_comp_type_b_entry.sql;
@ scripts/18.al_ddl_log_revhash.sql;
@ scripts/19.config_cl_file_location.sql;
@ scripts/20.ins_apex_auth_setup.sql;
@ scripts/21.al_acmp_exp_apex_cmp.sql
@ scripts/22.total_import.sql;

-- views
@ views/v_user_ddl_log.sql;


-- packages
@ packages/p$utl_context.pks;
@ packages/p$utl_context.pkb;

@ packages/p$apx_utl.pks;
@ packages/p$apx_utl.pkb;

@ packages/p$ver_ctrl.pks;
@ packages/p$ver_ctrl.pkb;

-- standalone program units
@ procedures/p_log.sql;

-- triggers
@ triggers/ddl_apex.sql;
@ triggers/ddl_trigger_playground.sql;

