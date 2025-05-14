/** Creation of the database schema */


-- Employee table
CREATE TABLE EMPLOYEES (
    Employee_ID INT PRIMARY KEY,
    EmployeeName VARCHAR(100),
    Roles VARCHAR(15) NOT NULL CHECK (Roles IN ('HR', 'Line-Manager', 'User')),
    Email VARCHAR(100) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    EmployeeStartDate DATE NOT NULL,
    CurrentLineManager VARCHAR(100),
    Department_ID INT NOT NULL,

    CONSTRAINT checking_CurrentLineManager CHECK (
        (Roles = 'User' AND CurrentLineManager IS NOT NULL) OR
        (Roles IN ('HR', 'Line-Manager') AND CurrentLineManager IS NULL))
    
);

-- Permissions table
CREATE TABLE RolePermissions (
    Roles VARCHAR(15) NOT NULL CHECK (Roles IN ('HR', 'Line-Manager', 'User')),
    PermissionLevel VARCHAR(100) NOT NULL CHECK (PermissionLevel IN ('user', 'enhanced','enhanced+','admin')),
    canCreateReferral BOOLEAN NOT NULL,
    canViewReferral BOOLEAN NOT NULL,
    canUpdateReferral BOOLEAN NOT NULL,
    canDeleteReferral BOOLEAN NOT NULL,
    canAssignReferral BOOLEAN NOT NULL,
    canApproveReferral BOOLEAN NOT NULL,
    canRecordReferral BOOLEAN NOT NULL
    
)
-- Service Provider table
CREATE TABLE ServiceProviders (
    ServiceProvider_ID INT PRIMARY KEY,
    ServiceProviderName VARCHAR(100) NOT NULL,
    ProvisionLevel VARCHAR(100) NOT NULL CHECK (ProvisionLevel IN ('1', '2', '3')),
    ProviderType VARCHAR(100) NOT NULL CHECK (ProviderType IN ('internal', 'external')),
    ServiceProvided VARCHAR(100) NOT NULL
);

-- Referral table
CREATE TABLE Referrals (
    Referral_ID INT PRIMARY KEY,
    Employee_ID INT NOT NULL,
    HR_Employee_ID INT NOT NULL,
    ServiceProvider_ID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    Self_Referred VARCHAR(100) NOT NULL CHECK (Self_Referred IN ('non-selfReferral', 'self-referral')),
    RequestedServices VARCHAR(100), -- restricted by type and level of service and shows service provided
    UserNotes VARCHAR(100) NOT NULL,
    Attachments BLOB,
    ProjectedCost DECIMAL(10, 2) NOT NULL,
    ActualCost DECIMAL(10, 2) NOT NULL,
    Status VARCHAR(100) NOT NULL CHECK (Status IN ('open', 'closed', 'in-progress')),
    Confidentiality BOOLEAN NOT NULL,
    Emergency BOOLEAN NOT NULL,
    EthicsOfficerRequest BOOLEAN NOT NULL,
    HR_Notes VARCHAR(100) NOT NULL,
    
    CONSTRAINT fk_Employee FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    CONSTRAINT fk_HR_Employee FOREIGN KEY (HR_Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    CONSTRAINT fk_ServiceProvider FOREIGN KEY (ServiceProvider_ID) REFERENCES ServiceProviders(ServiceProvider_ID)
);

/* Link Table */
-- avoids many-to-many relationships


-- employee - department link table
CREATE TABLE EmployeeDepartment_Link (
    Employee_ID INT NOT NULL,
    Department_ID INT NOT NULL,
    PRIMARY KEY (Employee_ID, Department_ID),
    FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    FOREIGN KEY (Department_ID) REFERENCES Departments(Department_ID)
);

CREATE TABLE EmployeeReferral_Link (
    Employee_ID INT NOT NULL,
    Referral_ID INT NOT NULL,
    RoleInReferral VARCHAR(50) NOT NULL CHECK (RoleInReferral IN ('User', 'HR')),
    PRIMARY KEY (Employee_ID, Referral_ID),
    FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    FOREIGN KEY (Referral_ID) REFERENCES Referrals(Referral_ID)
);

CREATE TABLE EmployeeRolePermissions_Link (
    Employee_ID INT NOT NULL,
    Roles VARCHAR(15) NOT NULL,
    PRIMARY KEY (Employee_ID, Roles),
    FOREIGN KEY (Employee_ID) REFERENCES EMPLOYEES(Employee_ID),
    FOREIGN KEY (Roles) REFERENCES RolePermissions(Roles)
);

-- 
