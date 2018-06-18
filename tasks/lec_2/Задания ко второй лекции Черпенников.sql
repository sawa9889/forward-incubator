--1
select f_sum,DT_EVENT from FW_CONTRACTS
inner join trans_external
on FW_CONTRACTS.ID_CONTRACT_INST = trans_external.ID_CONTRACT
where V_EXT_IDENT='0102100000088207_MG1' and rownum=1
order by trans_external.DT_EVENT desc ;

--2
select V_EXT_IDENT,DT_start,V_NAME from fw_departments
right join fw_contracts on fw_departments.ID_DEPARTMENT=fw_contracts.ID_DEPARTMENT
where V_STATUS='A';

--3 
select fw_departments.V_name from fw_departments
left join fw_contracts on fw_departments.ID_DEPARTMENT=fw_contracts.ID_DEPARTMENT
group by fw_departments.V_name
having count(*)<2;

--4
select distinct V_name,sum(distinct f_sum),count(distinct f_sum),count(distinct ID_CONTRACT_INST) from fw_departments
inner join fw_contracts on fw_departments.ID_DEPARTMENT=fw_contracts.ID_DEPARTMENT
inner join trans_external on fw_contracts.ID_CONTRACT_INST=trans_external.ID_CONTRACT
where trans_external.DT_EVENT > (select max(trans_external.DT_EVENT)from fw_contracts) - interval '30' day
group by V_name;

--5
select  ID_CONTRACT_INST , fw_contracts.V_STATUS, count(distinct ID_TRANs) from fw_contracts
inner join trans_external on fw_contracts.ID_CONTRACT_INST=trans_external.ID_CONTRACT
where trans_external.DT_EVENT like '%.17 %'
group by ID_CONTRACT_INST , fw_contracts.V_STATUS
having count(ID_TRANS)>3;

--6
select distinct fw_contracts.ID_CONTRACT_INST,fw_contracts.v_status,V_NAME from fw_contracts
left join trans_external on fw_contracts.ID_CONTRACT_INST=trans_external.ID_CONTRACT
left join fw_departments on fw_departments.ID_DEPARTMENT=fw_contracts.ID_DEPARTMENT
where trans_external.DT_EVENT like '%.17 %' ;

--7
select  distinct V_name from fw_departments
left join fw_contracts on fw_departments.ID_DEPARTMENT=fw_contracts.ID_DEPARTMENT
left join trans_external on fw_contracts.ID_CONTRACT_INST=trans_external.ID_CONTRACT
where DT_event is null;

--8
select distinct count(distinct ID_TRANS),MAX(DT_EVENT),fw_contracts.ID_CONTRACT_INST,ID_MANAGER from fw_contracts
inner join trans_external on fw_contracts.ID_CONTRACT_INST=trans_external.ID_CONTRACT
group by fw_contracts.ID_CONTRACT_INST,ID_MANAGER;

--9 
select ID_REC from fw_contracts
inner join trans_external on fw_contracts.ID_CONTRACT_INST=trans_external.ID_CONTRACT
where ID_TRANS = 6397542 and DT_START<='01.01.16' and DT_STOP>='01.01.16';

--10
select ID_CONTRACT_INST,V_STATUS,fw_currency.V_NAME from FW_CONTRACTS 
left join fw_currency on fw_currency.ID_CURRENCY= fw_contracts.id_currency 
where ID_CONTRACT_INST in (select ID_CONTRACT_INST from fw_contracts 
        group by ID_CONTRACT_INST,V_STATUS,FW_CURRENCY.V_NAME
        having count(distinct fw_contracts.id_currency)>1)
    and DT_STOP>=current_timestamp;
--11
select ID_CONTRACT_INST,count(V_status) from fw_contracts
where V_status='C'
group by ID_CONTRACT_INST
having count(V_status) >1;
