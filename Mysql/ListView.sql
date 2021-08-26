DROP PROCEDURE IF EXISTS filldates;


DELIMITER |

CREATE PROCEDURE `listview`(IN dateStart DATE,  IN dateEnd DATE , IN id int)
BEGIN

		
DECLARE _created_at  DATETIME  ;
DECLARE _updated_at  DATETIME  ;

DROP  table IF EXISTS listview ;

create temporary table listview
(
date datetime,
checkin datetime,
checkout  datetime 
) ;

WHILE ( dateStart <= dateEnd ) DO

select  created_at , updated_at into _created_at ,  _updated_at 
from attendances  
where   DATE_FORMAT( created_at,'%Y-%m-%d') = DATE_FORMAT(dateStart,'%Y-%m-%d') and employee_id = id  ; 

-- IF _created_at = _updated_at THEN
--    SET _updated_at =  null  ;
-- END IF ;	 
	 
IF EXISTS ( 	select  created_at , updated_at  
                from attendances  
		where   DATE_FORMAT( created_at,'%Y-%m-%d')  = DATE_FORMAT(dateStart,'%Y-%m-%d') 
		and employee_id = id   
) 
THEN

    IF _created_at = _updated_at THEN
       SET _updated_at =  null  ;
    END IF ;	
		
    insert into listview(date, checkin,checkout)
    values  ( dateStart  ,  _created_at ,_updated_at );

ELSE 

    insert into listview(date, checkin,checkout)
    values  ( dateStart  ,  null,null );

END IF ;
SET dateStart = date_add(dateStart, INTERVAL 1 DAY);


END WHILE ; 

select DATE_FORMAT( date,'%Y-%m-%d')  as date, DATE_FORMAT( checkin  , '%H:%i:%s') as checkin  , DATE_FORMAT( checkout  , '%H:%i:%s')  as checkout  from listview;
drop temporary table listview ;

END


|
DELIMITER ;

call filldates('2021-08-1','2021-08-31') ;