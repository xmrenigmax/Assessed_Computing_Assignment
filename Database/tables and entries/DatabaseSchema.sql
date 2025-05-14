/** Creation of the database schema */


-- Department table
CREATE TABLE Department (
    Department_ID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentEmail VARCHAR(100) NOT NULL
);

-- Employee table
CREATE TABLE EMPLOYEES (
    Employee_ID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Email VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    EmployeeStartDate DATE NOT NULL,
    CurrentLineManager VARCHAR(100),
    Department_ID INT NOT NULL
);

-- Employee Roles table
CREATE TABLE EmployeeRoles (
    Employee_ID INT NOT NULL,
    Roles VARCHAR(100) NOT NULL CHECK (Roles IN ('User', 'HR', 'Line-Manager')),

    PRIMARY KEY (Employee_ID),
    CONSTRAINT fk_Employee FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID)
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
    CONSTRAINT fk_Employee FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID)
);

-- Referral table
CREATE TABLE Referral (
    Referral_ID INT PRIMARY KEY,
    CreatedDate DATE NOT NULL,
    CreatedBy VARCHAR(100) NOT NULL, -- employee ID
    Employee_ID INT NOT NULL,
    ServiceProvider_ID INT NOT NULL,

    ReferralDate DATE NOT NULL,
    EndDate DATE NOT NULL,

    SelfReferral BOOLEAN NOT NULL,
    RequestedService VARCHAR(100) NOT NULL,
    Notes VARCHAR(255),
    Attachment VARCHAR(255),
    Confidentiality BOOLEAN NOT NULL,
    ReferralStatus VARCHAR(100) NOT NULL CHECK (ReferralStatus IN ('Open', 'Closed', 'In Progress', 'Deferred', 'Cancelled')),
    Emergency BOOLEAN NOT NULL,
    EthicsOfficer BOOLEAN NOT NULL,

    ProjectedCost DECIMAL(10, 2) NOT NULL,
    ActualCost DECIMAL(10, 2) NOT NULL,
    HR_Employee BOOLEAN NOT NULL,
    HR_Notes VARCHAR(255),

    PRIMARY KEY (Referral_ID),
    CONSTRAINT fk_Employee FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
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
        CreatedBy, 
        Employee_ID, 
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
WHERE Employee_ID = 'current_employee_id'
  AND ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
  AND (SelfReferral = TRUE OR (SelfReferral = FALSE AND ReferralStatus != 'Closed'))
  AND CreatedDate >= DATEADD(YEAR, -3, GETDATE());



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
SELECT  Referral_ID, 
        CreatedDate, 
        CreatedBy, 
        Employee_ID, 
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
WHERE Employee_ID IN (SELECT Employee_ID FROM EMPLOYEES WHERE CurrentLineManager = 'current_employee_id')
  AND ReferralStatus IN ('Open', 'In Progress', 'Closed', 'Deferred', 'Cancelled')
  AND (SelfReferral = TRUE OR (SelfReferral = FALSE AND ReferralStatus != 'Closed'))
  AND CreatedDate >= DATEADD(YEAR, -3, GETDATE());
