--1
select fc.ID_CONTRACT_INST,fd.ID_DEPARTMENT,average,sum(fsc1.N_COST_PERIOD) from fw_services_cost fsc1
inner join fw_contracts fc on fsc1.ID_CONTRACT_INST=fc.ID_CONTRACT_INST
inner join fw_departments fd on fc.ID_DEPARTMENT=fd.ID_DEPARTMENT
inner join(select sum( fsc.N_COST_PERIOD)/count(distinct fsc.ID_CONTRACT_INSt) average, fd1.id_department from  fw_services_cost fsc
inner join fw_contracts fc1 on fsc.ID_CONTRACT_INST=fc1.ID_CONTRACT_INST
inner join fw_departments fd1 on fc1.ID_DEPARTMENT=fd1.ID_DEPARTMENT
where fc1.dt_start <=current_timestamp and fc1.dt_stop >=current_timestamp and V_STATUS = 'A' and fsc.dt_start <=current_timestamp and fsc.dt_stop >=current_timestamp
group by fd1.id_department) fsc2 on fsc2.id_department=fd.id_department
where fc.dt_start <=current_timestamp and fc.dt_stop >=current_timestamp and V_STATUS = 'A' and fsc1.dt_start <=current_timestamp and fsc1.dt_stop >=current_timestamp
group by fc.ID_CONTRACT_INST,fd.ID_DEPARTMENT,average
having average<sum(fsc1.N_COST_PERIOD);

--2
select fs1.V_NAME,fd.ID_DEPARTMENT,average,sum(fsc1.N_COST_PERIOD) from fw_services_cost fsc1
inner join fw_contracts fc on fsc1.ID_CONTRACT_INST=fc.ID_CONTRACT_INST
inner join fw_departments fd on fc.ID_DEPARTMENT=fd.ID_DEPARTMENT
inner join fw_services fs on fc.ID_CONTRACT_INST=fs.ID_CONTRACT_INST
inner join FW_SERVICE fs1 on fs1.id_service=fs.id_service
inner join(select sum( fsc.N_COST_PERIOD)/count(distinct fsc.ID_CONTRACT_INSt) average, fd1.id_department from  fw_services_cost fsc
inner join fw_contracts fc1 on fsc.ID_CONTRACT_INST=fc1.ID_CONTRACT_INST
inner join fw_departments fd1 on fc1.ID_DEPARTMENT=fd1.ID_DEPARTMENT
where fc1.dt_start <=current_timestamp and fc1.dt_stop >=current_timestamp and V_STATUS = 'A' and fsc.dt_start <=current_timestamp and fsc.dt_stop >=current_timestamp
group by fd1.id_department) fsc2 on fsc2.id_department=fd.id_department
where fc.dt_start <=current_timestamp and fc.dt_stop >=current_timestamp and fc.V_STATUS = 'A' and fs.V_STATUS ='A' and fsc1.dt_start <=current_timestamp and fsc1.dt_stop >=current_timestamp
group by fs1.V_NAME,fd.ID_DEPARTMENT,average
having average<sum(fsc1.N_COST_PERIOD);

--3
select fc1.id_contract_inst,n_cost_period-N_DISCOUNT_PERIOD,count(*) from fw_services_cost fsc1
inner join (select * from fw_contracts fc where fc.DT_start<='01.12.17' and fc.V_STATUS='A') fc1 on fsc1.id_contract_inst=fc1.id_contract_inst
where  fsc1.dt_stop  between '01.10.17' and '01.12.17'
group by fc1.id_contract_inst,n_cost_period-N_DISCOUNT_PERIOD
having count(*)>2;

--4 (не решена, я просто смог вывести все услуги и их стоимость за последние 6 месяцев)
select (((current_timestamp - to_char(current_timestamp,'dd'))- interval '5' month)) - to_char(((current_timestamp - to_char(current_timestamp,'dd'))- interval '5' month),'dd')-30 as date1  from dual;
select fc.id_contract_inst,fsc.DT_START,fsc.DT_STOP,n_cost_period-n_discount_period,fsc.ID_SERVICE_INST from fw_contracts fc
inner join (select * from fw_services_cost 
      where DT_Start<=current_timestamp - to_char(current_timestamp,'dd') 
      and DT_stop>=(((current_timestamp - to_char(current_timestamp,'dd'))- interval '5' month)) - to_char(((current_timestamp - to_char(current_timestamp,'dd'))- interval '5' month),'dd')-30)fsc
      on fsc.id_contract_inst=fc.id_contract_inst
where fc.dt_start <=current_timestamp and fc.dt_stop>=current_timestamp and fc.v_status='A'
order by fsc.DT_START asc; 


