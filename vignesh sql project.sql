create database logistics;
use logistics;

CREATE TABLE Employee_Details(					
  Emp_ID INT(5) NOT NULL,										
  Emp_name VARCHAR(30) NULL,									
  Emp_branch VARCHAR(15) NULL,								    
  Emp_designation VARCHAR(40) NULL,							   
  Emp_addr VARCHAR(100) NULL,									
  Emp_Cont_no VARCHAR(10) NULL,						     		
  PRIMARY KEY (Emp_ID)									    	
);

select * from Employee_Details;

CREATE TABLE IF NOT EXISTS Membership(						
  M_ID INT NOT NULL,										
  Start_Date TEXT NULL,										
  End_Date TEXT NULL,										
  PRIMARY KEY (M_ID)										
);

select * from Membership;

CREATE TABLE  customer (							
  Cust_ID INT(4) NOT NULL,
  Membership_M_ID INT NOT NULL,
  Cust_name VARCHAR(30) NULL,									
  Cust_email_id VARCHAR(50) NULL,	
  Cust_type VARCHAR(20) NULL,
  Cust_addr VARCHAR(100) NULL,
  Cust_cont_no VARCHAR (10) NULL,								
  PRIMARY KEY (Cust_ID, Membership_M_ID),						
  CONSTRAINT fk_customer_Membership1							
    FOREIGN KEY (Membership_M_ID)
    REFERENCES Membership (M_ID));
    
    
CREATE TABLE Shipment_Details(				
  Sd_id VARCHAR(6) NOT NULL,								
  Sd_content VARCHAR(40) NULL,
  Sd_domain VARCHAR(15) NULL,								
  Sd_type VARCHAR(15) NULL,								    
  Sd_weight VARCHAR(10) NULL,								
  Sd_charges INT(10) NULL,									
  Sd_addr VARCHAR(100) NULL,								
  Ds_Addr VARCHAR(100) NULL,								
  Customer_Cust_ID INT(4) NOT NULL,							
  PRIMARY KEY (Sd_id, Customer_Cust_ID),					
  CONSTRAINT fk_Shipment_Customer							
    FOREIGN KEY (Customer_Cust_ID)
    REFERENCES Customer(Cust_ID)
);

CREATE TABLE  Payment_Details(							
  PAYMENT_ID VARCHAR(40) NOT NULL,							
  Amount INT NULL,											
  Payment_Status VARCHAR(10) NULL,							
  Payment_Date TEXT NULL,									
  Payment_Mode VARCHAR(25) NULL,							
  Shipment_Details_Sd_id VARCHAR(6) NOT NULL,						
  Shipment_Details_Customer_Cust_ID INT(4) NOT NULL,						
  PRIMARY KEY (PAYMENT_ID, Shipment_Details_Sd_id, Shipment_Details_Customer_Cust_ID),		  
  CONSTRAINT fk_Payment_Shipment1							
    FOREIGN KEY (Shipment_Details_Sd_id , Shipment_Details_Customer_Cust_ID)
    REFERENCES Shipment_Details (Sd_id ,Customer_Cust_ID));
    
CREATE TABLE IF NOT EXISTS Status(							
  Current_ST VARCHAR(15) NOT NULL,							
  Sent_date TEXT NULL,										
  Delivery_date TEXT NULL,									
  Sh_id VARCHAR(6) NOT NULL,								
  PRIMARY KEY (Sh_id));	
  
  
CREATE TABLE IF NOT EXISTS Employee_Manages_Shipment(		
  Employee_Details_Emp_ID INT(5) NOT NULL,							
  Shipment_Details_Sd_id VARCHAR(6) NOT NULL,						
  Status_Sh_id VARCHAR(6) NOT NULL,							
  
  PRIMARY KEY (Employee_Details_Emp_ID, Shipment_Details_Sd_id, Status_Sh_id),	

  CONSTRAINT fk_Employee_Manages_Shipment_Employee				
    FOREIGN KEY (Employee_Details_Emp_ID)
    REFERENCES Employee_Details (Emp_ID),
  CONSTRAINT fk_Employee_Manages_Shipment_Shipment1				
    FOREIGN KEY (Shipment_Details_Sd_id)
    REFERENCES Shipment_Details (Sd_id),
  CONSTRAINT fk_Employee_Manages_Shipment_Status1				
    FOREIGN KEY (Status_Sh_id)
    REFERENCES Status (Sh_id)
);


