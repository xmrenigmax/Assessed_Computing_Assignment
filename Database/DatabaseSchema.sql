/** Creation of the database schema */


-- Department table
CREATE TABLE Department (
    Department_ID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentEmail VARCHAR(100) NOT NULL
);

-- Employee table
CREATE TABLE Employee (
    Employee_ID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Email VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    EmployeeStartDate DATE NOT NULL,
    CurrentLineManager VARCHAR(100),
    Department_ID INT NOT NULL,
    CONSTRAINT fk_Department FOREIGN KEY (Department_ID) REFERENCES Department(Department_ID)
);

-- Employee Roles table
CREATE TABLE EmployeeRoles (
    Employee_ID INT NOT NULL,
    Roles VARCHAR(100) NOT NULL CHECK (Roles IN ('User', 'HR', 'Line-Manager')),

    PRIMARY KEY (Employee_ID),
    CONSTRAINT fk_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);

    
-- Service Provider table
CREATE TABLE ServiceProviders (
    ServiceProvider_ID INT PRIMARY KEY,
    ServiceProviderName VARCHAR(100) NOT NULL,
    ProvisionLevel VARCHAR(100) NOT NULL CHECK (ProvisionLevel IN ('1', '2', '3')),
    ProviderType VARCHAR(100) NOT NULL CHECK (ProviderType IN ('internal', 'external')),
    ServiceProvided VARCHAR(100) NOT NULL
);

-- Role permissions table
CREATE TABLE RolePermissions (
    Employee_ID INT NOT NULL,
    PermissionLevel VARCHAR(100) NOT NULL CHECK (PermissionLevel IN ('User', 'Enhanced', 'Enhanced+')),

    PRIMARY KEY (Employee_ID),
    CONSTRAINT fk_RolePermissions_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID)
);

-- Referral table
CREATE TABLE Referral (
    Referral_ID INT PRIMARY KEY,
    CreatedDate DATE NOT NULL,
    CreatedBy INT NOT NULL, -- employee ID
    Employee_ID INT NOT NULL,
    ServiceProvider_ID INT NOT NULL,
    ReferralDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    SelfReferral NUMBER(1) NOT NULL,
    RequestedService VARCHAR(100) NOT NULL,
    Notes VARCHAR(255),
    Attachment VARCHAR(255),
    Confidentiality NUMBER(1) NOT NULL,
    ReferralStatus VARCHAR(100) NOT NULL CHECK (ReferralStatus IN ('Open', 'Closed', 'In Progress', 'Deferred', 'Cancelled')),
    Emergency NUMBER(1) NOT NULL,
    EthicsOfficer NUMBER(1) NOT NULL,
    ProjectedCost DECIMAL(10, 2) NOT NULL,
    ActualCost DECIMAL(10, 2) NOT NULL,
    HR_Employee NUMBER(1) NOT NULL,
    HR_Notes VARCHAR(255),
    -- Constraints
    CONSTRAINT fk_Referral_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    CONSTRAINT fk_ServiceProvider FOREIGN KEY (ServiceProvider_ID) REFERENCES ServiceProviders(ServiceProvider_ID)
);

/* QUERY: Select queries based on requirements */

-- User view query
SELECT  
    Referral_ID, 
    CreatedDate, 
    creator.EmployeeName AS CreatedBy,
    employee.EmployeeName AS EmployeeName,
    serviceProvider_ID,
    ReferralDate, 
    EndDate, 
    SelfReferral,
    RequestedService,
    -- Only show notes and attachments for open/in-progress referrals
    CASE 
        WHEN 
            ReferralStatus IN ('Open','In Progress') 
        THEN 
            Notes 
        ELSE 
            NULL END AS Notes,
    CASE 
        WHEN 
            ReferralStatus IN ('Open','In Progress') 
        THEN 
            Attachment 
        ELSE 
            NULL END AS Attachment, 
    Confidentiality, 
    ReferralStatus, 
    Emergency, 
    EthicsOfficer, 
    HR_Employee, 
    HR_Notes
    FROM Referral
    
    -- outer joins to get employee names
        JOIN Employee creator ON CreatedBy = creator.Employee_ID
        JOIN Employee employee ON Referral.Employee_ID = employee.Employee_ID
    
    -- Where clauses to filter
        WHERE (SelfReferral = 1 OR (SelfReferral = 0 AND ReferralStatus != 'Closed'))
            AND CreatedDate >= ADD_MONTHS(SYSDATE, -36);



/* Line Manager Requirements*/

