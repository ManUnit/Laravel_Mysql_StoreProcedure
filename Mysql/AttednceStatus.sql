CREATE DEFINER=`dbadmin`@`%` PROCEDURE `find_shift_checkin`(
    IN userid INT
)
BEGIN
-- today recourd count        =>  _today_checkin_count_shift 
-- shift number for checkin   =>  _today_max_shift_number
-- last shift record id
  DECLARE employeeid INT ;
  DECLARE _today_checkin_count_shift  INT ;
  DECLARE _today_max_shift_number INT ;
  DECLARE _today_checkin_record_id INT ;
  DECLARE _today_status INT ; 
  DECLARE _today_maxshift_created DATETIME ;
  DECLARE _today_maxshift_updated DATETIME ;
	
-- DECLARE _usr_table_name TINYTEXT = _usr_table ;

-- Yesterday check last shift have complate checkout 
  DECLARE _ytd_lastshift_rec_id INT ; 
  DECLARE _ytd_created DATETIME  ; 
  DECLARE _ytd_updated DATETIME ; 
  DECLARE _ytd_shift INT ; 
  DECLARE _ytd_max_shift INT ;
  DECLARE _ytd_count INT ; 
        DECLARE _ytd_max_rec_id  INT ;
        DECLARE _usr_dynamic_table  varchar(50) ;
        DECLARE _ytd_status INT ;
        DECLARE _ytd_is_holiday INT ; 
        DECLARE _ytd_hoilday_count INT ; 
        DECLARE _ytd_weekday INT ; 
  SET  _usr_dynamic_table  = CONCAT('shiftcheckin', userid );   -- Dynamic table  name 

  DROP temporary TABLE IF EXISTS _usr_dynamic_table  ;

  CREATE temporary TABLE _usr_dynamic_table  ( list_keys VARCHAR(100)  , data_values VARCHAR(100) ) ; 
	
-- Find Employee ID 
select employees.id into employeeid from employees where user_id=userid ; 

select count(*) INTO _today_checkin_count_shift  from attendances 
          where employee_id=employeeid 
                and date_format(created_at,'%Y-%m-%d') = date_format(now(),'%Y-%m-%d') ;  


 select max(shift) INTO _today_max_shift_number  from attendances 
          where employee_id=employeeid 
                and date_format(created_at,'%Y-%m-%d') = date_format(now(),'%Y-%m-%d') ; 

 select id , created_at , updated_at  INTO _today_checkin_record_id , _today_maxshift_created ,_today_maxshift_updated  
        from attendances 
          where employee_id=employeeid 
                and date_format(created_at,'%Y-%m-%d') = date_format(now(),'%Y-%m-%d') 
                and shift = _today_max_shift_number  ; 




-- Defind Today Status 
-- today shift checkin status 
-- _today_status
-- 0 not found any today checkin 
-- 1 ready to check out max shift 
-- 2 checkin for next shift 


IF ( _today_checkin_count_shift = 0 and _today_max_shift_number IS NULL  )  THEN   --  once found nothing  going to checkin for todays 
 SET _today_status = 0 ; 
ELSEIF (_today_maxshift_created = _today_maxshift_updated  and _today_max_shift_number > 0 and _today_maxshift_created IS NOT NULL ) THEN  
 SET _today_status = 1 ; 
--  ready for todays checkout on max number of shift  and have to get more other parameter to find point of record number to update 
ELSEIF (  _today_checkin_count_shift > 0 
           and _today_maxshift_created != _today_maxshift_updated  
					 and _today_max_shift_number > 0 
					 and _today_maxshift_created IS NOT NULL
					 ) THEN 
-- once today the max of shift number has  shift checkout
  SET  _today_status = 2 ; -- do checkin for next shift
END IF ;

IF ( _today_max_shift_number IS NULL ) THEN 
 set _today_max_shift_number = 0  ; 
END IF ; 


-- Yesterday last shift check 

select count(*) INTO _ytd_hoilday_count from holidays where date_format( subdate(current_date, 1) , '%Y-%m-%d'  )   BETWEEN   date_format( start_date , '%Y-%m-%d'  ) and  date_format( end_date , '%Y-%m-%d'  )  ;


