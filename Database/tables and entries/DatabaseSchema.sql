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
    ReferralStatus VARCHAR(100) NOT NULL CHECK (ReferralStatus IN ('Open', 'Closed', 'In Progress')),
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