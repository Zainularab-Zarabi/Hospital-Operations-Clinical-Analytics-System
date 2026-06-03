-- =========================================
-- Hospital Database Schema
-- Physical ERD Implementation
-- SQL Server / T-SQL
-- =========================================

-- Optional: create database first
-- CREATE DATABASE HospitalDB;
-- GO
-- USE HospitalDB;
-- GO

-- =========================================
-- 1. Parent / Reference Tables
-- =========================================
CREATE DATABASE CST2102_MedDBfinal;
GO
USE CST2102_MedDBfinal;
GO


CREATE TABLE Department (
    DepartmentID INT PRIMARY KEY,
    DepartmentName VARCHAR(100) NOT NULL,
    Location VARCHAR(100) NOT NULL,
    PhoneExtension VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE Patient (
    PatientID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender VARCHAR(20) NOT NULL,
    Address VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(100) UNIQUE,
    EmergencyContactName VARCHAR(100) NOT NULL,
    EmergencyContactPhone VARCHAR(20) NOT NULL,
    CONSTRAINT CK_Patient_DateOfBirth CHECK (DateOfBirth < CAST(GETDATE() AS DATE)),
    CONSTRAINT CK_Patient_Gender CHECK (Gender IN ('Male', 'Female'))
);

CREATE TABLE Medicine (
    MedicineID INT PRIMARY KEY,
    MedicineName VARCHAR(100) NOT NULL,
    Manufacturer VARCHAR(100) NOT NULL,
    StockQuantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    CONSTRAINT CK_Medicine_StockQuantity CHECK (StockQuantity >= 0),
    CONSTRAINT CK_Medicine_Price CHECK (Price >= 0)
);

CREATE TABLE Doctor (
    DoctorID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Specialization VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    Availability VARCHAR(100),
    CONSTRAINT FK_Doctor_Department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Staff (
    StaffID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(50) NOT NULL,
    DepartmentID INT NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL UNIQUE,
    Email VARCHAR(100) NOT NULL UNIQUE,
    ShiftHours VARCHAR(50),
    CONSTRAINT FK_Staff_Department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID)
);

CREATE TABLE Room (
    RoomID INT PRIMARY KEY,
    RoomNumber VARCHAR(20) NOT NULL UNIQUE,
    DepartmentID INT NOT NULL,
    RoomType VARCHAR(50) NOT NULL,
    AvailabilityStatus VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Room_Department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT CK_Room_RoomType CHECK (RoomType IN ('General', 'Private', 'ICU', 'Treatment', 'Exam')),
    CONSTRAINT CK_Room_AvailabilityStatus CHECK (AvailabilityStatus IN ('Available', 'Occupied', 'Maintenance'))
);

-- =========================================
-- 2. Core Transaction Table
-- =========================================

CREATE TABLE Appointment (
    AppointmentID INT PRIMARY KEY,
    PatientID INT NOT NULL,
    DoctorID INT NOT NULL,
    DepartmentID INT NOT NULL,
    AppointmentDate DATE NOT NULL,
    AppointmentTime TIME NOT NULL,
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT FK_Appointment_Patient
        FOREIGN KEY (PatientID) REFERENCES Patient(PatientID),
    CONSTRAINT FK_Appointment_Doctor
        FOREIGN KEY (DoctorID) REFERENCES Doctor(DoctorID),
    CONSTRAINT FK_Appointment_Department
        FOREIGN KEY (DepartmentID) REFERENCES Department(DepartmentID),
    CONSTRAINT CK_Appointment_Status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled')),
    CONSTRAINT UQ_Appointment_DoctorSlot UNIQUE (DoctorID, AppointmentDate, AppointmentTime),
    CONSTRAINT UQ_Appointment_PatientSlot UNIQUE (PatientID, AppointmentDate, AppointmentTime)
);

-- =========================================
-- 3. Appointment-Dependent Tables
-- =========================================

CREATE TABLE Medical_Record (
    RecordID INT PRIMARY KEY,
    AppointmentID INT NOT NULL UNIQUE,
    VisitDate DATE NOT NULL,
    Diagnosis VARCHAR(255) NOT NULL,
    TreatmentPlan VARCHAR(500),
    Prescription VARCHAR(500),
    CONSTRAINT FK_MedicalRecord_Appointment
        FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID)
);

CREATE TABLE Billing (
    BillingID INT PRIMARY KEY,
    AppointmentID INT NOT NULL UNIQUE,
    TotalAmount DECIMAL(10,2) NOT NULL,
    PaymentStatus VARCHAR(20) NOT NULL,
    PaymentDate DATE NULL,
    PaymentMethod VARCHAR(50) NULL,
    CONSTRAINT FK_Billing_Appointment
        FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID),
    CONSTRAINT CK_Billing_TotalAmount CHECK (TotalAmount >= 0),
    CONSTRAINT CK_Billing_PaymentStatus CHECK (PaymentStatus IN ('Paid', 'Unpaid', 'Pending')),
    CONSTRAINT CK_Billing_PaymentMethod CHECK (
        PaymentMethod IS NULL
        OR PaymentMethod IN ('Cash', 'Credit Card', 'Debit Card', 'Insurance', 'Online')
    )
);

CREATE TABLE Room_Assignment (
    AssignmentID INT PRIMARY KEY,
    RoomID INT NOT NULL,
    AppointmentID INT NOT NULL,
    AdmissionDate DATETIME NOT NULL,
    DischargeDate DATETIME NULL,
    CONSTRAINT FK_RoomAssignment_Room
        FOREIGN KEY (RoomID) REFERENCES Room(RoomID),
    CONSTRAINT FK_RoomAssignment_Appointment
        FOREIGN KEY (AppointmentID) REFERENCES Appointment(AppointmentID),
    CONSTRAINT CK_RoomAssignment_DateOrder CHECK (
        DischargeDate IS NULL OR DischargeDate > AdmissionDate
    ),
    CONSTRAINT UQ_RoomAssignment_Appointment UNIQUE (AppointmentID)
);

-- =========================================
-- 4. Medical Record Dependent Tables
-- =========================================

CREATE TABLE Prescription (
    PrescriptionID INT PRIMARY KEY,
    RecordID INT NOT NULL,
    MedicineID INT NOT NULL,
    Dosage VARCHAR(50) NOT NULL,
    Frequency VARCHAR(50) NOT NULL,
    Duration VARCHAR(50) NOT NULL,
    CONSTRAINT FK_Prescription_MedicalRecord
        FOREIGN KEY (RecordID) REFERENCES Medical_Record(RecordID),
    CONSTRAINT FK_Prescription_Medicine
        FOREIGN KEY (MedicineID) REFERENCES Medicine(MedicineID)
);