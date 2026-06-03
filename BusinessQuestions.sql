/*
1. Patient and Appointment Analysis:

What is the average number of appointments per patient in the last 6 months?

*/

USE CST2102_MedDBfinal;
GO

WITH PatientAppointmentCounts AS (
    SELECT 
        p.PatientID,
        p.FirstName,
        p.LastName,
        COUNT(a.AppointmentID) AS AppointmentCount
    FROM Patient p
    LEFT JOIN Appointment a
        ON p.PatientID = a.PatientID
       AND a.AppointmentDate >= DATEADD(MONTH, -6, CAST(GETDATE() AS DATE))
    GROUP BY 
        p.PatientID,
        p.FirstName,
        p.LastName
)
SELECT 
    AVG(CAST(AppointmentCount AS DECIMAL(10,2))) AS AvgAppointmentsPerPatient_Last6Months
FROM PatientAppointmentCounts;
GO

/*
2 -  Doctor Availability and Workload:
Which doctors have the highest patient load?
How does it compare to their average working hours per day?

If you add something like AvgWorkingHoursPerDay to a doctor schedule table later, use that. For now, this first version is acceptable for the assignment since it compares patient load with the doctor’s stored availability field.

*/

USE CST2102_MedDBfinal;
GO

SELECT 
    d.DoctorID,
    d.FirstName,
    d.LastName,
    dep.DepartmentName,
    d.Specialization,
    COUNT(a.AppointmentID) AS TotalAppointments,
    d.Availability AS AvailabilityCodeOrSchedule,
    CAST(COUNT(a.AppointmentID) AS DECIMAL(10,2)) / NULLIF(90.0, 0) AS AvgAppointmentsPerDay_Last90Days
FROM Doctor d
INNER JOIN Department dep
    ON d.DepartmentID = dep.DepartmentID
LEFT JOIN Appointment a
    ON d.DoctorID = a.DoctorID
   AND a.AppointmentDate >= DATEADD(DAY, -90, CAST(GETDATE() AS DATE))
GROUP BY
    d.DoctorID,
    d.FirstName,
    d.LastName,
    dep.DepartmentName,
    d.Specialization,
    d.Availability
ORDER BY TotalAppointments DESC;
GO

/*
3 -  Financial Overview:

What is the total revenue generated from different departments over the past quarter?

*/
USE CST2102_MedDBfinal;
GO

SELECT 
    dep.DepartmentID,
    dep.DepartmentName,
    COUNT(b.BillingID) AS NumberOfBills,
    SUM(b.TotalAmount) AS TotalRevenue,
    AVG(CAST(b.TotalAmount AS DECIMAL(10,2))) AS AvgBillAmount
FROM Billing b
INNER JOIN Appointment a
    ON b.AppointmentID = a.AppointmentID
INNER JOIN Department dep
    ON a.DepartmentID = dep.DepartmentID
WHERE b.PaymentDate >= DATEADD(MONTH, -3, CAST(GETDATE() AS DATE))
  AND b.PaymentStatus = 'Paid'
GROUP BY
    dep.DepartmentID,
    dep.DepartmentName
ORDER BY TotalRevenue DESC;
GO

/*
4 - Prescription Patterns:

Which are the top 5 most prescribed medicines in the last 3 months?

*/
USE CST2102_MedDBfinal;
GO

SELECT TOP 5
    m.MedicineID,
    m.MedicineName,
    m.Manufacturer,
    COUNT(p.PrescriptionID) AS TimesPrescribed
FROM Prescription p
INNER JOIN Medicine m
    ON p.MedicineID = m.MedicineID
INNER JOIN Medical_Record mr
    ON p.RecordID = mr.RecordID
WHERE mr.VisitDate >= DATEADD(MONTH, -3, CAST(GETDATE() AS DATE))
GROUP BY
    m.MedicineID,
    m.MedicineName,
    m.Manufacturer
ORDER BY TimesPrescribed DESC, m.MedicineName ASC;
GO

/*
5 -  Room Utilization:
What percentage of rooms (ICU, General, Private) were occupied in the last month?

*/

USE CST2102_MedDBfinal;
GO

WITH ActiveRoomUse AS (
    SELECT DISTINCT
        r.RoomID,
        r.RoomType
    FROM Room r
    INNER JOIN Room_Assignment ra
        ON r.RoomID = ra.RoomID
    WHERE ra.AdmissionDate <= CAST(GETDATE() AS DATE)
      AND (
            ra.DischargeDate IS NULL
            OR ra.DischargeDate >= DATEADD(MONTH, -1, CAST(GETDATE() AS DATE))
          )
),
RoomTotals AS (
    SELECT
        RoomType,
        COUNT(*) AS TotalRooms
    FROM Room
    WHERE RoomType IN ('ICU', 'General', 'Private')
    GROUP BY RoomType
),
OccupiedTotals AS (
    SELECT
        RoomType,
        COUNT(*) AS OccupiedRooms
    FROM ActiveRoomUse
    WHERE RoomType IN ('ICU', 'General', 'Private')
    GROUP BY RoomType
)
SELECT
    rt.RoomType,
    rt.TotalRooms,
    ISNULL(ot.OccupiedRooms, 0) AS OccupiedRooms,
    CAST(ISNULL(ot.OccupiedRooms, 0) * 100.0 / NULLIF(rt.TotalRooms, 0) AS DECIMAL(5,2)) AS OccupancyPercent
FROM RoomTotals rt
LEFT JOIN OccupiedTotals ot
    ON rt.RoomType = ot.RoomType
ORDER BY rt.RoomType;
GO