-- HOLIDAY Chekin  CHECK 
select count(*) into  _ytd_count
     from attendances 
     where  employee_id=employeeid 
       and  date_format(created_at,'%Y-%m-%d' ) =  date_format( subdate(current_date, 1) , '%Y-%m-%d'  ) ;

select max(shift) into _ytd_max_shift 
     from attendances 
     where  employee_id=employeeid 
       and  date_format(created_at,'%Y-%m-%d' ) =  date_format( subdate(current_date, 1) , '%Y-%m-%d'  ) ;
			 


select id, created_at,updated_at,shift  into _ytd_max_rec_id , _ytd_created , _ytd_updated , _ytd_shift 
     from attendances 
     where  employee_id=employeeid 
     and  date_format(created_at,'%Y-%m-%d' ) =  date_format( subdate(current_date, 1) , '%Y-%m-%d'  ) 
     and shift=_ytd_max_shift  ;

-- Weekday Note: 0 = Monday, 1 = Tuesday, 2 = Wednesday, 3 = Thursday, 4 = Friday, 5 = Saturday, 6 = Sunday.

SELECT WEEKDAY(date_format( subdate(current_date, 1) , '%Y-%m-%d'  ) ) into _ytd_weekday ;


-- Values setting by conditions 
-- select _ytd_created , _ytd_updated ; 
-- select  DATE_SUB( now() , INTERVAL 2 HOUR)  ;
-- select  TIMESTAMPDIFF( HOUR  , _ytd_created , DATE_SUB( now() , INTERVAL 2 HOUR))   ;
-- YTD_STATUS
-- 0 Nothing  , yesterday dont come to work 
-- 1 Status Normal  CheckIN + CheckOUT
-- 2 Request Checkout  yestrday 
-- 3 Forgot checkout yesterday within 12hrs after checkin 




IF (_ytd_updated IS NULL and _ytd_created IS NULL )  THEN 
  SET  _ytd_status = 0 ;  -- Nothing 
ELSEIF ( _ytd_updated !=  _ytd_created  and  _ytd_created IS NOT NULL  and _ytd_updated IS NOT NULL) THEN 
  SET  _ytd_status = 1 ; -- Status Normal  CheckIN + CheckOUT
ELSEIF (  _ytd_updated = _ytd_created and TIMESTAMPDIFF( HOUR  , _ytd_created , DATE_SUB( now() , INTERVAL 2 HOUR)) <= 12  ) THEN
  SET _ytd_status = 2 ;  -- Request Checkout 
ELSEIF (  _ytd_updated = _ytd_created and TIMESTAMPDIFF( HOUR  , _ytd_created , DATE_SUB( now() , INTERVAL 2 HOUR)) > 12   ) THEN
  SET _ytd_status = 3 ;  -- Forgot checkout 
END IF ;

IF ( _ytd_max_shift IS NULL ) THEN  
 SET _ytd_max_shift = 0 ;  
END IF ; 


-- Yesterday is hoilday 
if ( _ytd_hoilday_count > 0  ) THEN
 SET _ytd_is_holiday = 1  ;
ELSE 
 SET _ytd_is_holiday = 0 ;
END IF ;

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'user_id' , userid );

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'employee_id' , employeeid );
					 
insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'today_status' , _today_status );

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'today_count' , _today_checkin_count_shift );

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'today_max_shift' , _today_max_shift_number );

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'today_max_shift_record_id' , _today_checkin_record_id );
					 
insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'today_checkin_at' , _today_maxshift_created );
                                         
-- Yester day value 

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'ytd_count' , _ytd_count  );
                                         
insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'ytd_max_shift' , _ytd_max_shift  );                                         
                                         
insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'ytd_max_shift_record_id' , _ytd_max_rec_id  );
                                         
insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'ytd_status' , _ytd_status );

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'ytd_checkin_at' , _ytd_created );

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'ytd_is_holiday' , _ytd_is_holiday  );

insert into _usr_dynamic_table ( list_keys , data_values ) 
           values ( 'ytd_weekday' , _ytd_weekday   );


select * from _usr_dynamic_table  ;

DROP temporary TABLE _usr_dynamic_table ; 

  
END
