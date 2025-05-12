/*creation for the database schema*/

/* Creation of database */
CREATE DATABASE BaeOccupationalHealthReferralSystem;
USE BaeOccupationalHealthReferralSystem;

/* Creation of tables */

-- Department table
CREATE TABLE Department (
    DepartmentID INT Primary KEY AUTO_INCREMENT,
    DepartmentName VARCHAR(100) NOT NULL,
    DepartmentEmail VARCHAR(100) NOT NULL,
);

-- LineManager table
CREATE TABLE LineManager (
    LineManagerID INT Primary KEY AUTO_INCREMENT,
    LineManagerName VARCHAR(100) NOT NULL,
    LineManagerEmail VARCHAR(100) NOT NULL,
    DepartmentID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

-- User table
CREATE TABLE User (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    UserName VARCHAR(100) NOT NULL,
    UserEmail VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    DepartmentID INT,
    LineManagerID INT,
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (LineManagerID) REFERENCES LineManager(LineManagerID)
);

-- Service Provider Table ( a should have? )

CREATE TABLE ServiceProvider (
    ServiceProviderID INT PRIMARY KEY AUTO_INCREMENT,
    ServiceProviderName VARCHAR(100) NOT NULL,
    ServiceProviderType ENUM('Internal', 'External') NOT NULL,
    ServicesProvided TEXT,
    provisionLevel INT CHECK (provisionLevel >= 1 AND provisionLevel <= 3),
);

-- Referral type table
CREATE TABLE ReferralType (
    ReferralTypeID INT PRIMARY KEY AUTO_INCREMENT,
    ReferralTypeName VARCHAR(100) NOT NULL,
    Description TEXT
);

-- User Role table
CREATE TABLE UserRole (
    RoleID INT PRIMARY KEY AUTO_INCREMENT,
    RoleName VARCHAR(50) NOT NULL,
    Description TEXT,
    CanCreate BOOLEAN DEFAULT FALSE,
    CanRead BOOLEAN DEFAULT TRUE,
    CanUpdate BOOLEAN DEFAULT FALSE,
    CanDelete BOOLEAN DEFAULT FALSE,
    CanApprove BOOLEAN DEFAULT FALSE,
    CanAssign BOOLEAN DEFAULT FALSE
);

-- Referral Status table
CREATE TABLE ReferralStatus (
    StatusID INT PRIMARY KEY AUTO_INCREMENT,
    StatusName VARCHAR(50) NOT NULL,
    Description TEXT
);

-- Referral Table (main entity for referral system)
CREATE TABLE Referral (
    ReferralID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL,
    DepartmentID INT NOT NULL,
    LineManagerID INT NOT NULL,
    ProviderID INT NOT NULL,
    TypeID INT NOT NULL,
    StatusID INT NOT NULL,
    Confidential BOOLEAN DEFAULT FALSE,
    DateRaised DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    DateCompleted DATETIME,
    Description TEXT NOT NULL,
    BudgetQuote DECIMAL(10,2),
    ActualCost DECIMAL(10,2),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    FOREIGN KEY (LineManagerID) REFERENCES LineManager(ManagerID),
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID),
    FOREIGN KEY (TypeID) REFERENCES ReferralType(TypeID),
    FOREIGN KEY (StatusID) REFERENCES ReferralStatus(StatusID)
);

-- ReferralNote table
CREATE TABLE ReferralNote (
    NoteID INT PRIMARY KEY AUTO_INCREMENT,
    ReferralID INT NOT NULL,
    EmployeeID INT NOT NULL,
    NoteDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    NoteText TEXT NOT NULL,
    Visibility ENUM('Open', 'Closed') DEFAULT 'Open',
    FOREIGN KEY (ReferralID) REFERENCES Referral(ReferralID),
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID)
);

-- Attachment table
CREATE TABLE Attachment (
    AttachmentID INT PRIMARY KEY AUTO_INCREMENT,
    ReferralID INT NOT NULL,
    FileName VARCHAR(255) NOT NULL,
    FileType VARCHAR(50),
    FileSize INT,
    UploadDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    FilePath VARCHAR(255) NOT NULL,
    FOREIGN KEY (ReferralID) REFERENCES Referral(ReferralID)
);

-- Report table
CREATE TABLE Report (
    ReportID INT PRIMARY KEY AUTO_INCREMENT,
    ReportName VARCHAR(100) NOT NULL,
    Description TEXT,
    DateGenerated DATETIME DEFAULT CURRENT_TIMESTAMP,
    GeneratedBy INT NOT NULL,
    Parameters TEXT,
    FOREIGN KEY (GeneratedBy) REFERENCES Employee(EmployeeID)
);

-- UserAccess table (for login and permissions)
CREATE TABLE UserAccess (
    UserID INT PRIMARY KEY AUTO_INCREMENT,
    EmployeeID INT NOT NULL UNIQUE,
    Username VARCHAR(50) NOT NULL UNIQUE,
    PasswordHash VARCHAR(255) NOT NULL,
    RoleID INT NOT NULL,
    MFAEnabled BOOLEAN DEFAULT FALSE,
    LastLogin DATETIME,
    FOREIGN KEY (EmployeeID) REFERENCES Employee(EmployeeID),
    FOREIGN KEY (RoleID) REFERENCES UserRole(RoleID)
);


/* Link tables for many-to-many relationships */


-- Permissions
CREATE TABLE Permission (
    PermissionID INT PRIMARY KEY AUTO_INCREMENT,
    PermissionName VARCHAR(50)
);

CREATE TABLE RolePermission (
    RoleID INT,
    PermissionID INT,
    PRIMARY KEY (RoleID, PermissionID),
    FOREIGN KEY (RoleID) REFERENCES UserRole(RoleID),
    FOREIGN KEY (PermissionID) REFERENCES Permission(PermissionID)
);

-- Referral and Service Provider
CREATE TABLE ReferralProvider (
    ReferralID INT,
    ProviderID INT,
    PRIMARY KEY (ReferralID, ProviderID),
    FOREIGN KEY (ReferralID) REFERENCES Referral(ReferralID),
    FOREIGN KEY (ProviderID) REFERENCES ServiceProvider(ProviderID)
);