--5
select * from (select distinct FW_SERVICE.V_NAME,n_cost_period-N_DISCOUNT_PERIOD from fw_services_cost fsc1
inner join (select * from fw_contracts fc where fc.dt_stop >=current_timestamp and fc.DT_start<=current_timestamp and fc.V_STATUS='A') fc1 on fsc1.id_contract_inst=fc1.id_contract_inst
inner join fw_services fs on fsc1.ID_SERVICE_INST=fs.ID_SERVICE_INST
inner join FW_SERVICE  on fs.id_service=FW_SERVICE.id_service
where  fsc1.dt_start <= current_timestamp and fsc1.dt_stop >=current_timestamp
order by n_cost_period-N_DISCOUNT_PERIOD DESC)
where rownum<=5;




--6
select v_name,id_tariff_plan,sum(n_cost_period-n_discount_period) summary  from (select * from fw_departments fd
inner join (select * from fw_contracts fc1 where fc1.dt_start <=current_timestamp - to_char(current_timestamp,'dd')  and fc1.dt_stop>=current_timestamp - to_char(current_timestamp,'dd')  and fc1.v_status='A') fc on fc.id_department=fd.id_department
inner join fw_services FS ON FS.ID_CONTRACT_INST=fc.id_contract_inst
inner join (select * from fw_services_cost where DT_START<=current_timestamp - to_char(current_timestamp,'dd')  and dt_stop>=current_timestamp - to_char(current_timestamp,'dd') ) fsc on fsc.id_contract_inst=fc.id_contract_inst)

where id_tariff_plan in (select id_tariff_plan from (select id_tariff_plan, sum(n_cost_period-n_discount_period) summary from (select * from fw_departments fd
inner join (select * from fw_contracts fc1 where fc1.dt_start <=current_timestamp - to_char(current_timestamp,'dd')  and fc1.dt_stop>=current_timestamp - to_char(current_timestamp,'dd')  and fc1.v_status='A') fc on fc.id_department=fd.id_department
inner join fw_services FS ON FS.ID_CONTRACT_INST=fc.id_contract_inst
inner join (select * from fw_services_cost where DT_START<=current_timestamp - to_char(current_timestamp,'dd')  and dt_stop>=current_timestamp - to_char(current_timestamp,'dd') ) fsc on fsc.id_contract_inst=fc.id_contract_inst)
group by id_tariff_plan order by summary desc) where rownum<=5)
group by v_name,id_tariff_plan;


--7 
select distinct fc.id_department,table1.V_name nameMax,table2.V_name nameMin from fw_contracts fc

inner join (select fd.id_department,fs.v_name,count(*) cnt from fw_service fs
inner join (select * from fw_services where b_deleted=0) fs1 on fs.id_service=fs1.id_service
inner join (select * from fw_contracts where dt_start<=current_timestamp and dt_stop >= current_timestamp and V_status='A') fc on fc.id_contract_inst=fs1.id_contract_inst
inner join (select * from fw_departments where b_deleted=0) fd on fd.id_department=fc.id_department
group by fd.id_department,fs.v_name
having (fd.id_department,count(*)) in (select id_department,max(cnt) from (select fd.id_department,fs.v_name,count(*) cnt from fw_service fs
inner join (select * from fw_services where b_deleted=0) fs1 on fs.id_service=fs1.id_service
inner join (select * from fw_contracts where dt_start<=current_timestamp and dt_stop >= current_timestamp and V_status='A') fc on fc.id_contract_inst=fs1.id_contract_inst
inner join (select * from fw_departments where b_deleted=0) fd on fd.id_department=fc.id_department
group by fd.id_department,fs.v_name)group by id_department)) table1 on table1.id_department=fc.id_department

inner join(select fd.id_department,fs.v_name,count(*) cnt from fw_service fs
inner join (select * from fw_services where b_deleted=0) fs1 on fs.id_service=fs1.id_service
inner join (select * from fw_contracts where dt_start<=current_timestamp and dt_stop >= current_timestamp and V_status='A') fc on fc.id_contract_inst=fs1.id_contract_inst
inner join (select * from fw_departments where b_deleted=0) fd on fd.id_department=fc.id_department
group by fd.id_department,fs.v_name
having (fd.id_department,count(*)) in (select id_department,min(cnt) from (select fd.id_department,fs.v_name,count(*) cnt from fw_service fs
inner join (select * from fw_services where b_deleted=0) fs1 on fs.id_service=fs1.id_service
inner join (select * from fw_contracts where dt_start<=current_timestamp and dt_stop >= current_timestamp and V_status='A') fc on fc.id_contract_inst=fs1.id_contract_inst
inner join (select * from fw_departments where b_deleted=0) fd on fd.id_department=fc.id_department
group by fd.id_department,fs.v_name)group by id_department)) table2 on table2.id_department=table1.id_department;

