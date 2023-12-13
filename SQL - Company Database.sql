-- Create table employee
CREATE TABLE employee (
-- SSN as primary key
	ssn INT PRIMARY KEY,
-- First name (can't be null)
	fname VARCHAR(20) NOT NULL,
-- Middle name first letter
	mint CHAR(1),
-- Last name (can't be null)
	lname VARCHAR(20) NOT NULL,
-- Birthday date (YYYY-MM-DD)
	bdate DATE NOT NULL,
-- Employee address
	address VARCHAR(25) NOT NULL,
-- Sex (F or M)
	sex CHAR(1) NOT NULL,
-- Employee salary
	salary INT,
-- Supervisor SSN (Can be null because the CEO doesn't has a supervisor)
	super_ssn INT NULL,
-- Department number
	dno INT
);

-- Insert data into the employee table
INSERT INTO employee(ssn,fname,mint,lname,bdate,address,sex,salary,super_ssn,dno) VALUES
(123456789,'john', 'b', 'smith','1965-01-09','731 Fondren, Houston, TX', 'm',30000,333445555,5),
(333445555,'franklin', 't', 'wong','1955-12-08','638 Voss, Houston, TX', 'm',40000,888665555,5),
(999887777,'alicia', 'j', 'zelaya','1968-01-19','3321 Castle, Spring, TX', 'f',25000,987654321,4),
(987654321,'jennifer', 's', 'wallace','1941-06-20','291 Berry, Bellaire, TX', 'f',43000,888665555,4),
(666884444,'ramesh', 'k', 'narayan','1962-09-15','975 Fire Oak, Humble, TX', 'm',38000,333445555,5),
(453453453,'joyce', 'a', 'english','1972-07-31','5631 Rice, Houston, TX', 'f',25000,333445555,5),
(987987987,'ahmad', 'v', 'jabbar','1969-03-29','980 Dallas, Houston, TX', 'm',25000,987654321,4),
(888665555,'james', 'e', 'borg','1937-11-10','450 Stone, Houston, TX', 'm',55000,NULL,1);

-- Select everything from employee
SELECT * FROM employee;

-- ----------------------------------------------------------------------------------------------------------

-- Create table department
CREATE TABLE department (
-- Department number as primary key
	dnumber INT PRIMARY KEY,
-- Department name (just unique values)
	dname VARCHAR(30) UNIQUE NOT NULL,
	mgr_ssn INT NOT NULL,
	mgr_start_date DATE 
);

-- Insert data into the department table
INSERT INTO department(dnumber,dname,mgr_ssn,mgr_start_date) VALUES
(5,'research',333445555,'1988-05-22'),
(4,'administration',987654321,'1995-01-01'),
(1,'headquarter',888665555,'1981-06-19');

-- Select everything from department
SELECT * FROM department;

-- ----------------------------------------------------------------------------------------------------------

-- Alter the employee table adding the constrait fk_department_dno (foreign key department)
ALTER TABLE employee
ADD CONSTRAINT fk_department_dno
-- The foreign key dno referes to the dnumber values of the department table (dno = dnumber)
FOREIGN KEY (dno) REFERENCES department(dnumber);

-- ----------------------------------------------------------------------------------------------------------

-- Create table depto_locations
CREATE TABLE depto_locations (
-- dnumber referes to dnumber values of the department table
	dnumber INT  REFERENCES department(dnumber),
-- Department location
    dlocation VARCHAR(30),
-- dnumber concatenated with dlocation as the primary key
    PRIMARY KEY (dnumber, dlocation));

-- Insert data into the depto_locations table
INSERT INTO depto_locations(dnumber,dlocation) VALUES
(1,'houston'),
(4,'stafford'),
(5,'bellaire'),
(5,'sugarland'),
(5,'houston');

-- Select everything from depto_locations
SELECT * FROM depto_locations;

-- ----------------------------------------------------------------------------------------------------------

-- Create table project
CREATE TABLE project (
-- Project number as primary key
	pnumber INT PRIMARY KEY,
-- Project name
	pname VARCHAR(30) NOT NULL,
-- Department number
	dnum INT,
-- Project location
	plocation VARCHAR(30) NOT NULL,
-- dnum is the foreign key and referes to the dnumber values of the department table
	FOREIGN KEY (dnum) REFERENCES department(dnumber)
);

-- Insert data into the table project
INSERT INTO project(pnumber,pname,dnum,plocation) VALUES 
(1,'productx',5,'bellaire'),
(2,'producty',5,'sugarland'),
(3,'productz',5,'houston'),
(10,'computerization',4,'stafford'),
(20,'reorganization',1,'houston'),
(30,'newbenefits',4,'stafford');

-- Select everything from project
SELECT * FROM project;

-- ----------------------------------------------------------------------------------------------------------

-- Create the table works_on
CREATE TABLE works_on (
-- Employee SSN
	essn INT,
-- Project number
	pno INT,
-- Total hours spent on the project
	hours NUMERIC(4,1) NULL,
-- eSSN is the foreign key and referes to the ssn values of the employee table
	FOREIGN KEY (essn) REFERENCES employee(ssn),
-- pno is the foreign key and referes to the dnumber values fo the project table
	FOREIGN KEY (pno) REFERENCES project(pnumber),
-- eSSN concatenated with pno as the primary key
	PRIMARY KEY(essn,pno)
);

-- Insert data into the table works_on
INSERT INTO works_on (essn,pno,hours) VALUES
(123456789,1,32.5),
(123456789,2,7.5),
(666884444,3,40),
(453453453,1,20),
(453453453,2,20),
(333445555,2,10),
(333445555,3,10),
(333445555,10,10),
(333445555,20,10),
(999887777,30,30),
(999887777,10,10),
(987987987,10,35),
(987987987,30,5),
(987654321,30,20),
(987654321,20,15),
(888665555,20,NULL);

-- Select everything from works_on
SELECT * FROM works_on;

-- ----------------------------------------------------------------------------------------------------------

-- Create the table dependent
CREATE TABLE dependent (
-- Dependent employee SSN
	essn INT NOT NULL,
-- Dependent name
	dependent_name VARCHAR(30) NOT NULL,
-- Dependent sex (checked if is F or M)
	sex CHAR(1) NOT NULL CHECK(sex IN ('f','m')),
-- Dependent birthday date
	bdate DATE NOT NULL,
-- Relationship between the employee and it's dependent (son, daughter, spouse or husband)
	relationship varchar(10) CHECK (relationship IN ('son','daughter','spouse','husband')),
-- eSSN is the foreign key and referes to the SSN values fo the employee table
	FOREIGN KEY (essn) REFERENCES employee(ssn),
-- eSSN concatenated with the dependent_name as the primary key
	PRIMARY KEY (essn,dependent_name)
);

-- Insert data into the table dependent
INSERT INTO dependent(essn,dependent_name,sex,bdate,relationship) VALUES
(333445555,'alice','f','1986-04-05','daughter'),
(333445555,'teodore','m','1983-10-25','son'),
(333445555,'joy','f','1958-05-03','spouse'),
(987654321,'abner','m','1942-02-28','spouse'),
(123456789,'michael','m','1988-01-04','son'),
(123456789,'alice','f','1988-12-30','daughter'),
(123456789,'elizabeth','f','1967-05-05','spouse');

-- Select everything from dependent
SELECT * FROM dependent;

-- ----------------------------------------------------------------------------------------------------------

-- Employee's dependents
SELECT	CONCAT(e.fname, ' ', e.lname) AS "Employee Name",
		d.dependent_name AS "Dependent"
FROM employee e
LEFT JOIN dependent d ON e.ssn = d.essn;

-- Dependents number by employee
SELECT	CONCAT(e.fname, ' ', e.lname) AS "Employee Name",
		COUNT(d.dependent_name) AS "Dependents Total"
FROM employee e
LEFT JOIN dependent d ON e.ssn = d.essn
GROUP BY e.ssn, e.fname;

-- Employee with 3 dependents
SELECT	CONCAT(e.fname, ' ', e.lname) AS "Employee Name"
FROM employee e
LEFT JOIN dependent d ON e.ssn = d.essn
GROUP BY e.ssn
HAVING COUNT(d.dependent_name) = 3;

-- Projects departments
SELECT	p.pname AS "Project Name",
		d.dname AS "Department Name"
FROM project p
JOIN department d ON p.dnum = d.dnumber;

-- Number of projects by department
SELECT	d.dname AS "Departament Name",
		COUNT(p.pnumber) AS "Projects Total"
FROM department d
LEFT JOIN project p ON d.dnumber = p.dnum
GROUP BY d.dname;

-- Hours spent in projects by each department
SELECT	d.dname AS "Departament Name",
		COALESCE(SUM(wo.hours), 0) AS "Total Hours"
FROM department d
LEFT JOIN employee e ON d.mgr_ssn = e.ssn
LEFT JOIN works_on wo ON e.ssn = wo.essn
GROUP BY d.dname;

-- Number of departments by location
SELECT	d.dlocation AS "Location",
		COUNT(d.dnumber) AS "Number of Departments"
FROM depto_locations d
GROUP BY d.dlocation;

-- Number of employees by department location
SELECT	d.dname AS "Department",
		COUNT(e.dno) AS "Number of Employees"
FROM department d, employee e
WHERE e.dno = d.dnumber
GROUP BY d.dname;

-- Number of employees by location
SELECT	d.dlocation AS "Location",
		COUNT(e.dno) AS "Number of Employees"
FROM depto_locations d, employee e
WHERE e.dno = d.dnumber
GROUP BY d.dlocation;