-- Line Manager view
SELECT  
    Referral_ID, 
    CreatedDate, 
    creator.EmployeeName AS CreatedBy,
    employee.EmployeeName AS EmployeeName,
    ServiceProvider_ID,
    ReferralDate, 
    EndDate, 
    SelfReferral,
    RequestedService,
    -- Only show notes and attachments for open/in-progress referrals
    CASE 
        WHEN 
            ReferralStatus IN ('Open','In Progress') 
        THEN 
            Notes 
        ELSE 
            NULL END AS Notes,
    CASE 
        WHEN 
            ReferralStatus IN ('Open','In Progress') 
        THEN 
            Attachment 
        ELSE 
            NULL END AS Attachment, 
    Confidentiality, 
    ReferralStatus, 
    Emergency, 
    EthicsOfficer, 
    HR_Employee, 
    HR_Notes
    FROM Referral

    -- outer joins to get employee names
        JOIN Employee creator ON CreatedBy = creator.Employee_ID
        JOIN Employee employee ON Referral.Employee_ID = employee.Employee_ID

    -- Where clauses to filter
        WHERE Referral.Employee_ID IN (SELECT Employee_ID FROM Employee WHERE CurrentLineManager = 'current_employee_id')
            AND (SelfReferral = 1 OR (SelfReferral = 0 AND ReferralStatus != 'Closed'))
            AND CreatedDate >= ADD_MONTHS(SYSDATE, -36);

-- HR view
SELECT  
    Referral_ID, 
    CreatedDate, 
    creator.EmployeeName AS CreatedBy,
    employee.EmployeeName AS EmployeeName,
    ServiceProvider_ID,
    ReferralDate, 
    EndDate, 
    SelfReferral,
    RequestedService,
    -- Only show notes and attachments for open/in-progress referrals
    CASE 
        WHEN 
            ReferralStatus IN ('Open','In Progress') 
        THEN 
            Notes 
        ELSE 
            NULL END AS Notes,
    CASE 
        WHEN   
            ReferralStatus IN ('Open','In Progress') 
        THEN 
            Attachment 
        ELSE 
            NULL END AS Attachment, 
    Confidentiality, 
    ReferralStatus, 
    Emergency, 
    EthicsOfficer, 
    ActualCost,
    ProjectedCost,
    HR_Employee, 
    HR_Notes
    FROM Referral

        -- outer joins to get employee names
        JOIN Employee creator ON CreatedBy = creator.Employee_ID
        JOIN Employee employee ON Referral.Employee_ID = employee.Employee_ID

        -- Where clauses to filter
        WHERE Referral.Employee_ID IN (
            SELECT E.Employee_ID FROM Employee E
            JOIN EmployeeRoles ER ON E.Employee_ID = ER.Employee_ID 
            WHERE ER.Roles = 'HR'
    )
            AND ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
            AND (SelfReferral = 1 OR (SelfReferral = 0 AND ReferralStatus != 'Closed'))
            AND CreatedDate >= ADD_MONTHS(SYSDATE, -36);


/* TEST : Insert Data */

