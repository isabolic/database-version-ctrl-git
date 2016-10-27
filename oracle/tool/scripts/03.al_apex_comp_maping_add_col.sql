alter table apex_comp_maping add (apex_col_name varchar2(200));
/
comment on column apex_comp_maping.apex_col_name is 'Naziv kolone apex ref. tablice u kojoj je pohranjen naziv objekta';
/