#Converting the string in to a date format
-- -----------------------------------------------------
UPDATE Payment_Details
	SET Payment_Date = STR_TO_DATE(Payment_Date,'%Y-%m-%d');    
UPDATE STATUS
	SET Delivery_Date = STR_TO_DATE(Delivery_Date,'%m/%d/%Y'),
    Sent_Date = STR_TO_DATE(Sent_Date,'%m/%d/%Y');
UPDATE MEMBERSHIP
	SET Start_Date = STR_TO_DATE(Start_Date,'%Y-%m-%d'),
    End_Date = STR_TO_DATE(End_Date,'%Y-%m-%d');
    
 CREATE TABLE logistics_Emp AS
SELECT 
	emp.Emp_ID, ship.Sd_id, Cust.Cust_ID, pmt.PAYMENT_ID, memb.M_ID,
    emp.Emp_name, emp.Emp_addr, emp.Emp_branch, emp.Emp_designation, emp.Emp_Cont_no,
    ship.Sd_domain, ship.Sd_content, ship.Sd_addr, ship.Ds_Addr, ship.Sd_weight, ship.Sd_type, ship.Sd_charges,
    cust.Cust_name, cust.Cust_type, cust.Cust_addr, cust.Cust_cont_no, cust.Cust_email_id,
    stat.Sent_Date, stat.Delivery_Date, stat.Current_ST, 
    pmt.Amount, pmt.Payment_Status, pmt.Payment_Date, pmt.Payment_Mode,
    memb.Start_Date, memb.End_Date
    
FROM
    Employee_Details AS emp
         INNER JOIN
	employee_manages_shipment AS ems ON emp.Emp_ID = ems.Employee_details_Emp_ID
         INNER JOIN
   Shipment_Details AS ship ON ship.Sd_id = ems.Shipment_details_Sd_id
		 INNER JOIN
	Customer AS cust ON Cust.Cust_ID = ship.Customer_Cust_ID
		 INNER JOIN
	status AS stat ON ship.Sd_id = stat.Sh_id
		 INNER JOIN
	Payment_Details AS pmt ON ship.sd_id = pmt.Shipment_Details_Sd_id
		 INNER JOIN
	Membership AS memb ON memb.M_ID = cust.Membership_M_ID; 
select * from logistics_Emp;   
   




    DESCRIBE Customer;
DESCRIBE Employee_Details;
DESCRIBE Shipment_Details;
DESCRIBE Payment_Details;
DESCRIBE Membership;
DESCRIBE status;
DESCRIBE employee_manages_shipment;
DESCRIBE logistics_Emp;
# 3) Extract all the employees whose name starts with A and ends with A.
SELECT 
    Emp_ID
FROM
    Employee_Details
WHERE
    Emp_ID LIKE 'A%A';

# 4) Find all the common names from Employee_Details names and Customer names.
SELECT DISTINCT(Emp_name) FROM Employee_Details WHERE Emp_name IN (SELECT Cust_name FROM Customer AS cus);


# 5) Create a view 'PaymentNotDone' of those customers who have not paid the amount.
CREATE VIEW PaymentNotDone AS
SELECT * FROM payment_details
WHERE PAYMENT_STATUS = 'NOT PAID';

select * from PaymentNotDone;



# 6) Find the frequency (in percentage) of each of the class of the payment mode
SET @total_count = 0;
SELECT COUNT(*) INTO @total_count FROM Payment_Details;
SELECT 
    PAYMENT_MODE,
    ROUND((COUNT(PAYMENT_MODE) / @total_count) * 100,2) 
		AS Percentage_Contribution
FROM
    Payment_Details
GROUP BY PAYMENT_MODE;

