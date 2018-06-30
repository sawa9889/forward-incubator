--1
create or replace procedure saveSigners (pV_FIO in ci_users.v_description%type , pID_MANAGER in ci_users.id_user%type , pACTION in number(1)) is
    cnt number(10);   
begin
  select count(*) into cnt from ci_users where ci_users.id_user = pID_MANAGER
  if cnt=0 then  
    raise_application_error(-20020,'Пользователь не найден')
  end if;
  case pACTION 
    when 1 then
      select Count(*) into cnt from scd_signers where scd_signers.ID_MANAGER = pID_MANAGER
      if cnt=0 then
        insert into scd_signers values(pV_FIO, pID_MANAGER); 
      else 
        raise_application_error(-20021,'Пользователь уже существует');
      end if;
    when 2 then
       update scd_signers set scd_signers.v_fio = pFIO where scd_signers.id_manager=pID_MANAGER;
    when 3 then 
      delete from scd_signers where scd_signers.id_manager=pID_MANAGER;
    end;
end saveSigners;

--2
create or replace function getDecoder(pID_EQUIP in scd_equip_kits.id_equip_kits_inst%type ) 
return scd_equip_kits.v_cas_id%type is
cnt number;
begin
  select count(*) into cnt from scd_equip_kits se 
    where dt_start<=current_timestamp and dt_stop >= current_timestamp and se.id_equip_kits_inst=pID_EQUIP 
  if cnt=0 then
    raise_application_error(-20022,'Нет такого оборудования');
  else
  for i in (select scd_equip_kits.v_cas_id cas_id,scd_equip_kits.v_ext_ident ext_ident,b_agency from scd_equip_kits se
    inner join scd_contracts sc on sc.id_contract_inst=se.id_contract_inst
    where dt_start<=current_timestamp and dt_stop >= current_timestamp and se.id_equip_kits_inst=pID_EQUIP ) loop
    if i.b_agency=1 then
         return i.cas_id;
       else 
         return i.ext_ident;
    end if;
  end loop;
end getDecoder;

--3
create or replace procedure getEquip(pID_EQUIP_KITS_INST in scd_equip_kits.id_equip_kits_inst%type default null,dwr out sys_refcursor) is
cnt number;
begin
  if pID_EQUIP_KITS_INST is null then
      open dwr for select distinct cu.V_description,cu.V_username,fc.ID_CONTRACT_INST,sek.v_name from ci_users cu
      inner join (select * from fw_contracts where dt_start<=current_timestamp and dt_stop >= current_timestamp and V_status='A') 
      fc on fc.ID_CLIENT_INST=cu.ID_CLIENT_INST
      inner join (select * from scd_equip_kits where dt_start<=current_timestamp and dt_stop >= current_timestamp) se
      on se.id_contract_inst=fc.id_contract_inst
      inner join (select * from scd_equipment_kits_type where dt_start<=current_timestamp and dt_stop >= current_timestamp) sek
      on sek.id_equip_kits_type=se.id_equip_kits_type;
    else
      select count(*) into cnt from scd_equip_kits where ID_EQUIP_KITS_INST=pID_EQUIP_KITS_INST;
      if cnt=0 then 
        raise_application_error(-20022,'Нет такого оборудования');
      else
        open dwr for select distinct cu.V_description,cu.V_username,fc.ID_CONTRACT_INST,sek.v_name from ci_users cu
        inner join (select * from fw_contracts where dt_start<=current_timestamp and dt_stop >= current_timestamp and V_status='A') 
        fc on fc.ID_CLIENT_INST=cu.ID_CLIENT_INST
        inner join (select * from scd_equip_kits where dt_start<=current_timestamp and dt_stop >= current_timestamp) se
        on se.id_contract_inst=fc.id_contract_inst
        inner join (select * from scd_equipment_kits_type where dt_start<=current_timestamp and dt_stop >= current_timestamp) sek
        on sek.id_equip_kits_type=se.id_equip_kits_type
        where se.ID_EQUIP_KITS_INST=pID_EQUIP_KITS_INST;
      end;
  end if;
end getEquip;

--4
create or replace procedure checkstatus()
is
  ID_Prodano scd_equipment_status.id_equipment_status%type;
begin
  select id_equipment_status into ID_Prodano from scd_equipment_status where V_STATUS='Продано';
  for i in (select sek.id_equip_kits_inst,sek.id_equip_kits_inst idEquip,fc.v_long_tittle tittle,sek.v_cas_id cas_id,sek.v_ext_ident ext_ident,b_agency agency from scd_equip_kits sek
  inner join (select * from scd_equipment_status where b_deleted=0)se on se.id_equipment_status=sek.id_status
  inner join (select * from fw_clients where dt_start<=current_timestamp and dt_stop >= current_timestamp) fc on fc.ID_CLIENT_INST=sek.id_dealer_client
  inner join scd_contracts sc on sc.id_contract_inst=se.id_contract_inst
  where  not id_dealer_client is null and dt_start<=current_timestamp and dt_stop >= current_timestamp and se.V_NAME!='Продано') loop
    update scd_equip_kits set scd_equip_kits.id_status=ID_Prodano where scd_equip_kits.id_equip_kits_inst=i.id_equip_kits_inst;
    dbms_output.put_line('  Для оборудования'|| i.idEquip || 'дилера '||i.tittle ||'с контрактом'
    case i.agency when 0 then i.cas_id else i.ext_ident end' агентской сетью был проставлен статус Продано.');
  end loop;
  
end checkstatus;
