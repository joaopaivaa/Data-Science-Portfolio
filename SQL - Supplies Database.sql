CREATE TABLE Supplier (
    S VARCHAR(4) PRIMARY KEY,
    SNAME VARCHAR(50),
    STATUS int(4),
    CITY VARCHAR(50)
);

CREATE TABLE Part (
    P VARCHAR(4) PRIMARY KEY,
    PNAME VARCHAR(50),
    COLOR VARCHAR(50),
    WEIGHT DECIMAL(4, 2),
    CITY VARCHAR(50)
);

CREATE TABLE Project (
    J VARCHAR(4) PRIMARY KEY,
    JNAME VARCHAR(50),
    CITY VARCHAR(50)
);

CREATE TABLE SPJ (
	S VARCHAR(4),
	P VARCHAR(4),
	J VARCHAR(4),
    FOREIGN KEY (S) REFERENCES Supplier(S),
    FOREIGN KEY (P) REFERENCES Part(P),
    FOREIGN KEY (J) REFERENCES Project(J),
    QUANTITY INT(5)
);

INSERT INTO Supplier (S, SNAME, STATUS, CITY)
VALUES
    ('S1', 'Smith', 20, 'London'),
    ('S2', 'Jones', 10, 'Paris'),
    ('S3', 'Blake', 30, 'Paris'),
    ('S4', 'Clark', 20, 'London'),
    ('S5', 'Adams', 30, 'Athens');
    
INSERT INTO Part (P, PNAME, COLOR, WEIGHT, CITY)
VALUES
    ('P1', 'Porca', 'Red', 12, 'London'),
    ('P2', 'Pino', 'Green', 17, 'Paris'),
    ('P3', 'Parafuso', 'Blue', 17, 'Rome'),
    ('P4', 'Parafuso', 'Red', 14, 'London'),
    ('P5', 'Came', 'Blue', 12, 'Paris'),
    ('P6', 'Tubo', 'Red', 19, 'London');
    
INSERT INTO Project (J, JNAME, CITY)
VALUES
    ('J1', 'Classifier', 'Paris'),
    ('J2', 'Monitor', 'Rome'),
    ('J3', 'OCR', 'Athens'),
    ('J4', 'Console', 'Athens'),
    ('J5', 'RAID', 'London'),
    ('J6', 'EDS', 'Oslo'),
    ('J7', 'Tape', 'London');
    
INSERT INTO SPJ (S, P, J, QUANTITY)
VALUES
    ('S1', 'P1', 'J1',200),
    ('S1', 'P1', 'J4',700),
    ('S2', 'P3', 'J1',400),
    ('S2', 'P3', 'J2',200),
    ('S2', 'P3', 'J3',200),
	('S2', 'P3', 'J4',500),
    ('S2', 'P3', 'J5',600),
    ('S2', 'P3', 'J6',400),
    ('S2', 'P3', 'J7',800),
    ('S2', 'P5', 'J2',100),
    ('S3', 'P3', 'J1',200),
    ('S3', 'P4', 'J2',500),
    ('S4', 'P6', 'J3',300),
    ('S4', 'P6', 'J7',300),
    ('S5', 'P2', 'J2',200),
    ('S5', 'P2', 'J4',100),
    ('S5', 'P5', 'J5',500),
    ('S5', 'P5', 'J7',100),
    ('S5', 'P6', 'J2',200),
    ('S5', 'P1', 'J4',100),
    ('S5', 'P3', 'J4',200),
    ('S5', 'P4', 'J4',800),
    ('S5', 'P5', 'J4',400),
    ('S5', 'P6', 'J4',500);