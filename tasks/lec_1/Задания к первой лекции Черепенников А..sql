--1
select count(*)from fw_process_log 
where V_message like '%2520123%' and id_error_code != 0

--2
select to_char(MAX(dt_timestamp),'dd.mon.yyyy') from fw_process_log 
where V_message like '%2520123%' and id_error_code != 0 

--3
select distinct substr(V_message,35) from fw_process_log 
where v_message like 'Загрузка порции заказов начиная с%' 

--4
select  count(distinct substr(V_message,35)) from fw_process_log 
where v_message like 'Загрузка порции заказов начиная с%'

--5
select sum(substr(V_message,140)) from fw_process_log 
where v_message like '%Общее время выполнения%'

--6
select count(*)from fw_process_log 
where DT_timestamp like '%-MAR-18%' and V_message like 'Процесс продвижения заказов завершен.%' 

--7
select  count(count(*)) from fw_process_log 
group by sid 
having count(*)!=1

--8
select substr(V_message,13,instr(V_message,' вошел')-13),dt_timestamp from fw_process_log
where id_user = 11136 
and v_message like '%вошел в систему%' 
and dt_timestamp = (select max(dt_timestamp) from fw_process_log where id_user =11136);

--9
select  count(substr(to_char(DT_TIMESTAMP,'dd.month.yyyy'),4,instr(to_char(DT_TIMESTAMP,'dd.month.yyyy'),'.',4)-4)) from fw_process_log 
group by substr(to_char(DT_TIMESTAMP,'dd.month.yyyy'),4,instr(to_char(DT_TIMESTAMP,'dd.month.yyyy'),'.',4)-4);


--10 
select count(distinct V_MESSAGE),count(*) from fw_process_log
where N_status =500 and id_process = 5 and DT_timestamp>'2018-02-22' and DT_timestamp<'2018-03-02';

--11
select min(n_sum) from fw_transfers
where dt_incoming>'2017-02-14 10:00' 
and dt_incoming <'2017-02-14 12:00' 
and id_contract_from != Id_contract_to

--12
select id_contract_to,dt_incoming,length(V_description)-22 from fw_transfers
where length(V_DESCRIPTION)>22
order by length(V_description)-22 desc;

--13
select to_char(dt_incoming,'dd.mm.yyyy'),count(*) from fw_transfers

where ID_CONTRACT_FROM=ID_CONTRACT_to

group by to_char(dt_incoming,'dd.mm.yyyy');