# 7) Create a new column 'Total_Payable_Charges' using shipping cost and price of the product.
ALTER TABLE logistics_Emp
	ADD COLUMN TOTAL_PAYABLE_CHARGES FLOAT AFTER AMOUNT;

UPDATE logistics_Emp 
	SET TOTAL_PAYABLE_CHARGES = Sd_charges + Amount;
SELECT TOTAL_PAYABLE_CHARGES FROM logistics_Emp;

# 8) What is the highest total payable amount ?
SELECT MAX(TOTAL_PAYABLE_CHARGES) FROM logistics_Emp;


# 9) Extract the customer id and the customer name  of the customers who were or will be the member of the branch for more than 10 years
SELECT Cust_ID, Cust_name, Start_Date, End_Date, ROUND(DATEDIFF(End_Date, Start_Date)/365,0) 
	AS Membership_Years FROM logistics_Emp 
HAVING Membership_Years > 10;


# 10) Who got the product delivered on the next day the product was sent?
SELECT * FROM logistics_Emp 
	HAVING DELIVERY_DATE-SENT_DATE = 1;
SELECT * FROM logistics_Emp 
	HAVING DATEDIFF(Delivery_Date, Sent_Date)=1;

# 11) Which shipping content had the highest total amount (Top 5).
SELECT 
   Sd_content, SUM(AMOUNT) AS Content_Wise_Amount
FROM
    logistics_Emp
GROUP BY (Sd_content)
ORDER BY Content_Wise_Amount DESC
LIMIT 5;

# 12) Which product categories from shipment content are transferred more?  
SELECT Sd_content, COUNT(Sd_content) 
	AS Content_Wise_Count 
FROM logistics_Emp 
GROUP BY(Sd_content) 
ORDER BY Content_Wise_Count DESC 
LIMIT 5;

# 13) Create a new view 'TXLogistics' where employee branch is Texas.
CREATE VIEW TXLogistics AS
	SELECT * FROM logistics_Emp 
		WHERE Emp_branch = 'TX';

SELECT * FROM TXLogistics;


# 14) Texas(TX) branch is giving 5% discount on total payable amount. Create a new column 'New_Price' for payable price after applying discount.
ALTER VIEW TXLogistics
   AS SELECT *, Amount - ((Amount * 5)/100) AS New_Price 
   FROM logistics_Emp
   WHERE Emp_branch = 'TX';
SELECT * FROM TXLogistics;
   
   
# 15) Drop the view TXLogistics
DROP VIEW TXLogistics;


# 16) The employee branch in New York (NY) is shutdown temporarily. Thus, the the branch needs to be replaced to New Jersy (NJ).
SELECT * FROM logistics_Emp WHERE Emp_branch = 'NY';

UPDATE logistics_Emp
	SET Emp_branch = 'NJ'
WHERE Emp_branch = 'NY';

SELECT * FROM logistics_Emp;

# 17) Finding the unique designations of the employees.
SELECT DISTINCT(Emp_designation) FROM Employee_Details;

# 18) We will see the frequency of each customer type (in percentage).
SET @total_count = 0;
SELECT COUNT(*) INTO @total_count FROM logistics_Emp;
SELECT Cust_type, (COUNT(Cust_type)/@total_count)*100 
	AS Contribution FROM logistics_Emp 
GROUP BY Cust_type;

# 19) Rename the column SER_TYPE to SERVICE_TYPE.
ALTER TABLE logistics_Emp
CHANGE SER_TYPE SERVICE_TYPE VARCHAR (15);

# 20) Which service type is preferred more?
SELECT SERVICE_TYPE, COUNT(SERVICE_TYPE) 
	AS Frequency 
FROM logistics_Emp 
GROUP BY SERVICE_TYPE 
ORDER BY Frequency DESC;

# 21) Find the shipment id and shipment content where the weight is greater than the average weight.
SELECT Sd_id, Sd_content, Sd_weight FROM Shipment_Details
WHERE Sd_weight > (SELECT AVG(Sd_weight) FROM Shipment_Details);