select distinct table2.id_contract_inst, sum(n_cost_period) from fw_services_cost table2
inner join fw_contracts on fw_contracts.ID_CONTRACT_INST=table2.ID_CONTRACT_INST
inner join fw_departments on fw_departments.id_department = fw_contracts.id_department
inner join  (select  sum(n_cost_period)/count(distinct fw_contracts.id_contract_inst) average,fw_departments.id_department  from fw_services_cost table1
inner join  fw_contracts on table1.ID_CONTRACT_INST = fw_contracts.ID_CONTRACT_INST
inner join fw_departments on fw_departments.id_department = fw_contracts.ID_DEPARTMENT
where  table1.DT_STOP >= current_timestamp and table1.DT_START<= current_timestamp
group by fw_departments.id_department
) table3 on table3.id_department= table2.Id_department
where table1.DT_STOP >= current_timestamp and table1.DT_START <= current_timestamp and V_STATUS = 'A' and 
fw_contracts.DT_STOP >= current_timestamp and fw_contracts.DT_START <= current_timestamp 
group by table2.id_contract_inst;



select sum(n_cost_period)/count(distinct fw_contracts.id_contract_inst) average,fw_departments.id_department from fw_services_cost
inner join  fw_contracts on fw_services_cost.ID_CONTRACT_INST = fw_contracts.ID_CONTRACT_INST
inner join fw_departments on fw_departments.id_department = fw_contracts.ID_DEPARTMENT
where  fw_services_cost.DT_STOP >= current_timestamp and fw_services_cost.DT_START<= current_timestamp
group by fw_departments.id_department;

select ID_DEPARTMENT, sum(n_cost_period) from fw_contracts
inner join fw_services on fw_services.ID_contract_inst = fw_contracts.id_contract_inst
inner join fw_contracts on fw_contracts.ID_CONTRACT_INST=fw_services_cost.ID_CONTRACT_INST;
