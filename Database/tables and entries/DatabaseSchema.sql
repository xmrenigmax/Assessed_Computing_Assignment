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

/* Select queries based on requirements */

/* User Requirements
1. Self-referral can be confidential or not. non-self referrals are not confidential.
2. Can view status of own referrals.
3. Can raise query against any active referrals (if involved)
4. Can view all referrals raised by them up to 3 years back.
5. Can close self-referrals but not non-self referrals.
6. Can view open notes and attachments.
7. information viewed by user = 
    - Referral ID
    - Created Date
    - Created By
    - Employee ID
    - Service Provider ID
    - Referral Date
    - End Date
    - Self Referral
    - Requested Service
    - Notes
    - Attachment
    - Confidentiality
    - Referral Status
    - Emergency
    - Ethics Officer
    - HR Employee
    - HR Notes

*/



-- redesign of combination 1-7 
SELECT  Referral_ID, 
        CreatedDate, 
        E1.EmployeeName AS CreatedBy,
        E2.EmployeeName AS Employee_ID,
        ServiceProvider_ID, 
        ReferralDate, 
        EndDate, 
        SelfReferral,
        RequestedService,
        -- Conditions based on status 
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

    -- outer joins to get employee names
    LEFT JOIN Employee E1 ON Referral.CreatedBy = E1.Employee_ID
    LEFT JOIN Employee E2 ON Referral.Employee_ID = E2.EmployeeName


    -- Where clauses to filter
    WHERE ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
        AND (SelfReferral = 1 OR (SelfReferral = 0 AND ReferralStatus != 'Closed'))
        AND CreatedDate >= ADD_MONTHS(SYSDATE, -36);



/* Line Manager Requirements 
1. view staff members who have them as a current line manager
2. Can add notes to own referrals, and subordinates (if any)
3. Can view all referrals raised by them up to 3 years back.
4. run Reportss relating to their department:
6. Self-referral can be confidential or not. non-self referrals are not confidential.
7. view status of own referrals. (can close self-referrals but not non-self referrals)
8. view open notes and attachments not closed
*/

-- combination of 1-8
SELECT  R.Referral_ID, 
        R.CreatedDate, 
        E1.EmployeeName AS CreatedBy,
        E2.EmployeeName AS Employee_ID,
        R.ServiceProvider_ID, 
        R.ReferralDate, 
        R.EndDate, 
        R.SelfReferral,
        R.RequestedService,
        -- Conditions based on status 
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

    -- outer joins to get employee names
    LEFT JOIN Employee E1 ON R.CreatedBy = E1.Employee_ID
    LEFT JOIN Employee E2 ON R.Employee_ID = E2.Employee_ID

    -- Where clauses to filter
    WHERE R.Employee_ID IN (SELECT Employee_ID FROM Employee WHERE CurrentLineManager = 'current_employee_id')
        AND R.ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
        AND (R.SelfReferral = 1 OR (R.SelfReferral = 0 AND R.ReferralStatus != 'Closed'))
        AND R.CreatedDate >= ADD_MONTHS(SYSDATE, -36);


/* HR Requirements 
1. can change confidentiality status of referrals done by line managers and HR
*/

SELECT  R.Referral_ID, 
        R.CreatedDate, 
        E1.EmployeeName AS CreatedBy,
        E2.EmployeeName AS Employee_ID,
        R.ServiceProvider_ID, 
        R.ReferralDate, 
        R.EndDate, 
        R.SelfReferral,
        R.RequestedService,
        -- Conditions based on status 
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

    -- outer joins to get employee names
    LEFT JOIN Employee E1 ON R.CreatedBy = E1.Employee_ID
    LEFT JOIN Employee E2 ON R.Employee_ID = E2.Employee_ID

    -- Where clauses to filter
    WHERE R.Employee_ID IN (
    SELECT E.Employee_ID 
    FROM Employee E
    JOIN EmployeeRoles ER ON E.Employee_ID = ER.Employee_ID 
    WHERE ER.Roles = 'HR'
)
        AND R.ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
        AND (R.SelfReferral = 1 OR (R.SelfReferral = 0 AND R.ReferralStatus != 'Closed'))
        AND R.CreatedDate >= ADD_MONTHS(SYSDATE, -36);


-- Drop tables if needed
DROP TABLE Referral;
DROP TABLE RolePermissions;
DROP TABLE EmployeeRoles;
DROP TABLE Employee;
DROP TABLE ServiceProviders;
DROP TABLE Department;

-- commit changes