-- Insert into Department
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (1, 'Customer Liaison', 'CustomerLiaison@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (2, 'Finances', 'Finances@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (3, 'Health & Safety', 'Health&Safety@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (4, 'Tech Support', 'TechSupport@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (5, 'Advertising', 'Advertising@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (6, 'IT', 'IT@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (7, 'Public Relations', 'PublicRelations@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (8, 'Research and Development', 'ResearchandDevelopment@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (9, 'Media Relations', 'MediaRelations@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (10, 'Sales and Marketing', 'SalesandMarketing@BAE.com');

-- Insert into Employee
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (1, 'Riley Jordan', 'RJordan@BAE.com', '20407803927', TO_DATE('14-10-2024', 'DD-MM-YYYY'), NULL, 1);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (2, 'Micheal Scott', 'MScott@BAE.com', '32862758319', TO_DATE('02-02-2019', 'DD-MM-YYYY'), 1, 1);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (3, 'James Smith', 'JSmith@BAE.com', '82123182480', TO_DATE('11-10-2024', 'DD-MM-YYYY'), 1, 1);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (4, 'Olivia Carter', 'OCarter@BAE.com', '27437890676', TO_DATE('09-11-2024', 'DD-MM-YYYY'), 1, 1);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (5, 'Mason Blake', 'MBlake@BAE.com', '65029827467', TO_DATE('12-03-2019', 'DD-MM-YYYY'), 1, 1);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (6, 'Ava Thompson', 'AThompson@BAE.com', '36837119855', TO_DATE('05-08-2022', 'DD-MM-YYYY'), NULL, 2);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (7, 'Ethan Ramirez', 'ERamirez@BAE.com', '10793017493', TO_DATE('06-03-2021', 'DD-MM-YYYY'), 6, 2);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (8, 'Sophia Bennett', 'SBennett@BAE.com', '86192961437', TO_DATE('18-09-2023', 'DD-MM-YYYY'), 6, 2);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (9, 'Liam Hayes', 'LHayes@BAE.com', '16689128146', TO_DATE('18-04-2019', 'DD-MM-YYYY'), 6, 2);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (10, 'Isabella Collins', 'ICollins@BAE.com', '12591819410', TO_DATE('17-01-2021', 'DD-MM-YYYY'), 6, 2);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (11, 'Noah Mitchell', 'NMitchell@BAE.com', '10813613394', TO_DATE('10-10-2019', 'DD-MM-YYYY'), NULL, 3);
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) VALUES (12, 'Mia Reynolds', 'MReynolds@BAE.com', '80312194641', TO_DATE('03-05-2024', 'DD-MM-YYYY'), 11, 3);

-- Insert into EmployeeRoles
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (1, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (2, 'HR');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (3, 'Line-Manager');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (4, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (5, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (6, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (7, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (8, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (9, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (10, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (11, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (12, 'User');

-- Insert into ServiceProviders
INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) VALUES (1, 'Health Services', '1', 'internal', 'Medical Checkup');
INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) VALUES (2, 'Mental Health Services', '2', 'internal', 'Counseling');
INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) VALUES (3, 'Fitness Services', '3', 'external', 'Gym Membership');
INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) VALUES (4, 'Nutrition Services', '1', 'internal', 'Diet Consultation');
INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) VALUES (5, 'Wellness Services', '2', 'external', 'Wellness Programs');

-- Insert into RolePermissions
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (1, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (2, 'Enhanced');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (3, 'Enhanced+');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (4, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (5, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (6, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (7, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (8, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (9, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (10, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (11, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (12, 'User');


-- Insert into Referral
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (1, TO_DATE('01-01-2024', 'DD-MM-YYYY'), 1, 2, 1, TO_DATE('02-01-2024', 'DD-MM-YYYY'), TO_DATE('03-01-2024', 'DD-MM-YYYY'), 1, 'Medical Checkup', 'Initial consultation', 'attachment1.pdf', 1, 'Open', 0, 0, 100.00, 50.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (2, TO_DATE('02-01-2024', 'DD-MM-YYYY'), 1, 3, 2, TO_DATE('03-01-2024', 'DD-MM-YYYY'), TO_DATE('04-01-2024', 'DD-MM-YYYY'), 0, 'Counseling', 'Follow-up session', 'attachment2.pdf', 1, 'In Progress', 0, 0, 200.00, 150.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (3, TO_DATE('03-01-2024', 'DD-MM-YYYY'), 1, 4, 3, TO_DATE('04-01-2024', 'DD-MM-YYYY'), TO_DATE('05-01-2024', 'DD-MM-YYYY'), 1, 'Gym Membership', 'Initial consultation', 'attachment3.pdf', 1, 'Closed', 0, 0, 300.00, 250.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (4, TO_DATE('04-01-2024', 'DD-MM-YYYY'), 1, 5, 4, TO_DATE('05-01-2024', 'DD-MM-YYYY'), TO_DATE('06-01-2024', 'DD-MM-YYYY'), 0, 'Diet Consultation', 'Initial consultation', 'attachment4.pdf', 1, 'Deferred', 0, 0, 400.00, 350.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (5, TO_DATE('05-01-2024', 'DD-MM-YYYY'), 1, 6, 5, TO_DATE('06-01-2024', 'DD-MM-YYYY'), TO_DATE('07-01-2024', 'DD-MM-YYYY'), 1, 'Wellness Programs', 'Initial consultation', 'attachment5.pdf', 1, 'Cancelled', 0, 0, 500.00, 450.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (6, TO_DATE('06-01-2024', 'DD-MM-YYYY'), 1, 7, 1, TO_DATE('07-01-2024', 'DD-MM-YYYY'), TO_DATE('08-01-2024', 'DD-MM-YYYY'), 0, 'Medical Checkup', 'Initial consultation', 'attachment6.pdf', 1, 'Open', 0, 0, 600.00, 550.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (7, TO_DATE('07-01-2024', 'DD-MM-YYYY'), 1, 8, 2, TO_DATE('08-01-2024', 'DD-MM-YYYY'), TO_DATE('09-01-2024', 'DD-MM-YYYY'), 1, 'Counseling', 'Initial consultation', 'attachment7.pdf', 1, 'In Progress', 0, 0, 700.00, 650.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (8, TO_DATE('08-01-2024', 'DD-MM-YYYY'), 1, 9, 3, TO_DATE('09-01-2024', 'DD-MM-YYYY'), TO_DATE('10-01-2024', 'DD-MM-YYYY'), 0, 'Gym Membership', 'Initial consultation', 'attachment8.pdf', 1, 'Closed', 0, 0, 800.00, 750.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (9, TO_DATE('09-01-2024', 'DD-MM-YYYY'), 1, 10, 4, TO_DATE('10-01-2024', 'DD-MM-YYYY'), TO_DATE('11-01-2024', 'DD-MM-YYYY'), 1, 'Diet Consultation', 'Initial consultation', 'attachment9.pdf', 1, 'Deferred', 0, 0, 900.00, 850.00, 0, NULL);
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (10, TO_DATE('10-01-2024', 'DD-MM-YYYY'), 1, 11, 5, TO_DATE('11-01-2024', 'DD-MM-YYYY'), TO_DATE('12-01-2024', 'DD-MM-YYYY'), 0, 'Wellness Programs', 'Initial consultation', 'attachment10.pdf', 1, 'Cancelled', 0, 0, 1000.00, 950.00, 0, NULL);




-- commit changes
COMMIT;

-- Drop tables if needed
DROP TABLE Referral;
DROP TABLE RolePermissions;
DROP TABLE EmployeeRoles;
DROP TABLE Employee;
DROP TABLE ServiceProviders;
DROP TABLE Department;


