CREATE TABLE employee_data (
    employee_nNme VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    AlphaNnmeric VARCHAR(15) NOT NULL,
    Employee_Start_Date DATE NOT NULL,
    Current_Line_Manager VARCHAR(100) NOT NULL,
    Line_Manager_Department VARCHAR(100) NOT NULL,
    Department VARCHAR(100) NOT NULL,
    Department_Email VARCHAR(100) NOT NULL

)