--8
select fc.id_contract_inst,fd.V_NAME,count(fc.id_contract_inst)from fw_contracts fc
inner join (select * from fw_services where b_deleted=0) fs on fs.id_contract_inst=fc.id_contract_inst
inner join (select * from fw_departments where b_deleted=0) fd on fd.id_department=fc.id_department
where fc.id_contract_inst in(
                          select * from (
                                 select fc.id_contract_inst from fw_contracts fc
                                 inner join (select * from fw_services where b_deleted=0) fs on fs.id_contract_inst=fc.id_contract_inst
                                 inner join (select * from fw_services_cost where DT_START<= current_timestamp and dt_stop>=current_timestamp) fsc on fsc.ID_SERVICE_INST=fs.ID_SERVICE_INST
                                 group by fc.id_contract_inst
                                 order by sum(N_COST_PERIOD-N_DISCOUNT_PERIOD) desc
                          )
                          where rownum<= (select max(rownum)*0.3 from fw_contracts)
) and fc.dt_start <=current_timestamp and fc.dt_stop>=current_timestamp and fc.v_status='A'
group by fc.id_contract_inst,fd.V_NAME;

--9
select fc.id_contract_inst,fd.v_name,cnt1,cnt0  from fw_contracts fc
inner join (select ID_CONTRACT_INST,count(*) cnt1  from fw_services fs2 inner join (select * from fw_service where B_deleted=0 and b_add_service=1 ) fs1 on fs1.id_service=fs2.id_service group by id_contract_inst ) 
fs on fs.id_contract_inst=fc.id_contract_inst
inner join (select ID_CONTRACT_INST,count(*) cnt0  from fw_services fs2 inner join (select * from fw_service where B_deleted=0 and b_add_service=0 ) fs1 on fs1.id_service=fs2.id_service group by id_contract_inst ) 
fs1 on fs1.id_contract_inst=fc.id_contract_inst
inner join (select * from fw_departments where b_deleted=0) fd on fd.id_department=fc.id_department
where fc.id_contract_inst in(
                          select * from (
                                 select fs.id_contract_inst from fw_services fs
                                 inner join (select * from fw_service where B_deleted=0 and B_ADD_SERVICE=1)  fs1 on fs1.id_service=fs.id_service
                                 inner join (select * from fw_services_cost where DT_START<= current_timestamp and dt_stop>=current_timestamp) fsc on fsc.ID_SERVICE_INST=fs.ID_SERVICE_INST  
                                 where fs.b_deleted=0                         
                                 group by fs.id_contract_inst
                                 order by sum(N_COST_PERIOD-N_DISCOUNT_PERIOD) desc
                          )
                          where rownum<= (select max(rownum)*0.45 from fw_contracts)
);

--10
--10.1
select * from (
select fc.id_contract_inst,fc.id_department,sum(fsc.n_cost_period) summary1,sum(nullif(fsc.n_discount_period,0)) summary2 from fw_contracts fc
inner join fw_services_cost fsc on fsc.id_contract_inst=fc.id_contract_inst
group by fc.id_contract_inst,fc.id_department
order by sum(fsc.n_cost_period)/sum(nullif(fsc.n_discount_period,0)) desc
)
where summary2 is not null and rownum=1;
--10.2
select fc.id_contract_inst,fc.id_department,sum(fsc.n_cost_period) summary1,sum(nullif(fsc.n_discount_period,0)) summary2 from fw_contracts fc
inner join (select * from fw_services_cost where DT_START<= current_timestamp and dt_stop>=current_timestamp) fsc on fsc.id_contract_inst=fc.id_contract_inst
group by fc.id_contract_inst,fc.id_department
having (fc.id_department,sum(fsc.n_cost_period)/sum(nullif(fsc.n_discount_period,0))) in (
select id_department,max(divine) from (
select fc.id_contract_inst,fc.id_department,sum(fsc.n_cost_period)/sum(nullif(fsc.n_discount_period,0)) divine from fw_contracts fc
inner join fw_services_cost fsc on fsc.id_contract_inst=fc.id_contract_inst
group by fc.id_contract_inst,fc.id_department) group by id_department);


--11
select fc.id_department,fs.id_tariff_plan,sum(N_COST_PERIOD-N_DISCOUNT_PERIOD) summary from fw_contracts fc
inner join (select * from fw_services fs where fs.B_deleted=0) fs on fs.id_contract_inst=fc.id_contract_inst
inner join (select * from fw_services_cost where DT_START<= current_timestamp and dt_stop>=current_timestamp) fsc on fsc.ID_SERVICE_INST=fs.ID_SERVICE_INST  
group by fc.id_department,fs.id_tariff_plan
having (id_department,sum(N_COST_PERIOD-N_DISCOUNT_PERIOD))in (
select id_department,max(summary) from (select fc.id_department,fs.id_tariff_plan,sum(N_COST_PERIOD-N_DISCOUNT_PERIOD) summary from fw_services fs  
inner join (select * from fw_contracts where dt_start<=current_timestamp and dt_stop>=current_timestamp)fc on fc.id_contract_inst=fs.id_contract_inst
inner join (select * from fw_departments where b_deleted=0) fd on fd.id_department=fc.id_department
inner join (select * from fw_services_cost where DT_START<= current_timestamp and dt_stop>=current_timestamp) fsc on fsc.ID_SERVICE_INST=fs.ID_SERVICE_INST 
where fs.B_deleted=0 group by  fc.id_department,fs.id_tariff_plan)                
group by id_department)
;
