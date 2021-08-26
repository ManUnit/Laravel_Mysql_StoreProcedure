DROP PROCEDURE IF EXISTS filldates;


DELIMITER |
CREATE PROCEDURE filldates(dateStart DATE, dateEnd DATE)
BEGIN
  DECLARE existingDate  DATE  ;
  WHILE dateStart <= dateEnd DO 

   IF  
      not exists(  SELECT _date  FROM  datelist where _date = dateStart   ) 
      
   THEN 
       
        INSERT INTO datelist(_date) VALUES (dateStart);

   END IF;
   SET dateStart = date_add(dateStart, INTERVAL 1 DAY);
     
  END WHILE;
END

|
DELIMITER ;

call filldates('2021-08-1','2021-08-31') ;