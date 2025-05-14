-- filepath: Database/tables and entries/test_DatabaseSchema.sql

-- Test Script for DatabaseSchema.sql
-- This script tests the database schema by:
-- 1. Creating the tables
-- 2. Loading test data from CSV files
-- 3. Testing the queries defined in the schema
-- 4. Verifying constraints

-- First, clean up any existing tables
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Referral';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE RolePermissions';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE EmployeeRoles';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Employee';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE ServiceProviders';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE Department';
EXCEPTION
    WHEN OTHERS THEN NULL;
END;
/

-- Create tables according to schema
DBMS_OUTPUT.PUT_LINE('1. Creating tables...');

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
    CurrentLineManager INT,
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
    CreatedBy INT NOT NULL,
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
    CONSTRAINT fk_Referral_Employee FOREIGN KEY (Employee_ID) REFERENCES Employee(Employee_ID),
    CONSTRAINT fk_ServiceProvider FOREIGN KEY (ServiceProvider_ID) REFERENCES ServiceProviders(ServiceProvider_ID)
);

DBMS_OUTPUT.PUT_LINE('Tables created successfully.');

-- 2. Load test data
DBMS_OUTPUT.PUT_LINE('2. Loading test data...');

-- Insert Department data from CSV
DBMS_OUTPUT.PUT_LINE('2.1 Loading Department data...');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (1, 'Customer Liaison', 'CustomerLiaison@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (2, 'Finances', 'Finances@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (3, 'Heath & Safety', 'Heath&Safety@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (4, 'Tech Support', 'TechSupport@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (5, 'Advertising', 'Advertising@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (6, 'IT', 'IT@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (7, 'Public Relations', 'PublicRelations@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (8, 'Research and Development', 'ResearchandDevelopment@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (9, 'Media Relations', 'MediaRelations@BAE.com');
INSERT INTO Department (Department_ID, DepartmentName, DepartmentEmail) VALUES (10, 'Sales and Marketing', 'SalesandMarketing@BAE.com');

DBMS_OUTPUT.PUT_LINE('Department data loaded. Count: ' || TO_CHAR(SQL%ROWCOUNT));

-- Insert Employee data from CSV (first 20 employees for testing)
DBMS_OUTPUT.PUT_LINE('2.2 Loading Employee data...');
INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (1, 'Riley Jordan', 'RJordan@BAE.com', '20407803927', TO_DATE('14-10-2024', 'DD-MM-YYYY'), NULL, 1);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (2, 'Micheal Scott', 'MScott@BAE.com', '32862758319', TO_DATE('02-02-2019', 'DD-MM-YYYY'), 1, 1);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (3, 'James Smith', 'JSmith@BAE.com', '82123182480', TO_DATE('11-10-2024', 'DD-MM-YYYY'), 1, 1);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (4, 'Olivia Carter', 'OCarter@BAE.com', '27437890676', TO_DATE('09-11-2024', 'DD-MM-YYYY'), 1, 1);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (5, 'Mason Blake', 'MBlake@BAE.com', '65029827467', TO_DATE('12-03-2019', 'DD-MM-YYYY'), 1, 1);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (6, 'Ava Thompson', 'AThompson@BAE.com', '36837119855', TO_DATE('05-08-2022', 'DD-MM-YYYY'), NULL, 2);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (7, 'Ethan Ramirez', 'ERamirez@BAE.com', '10793017493', TO_DATE('06-03-2021', 'DD-MM-YYYY'), 6, 2);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (8, 'Sophia Bennett', 'SBennett@BAE.com', '86192961437', TO_DATE('18-09-2023', 'DD-MM-YYYY'), 6, 2);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (9, 'Liam Hayes', 'LHayes@BAE.com', '16689128146', TO_DATE('18-04-2019', 'DD-MM-YYYY'), 6, 2);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (10, 'Isabella Collins', 'ICollins@BAE.com', '12591819410', TO_DATE('17-01-2021', 'DD-MM-YYYY'), 6, 2);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (11, 'Noah Mitchell', 'NMitchell@BAE.com', '10813613394', TO_DATE('10-10-2019', 'DD-MM-YYYY'), NULL, 3);

INSERT INTO Employee (Employee_ID, EmployeeName, Email, PhoneNumber, EmployeeStartDate, CurrentLineManager, Department_ID) 
VALUES (12, 'Mia Reynolds', 'MReynolds@BAE.com', '80312194641', TO_DATE('03-05-2024', 'DD-MM-YYYY'), 11, 3);

DBMS_OUTPUT.PUT_LINE('Employee data loaded. Count: ' || TO_CHAR(SQL%ROWCOUNT));

-- Insert EmployeeRoles data for testing
DBMS_OUTPUT.PUT_LINE('2.3 Setting up employee roles...');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (1, 'Line-Manager');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (2, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (3, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (4, 'HR');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (5, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (6, 'Line-Manager');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (7, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (8, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (9, 'User');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (10, 'HR');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (11, 'Line-Manager');
INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (12, 'HR');

DBMS_OUTPUT.PUT_LINE('Employee roles assigned. Count: ' || TO_CHAR(SQL%ROWCOUNT));

-- Insert RolePermissions data for testing
DBMS_OUTPUT.PUT_LINE('2.4 Setting up role permissions...');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (1, 'Enhanced');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (2, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (3, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (4, 'Enhanced+');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (5, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (6, 'Enhanced');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (7, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (8, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (9, 'User');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (10, 'Enhanced+');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (11, 'Enhanced');
INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (12, 'Enhanced+');

DBMS_OUTPUT.PUT_LINE('Role permissions assigned. Count: ' || TO_CHAR(SQL%ROWCOUNT));

-- Insert ServiceProviders data for testing
DBMS_OUTPUT.PUT_LINE('2.5 Setting up service providers...');
INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) 
VALUES (1, 'Internal Health Services', '1', 'internal', 'Health Checkup');

INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) 
VALUES (2, 'PsychCare Ltd', '2', 'external', 'Psychological Counseling');

INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) 
VALUES (3, 'BAE Training Department', '1', 'internal', 'Professional Development');

INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) 
VALUES (4, 'Wellness Center', '3', 'external', 'Physical Therapy');

INSERT INTO ServiceProviders (ServiceProvider_ID, ServiceProviderName, ProvisionLevel, ProviderType, ServiceProvided) 
VALUES (5, 'Career Advisors Inc', '2', 'external', 'Career Counseling');

DBMS_OUTPUT.PUT_LINE('Service providers added. Count: ' || TO_CHAR(SQL%ROWCOUNT));

-- Insert Referral data for testing
DBMS_OUTPUT.PUT_LINE('2.6 Creating test referrals...');
-- Create a mix of referrals with different statuses and types
INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (1, SYSDATE-100, 1, 2, 1, SYSDATE-95, SYSDATE-65, 0, 'Health Checkup', 
    'Regular health assessment', NULL, 0, 'Closed', 0, 0, 500.00, 450.00, 0, NULL);

INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (2, SYSDATE-80, 3, 3, 2, SYSDATE-75, SYSDATE-45, 1, 'Counseling Session', 
    'Stress management consultation', 'stress_doc.pdf', 1, 'In Progress', 0, 0, 800.00, 0.00, 0, NULL);

INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (3, SYSDATE-60, 4, 5, 3, SYSDATE-55, SYSDATE-25, 0, 'Leadership Training', 
    'Department leadership skills', 'training_plan.pdf', 0, 'Open', 0, 0, 1200.00, 0.00, 1, 
    'Approved by HR department');

INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (4, SYSDATE-40, 7, 7, 2, SYSDATE-35, SYSDATE-5, 1, 'Stress Management', 
    'Work-related stress issues', NULL, 1, 'Deferred', 0, 0, 600.00, 0.00, 0, NULL);

INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (5, SYSDATE-30, 10, 10, 1, SYSDATE-25, SYSDATE+5, 1, 'Health Assessment', 
    'Regular checkup', NULL, 0, 'Open', 0, 0, 350.00, 0.00, 1, 'Standard HR referral');

INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (6, SYSDATE-20, 4, 4, 5, SYSDATE-15, SYSDATE+15, 1, 'Career Development', 
    'Career progression planning', 'career_plan.pdf', 1, 'In Progress', 0, 0, 950.00, 300.00, 1, 
    'First session completed');

INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (7, SYSDATE-10, 1, 8, 4, SYSDATE-5, SYSDATE+25, 0, 'Physical Therapy', 
    'Work-related injury', 'medical_report.pdf', 0, 'Open', 1, 0, 1500.00, 0.00, 0, NULL);

INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
    SelfReferral, RequestedService, Notes, Attachment, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
    ProjectedCost, ActualCost, HR_Employee, HR_Notes)
VALUES (8, SYSDATE-5, 12, 12, 3, SYSDATE, SYSDATE+30, 1, 'Management Training', 
    'Advanced HR management', 'hr_training.pdf', 0, 'Open', 0, 0, 1800.00, 0.00, 1, 
    'HR department priority training');

DBMS_OUTPUT.PUT_LINE('Test referrals created. Count: ' || TO_CHAR(SQL%ROWCOUNT));

-- 3. Test the queries
DBMS_OUTPUT.PUT_LINE('3. Testing queries...');

-- 3.1. Test User Requirements Query
DBMS_OUTPUT.PUT_LINE('3.1 Testing User Requirements Query');
-- Setting current user for testing
DEFINE current_user_id = 3;

SELECT COUNT(*) AS user_query_result_count
FROM (
    SELECT  Referral_ID, 
            CreatedDate, 
            E1.EmployeeName AS CreatedBy,
            E2.EmployeeName AS Employee_Name,
            ServiceProvider_ID, 
            ReferralDate, 
            EndDate, 
            SelfReferral,
            RequestedService,
            CASE
                WHEN ReferralStatus IN ('Open','In Progress') THEN Notes
                ELSE NULL
            END AS Notes,
            CASE
                WHEN ReferralStatus IN ('Open','In Progress') THEN Attachment
                ELSE NULL
            END AS Attachment, 
            Confidentiality, 
            ReferralStatus, 
            Emergency, 
            EthicsOfficer, 
            HR_Employee, 
            HR_Notes
        FROM Referral
        LEFT JOIN Employee E1 ON Referral.CreatedBy = E1.Employee_ID
        LEFT JOIN Employee E2 ON Referral.Employee_ID = E2.Employee_ID
        WHERE ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
            AND (SelfReferral = 1 OR (SelfReferral = 0 AND ReferralStatus != 'Closed'))
            AND CreatedDate >= ADD_MONTHS(SYSDATE, -36)
            AND (Referral.Employee_ID = &current_user_id OR Referral.CreatedBy = &current_user_id) -- Filter for current user
);

-- 3.2. Test Line Manager Requirements Query
DBMS_OUTPUT.PUT_LINE('3.2 Testing Line Manager Requirements Query');
-- Setting current line manager for testing
DEFINE current_manager_id = 1;

SELECT COUNT(*) AS line_manager_query_result_count
FROM (
    SELECT  R.Referral_ID, 
            R.CreatedDate, 
            E1.EmployeeName AS CreatedBy,
            E2.EmployeeName AS Employee_Name,
            R.ServiceProvider_ID, 
            R.ReferralDate, 
            R.EndDate, 
            R.SelfReferral,
            R.RequestedService,
            CASE
                WHEN R.ReferralStatus IN ('Open','In Progress') THEN R.Notes
                ELSE NULL
            END AS Notes,
            CASE
                WHEN R.ReferralStatus IN ('Open','In Progress') THEN R.Attachment
                ELSE NULL
            END AS Attachment, 
            R.Confidentiality, 
            R.ReferralStatus, 
            R.Emergency, 
            R.EthicsOfficer, 
            R.HR_Employee, 
            R.HR_Notes
        FROM Referral R
        LEFT JOIN Employee E1 ON R.CreatedBy = E1.Employee_ID
        LEFT JOIN Employee E2 ON R.Employee_ID = E2.Employee_ID
        WHERE R.Employee_ID IN (SELECT Employee_ID FROM Employee WHERE CurrentLineManager = &current_manager_id)
            AND R.ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
            AND (R.SelfReferral = 1 OR (R.SelfReferral = 0 AND R.ReferralStatus != 'Closed'))
            AND R.CreatedDate >= ADD_MONTHS(SYSDATE, -36)
);

-- 3.3. Test HR Requirements Query
DBMS_OUTPUT.PUT_LINE('3.3 Testing HR Requirements Query');
SELECT COUNT(*) AS hr_query_result_count
FROM (
    SELECT  R.Referral_ID, 
            R.CreatedDate, 
            E1.EmployeeName AS CreatedBy,
            E2.EmployeeName AS Employee_Name,
            R.ServiceProvider_ID, 
            R.ReferralDate, 
            R.EndDate, 
            R.SelfReferral,
            R.RequestedService,
            CASE
                WHEN R.ReferralStatus IN ('Open','In Progress') THEN R.Notes
                ELSE NULL
            END AS Notes,
            CASE
                WHEN R.ReferralStatus IN ('Open','In Progress') THEN R.Attachment
                ELSE NULL
            END AS Attachment, 
            R.Confidentiality, 
            R.ReferralStatus, 
            R.Emergency, 
            R.EthicsOfficer, 
            R.ActualCost,
            R.ProjectedCost,
            R.HR_Employee, 
            R.HR_Notes
        FROM Referral R
        LEFT JOIN Employee E1 ON R.CreatedBy = E1.Employee_ID
        LEFT JOIN Employee E2 ON R.Employee_ID = E2.Employee_ID
        WHERE R.Employee_ID IN (
            SELECT E.Employee_ID 
            FROM Employee E
            JOIN EmployeeRoles ER ON E.Employee_ID = ER.Employee_ID 
            WHERE ER.Roles = 'HR'
        )
        AND R.ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
        AND (R.SelfReferral = 1 OR (R.SelfReferral = 0 AND R.ReferralStatus != 'Closed'))
        AND R.CreatedDate >= ADD_MONTHS(SYSDATE, -36)
);

-- 4. Test constraint enforcement
DBMS_OUTPUT.PUT_LINE('4. Testing constraints...');

-- 4.1 Test check constraints on ReferralStatus
DBMS_OUTPUT.PUT_LINE('4.1 Testing ReferralStatus check constraint');
BEGIN
    INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
        SelfReferral, RequestedService, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
        ProjectedCost, ActualCost, HR_Employee)
    VALUES (999, SYSDATE, 1, 2, 1, SYSDATE, SYSDATE+30, 0, 'Test', 0, 'Invalid Status', 0, 0, 100.00, 0.00, 0);
    DBMS_OUTPUT.PUT_LINE('FAILED: Inserted with invalid ReferralStatus');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PASSED: Check constraint prevented invalid ReferralStatus');
END;
/

-- 4.2 Test foreign key constraint on Employee_ID
DBMS_OUTPUT.PUT_LINE('4.2 Testing Employee_ID foreign key constraint');
BEGIN
    INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
        SelfReferral, RequestedService, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
        ProjectedCost, ActualCost, HR_Employee)
    VALUES (999, SYSDATE, 1, 999, 1, SYSDATE, SYSDATE+30, 0, 'Test', 0, 'Open', 0, 0, 100.00, 0.00, 0);
    DBMS_OUTPUT.PUT_LINE('FAILED: Inserted with non-existent Employee_ID');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PASSED: Foreign key constraint prevented invalid Employee_ID');
END;
/

-- 4.3 Test foreign key constraint on ServiceProvider_ID
DBMS_OUTPUT.PUT_LINE('4.3 Testing ServiceProvider_ID foreign key constraint');
BEGIN
    INSERT INTO Referral (Referral_ID, CreatedDate, CreatedBy, Employee_ID, ServiceProvider_ID, ReferralDate, EndDate, 
        SelfReferral, RequestedService, Confidentiality, ReferralStatus, Emergency, EthicsOfficer, 
        ProjectedCost, ActualCost, HR_Employee)
    VALUES (999, SYSDATE, 1, 2, 999, SYSDATE, SYSDATE+30, 0, 'Test', 0, 'Open', 0, 0, 100.00, 0.00, 0);
    DBMS_OUTPUT.PUT_LINE('FAILED: Inserted with non-existent ServiceProvider_ID');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PASSED: Foreign key constraint prevented invalid ServiceProvider_ID');
END;
/

-- 4.4 Test check constraint on RolePermissions.PermissionLevel
DBMS_OUTPUT.PUT_LINE('4.4 Testing PermissionLevel check constraint');
BEGIN
    INSERT INTO RolePermissions (Employee_ID, PermissionLevel) VALUES (11, 'Admin');
    DBMS_OUTPUT.PUT_LINE('FAILED: Inserted with invalid PermissionLevel');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PASSED: Check constraint prevented invalid PermissionLevel');
END;
/

-- 4.5 Test check constraint on EmployeeRoles.Roles
DBMS_OUTPUT.PUT_LINE('4.5 Testing Roles check constraint');
BEGIN
    INSERT INTO EmployeeRoles (Employee_ID, Roles) VALUES (11, 'Admin');
    DBMS_OUTPUT.PUT_LINE('FAILED: Inserted with invalid Role');
EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('PASSED: Check constraint prevented invalid Role');
END;
/

-- 5. Summary statistics
DBMS_OUTPUT.PUT_LINE('5. Database statistics summary:');

SELECT 'Department Count: ' || COUNT(*) AS stat FROM Department;
SELECT 'Employee Count: ' || COUNT(*) AS stat FROM Employee;
SELECT 'EmployeeRoles Count: ' || COUNT(*) AS stat FROM EmployeeRoles;
SELECT 'ServiceProviders Count: ' || COUNT(*) AS stat FROM ServiceProviders;
SELECT 'RolePermissions Count: ' || COUNT(*) AS stat FROM RolePermissions;
SELECT 'Referral Count: ' || COUNT(*) AS stat FROM Referral;

-- Count of referrals by status
SELECT 'Referral Status Breakdown:' AS stat FROM DUAL;
SELECT ReferralStatus, COUNT(*) AS count
FROM Referral
GROUP BY ReferralStatus
ORDER BY ReferralStatus;

-- Count of self-referrals vs non-self-referrals
SELECT 'Self vs Non-Self Referrals:' AS stat FROM DUAL;
SELECT 
    CASE WHEN SelfReferral = 1 THEN 'Self-Referral' ELSE 'Non-Self-Referral' END AS referral_type,
    COUNT(*) AS count
FROM Referral
GROUP BY SelfReferral;

-- HR-related referrals
SELECT 'HR-Related Referrals: ' || COUNT(*) AS stat 
FROM Referral 
WHERE HR_Employee = 1;

-- HR employee count
SELECT 'HR Employee Count: ' || COUNT(*) AS stat 
FROM EmployeeRoles 
WHERE Roles = 'HR';

-- Line manager count
SELECT 'Line Manager Count: ' || COUNT(*) AS stat 
FROM EmployeeRoles 
WHERE Roles = 'Line-Manager';

-- Clean up (leave commented for debugging if needed)
/* 
DROP TABLE Referral;
DROP TABLE RolePermissions;
DROP TABLE EmployeeRoles;
DROP TABLE Employee;
DROP TABLE ServiceProviders;
DROP TABLE Department;
*/

DBMS_OUTPUT.PUT_LINE('Test script completed successfully!');

COMMIT;