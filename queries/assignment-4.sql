-- Task 01

select
c.Code as Code,
UPPER(c.Title) as Course,
d.Name as Department,
c.CreditHours as CreditHours,
    c.Price AS Price
from [academic].[Courses] as c
inner join [academic].[Departments] as d
	on d.Id = c.DepartmentId
where c.IsActive = 1
ORDER BY Price DESC, Code ASC


-- Task 02

select
d.Code as DeptCode,
d.Name as Department,
c.Code as CourseCode,
CASE 
    WHEN c.Title IS NULL THEN 'No Courses Available' 
    ELSE c.Title 
END as Course
--ISNULL(c.Title, 'No Courses Available') as Course
from [academic].[Departments] as d
left join [academic].[Courses] as c
	on d.Id = c.DepartmentId
ORDER BY d.Name ASC, Course ASC;


-- Task 03

select
std.StudentNumber as StudentNo,
CONCAT(u.FirstName ,' ' , u.LastName) as FullName,
u.Email as Email,
ISNULL(u.PhoneNumber, 'Not Provided') as Phone,
std.AdmissionDate as Admitted,
DATEDIFF(day, AdmissionDate, GETUTCDATE()) as DaysSinceAdmission,
std.CurrentGpa as GPA
from [identity].[StudentProfiles] as std
inner join [identity].[Users] as u
	 on u.Id = std.UserId
order by AdmissionDate DESC ,std.StudentNumber asc



-- Task 04

SELECT 
    c.Code AS Code,
    c.Title AS Course,
    c.CreditHours AS CreditHours,
    c.Price AS Price
FROM [academic].[Courses] AS c
WHERE c.IsActive = 1
  AND NOT EXISTS (
      SELECT 1 
      FROM [content].[CourseModules] AS m 
      WHERE m.CourseId = c.Id
  )
ORDER BY c.CreditHours DESC, c.Title ASC;

-- Task 05

select
std.StudentNumber as StudentNo,
inv.InvoiceNumber as Invoice,
inv.TotalAmount as Total,
inv.PaidAmount as Paid,
(inv.TotalAmount - inv.PaidAmount) as Remaining ,
inv.DueAtUtc as DueUtc,
DATEDIFF(day, GETUTCDATE(), inv.DueAtUtc)AS DaysUntilDue
from [identity].[StudentProfiles] as std
inner join [finance].[Invoices] as inv
	ON inv.StudentId = std.Id
WHERE (inv.TotalAmount - inv.PaidAmount) > 0
order by Remaining DESC , Invoice asc


-- Task 06

select 
    i.InvoiceNumber as Invoice,
    i.TotalAmount as InvoiceTotal,
    ISNULL(p.Amount, 0.00) as Payment,
    p.PaidAtUtc as PaidAtUtc,
    case 
        when p.Id IS NOT NULL then 'Payment Recorded'
        else 'No Qualifying Payment'
    end AS Status
from [finance].[Invoices] as i
LEFT JOIN [finance].[Payments] as p
    ON p.InvoiceId = i.Id 
   AND p.Amount >= 500
ORDER BY i.InvoiceNumber ASC, p.PaidAtUtc DESC;


-- Task 07

SELECT 
    c.Title AS Course,
    CONCAT(c.Code, '-', s.SectionCode) AS Section,
    t.Name AS Term,
    s.Capacity AS Seats,
    DATEDIFF(day, t.StartDate, t.EndDate) AS TermLengthDays
FROM [delivery].[Sections] AS s
INNER JOIN [academic].[Courses] AS c
    ON s.CourseId = c.Id
INNER JOIN [delivery].[AcademicTerms] AS t
    ON s.TermId = t.Id
WHERE c.IsActive = 1
ORDER BY t.StartDate DESC, Section ASC;


-- Task 08
SELECT 
    sp.StudentNumber AS StudentNo,
    CONCAT(u.FirstName, ' ', u.LastName) AS FullName,
    s.SectionCode AS Section,
    e.EnrolledAtUtc AS EnrolledAtUtc,
    e.FinalScore AS FinalScore,
    ISNULL(e.FinalGrade, 'Pending') AS Grade
FROM [delivery].[Enrollments] AS e
INNER JOIN [identity].[StudentProfiles] AS sp
    ON e.StudentId = sp.Id
INNER JOIN [identity].[Users] AS u
    ON sp.UserId = u.Id
INNER JOIN [delivery].[Sections] AS s
    ON e.SectionId = s.Id
ORDER BY e.FinalScore DESC, sp.StudentNumber ASC;


-- Task 09

SELECT 
    c.Title AS Course,
    m.Title AS Module,
    l.Title AS Lesson,
    ISNULL(l.EstimatedMinutes, 0) AS Minutes,
    CASE 
        WHEN m.Id IS NULL THEN 'Module Missing'
        WHEN l.Id IS NULL THEN 'Lesson Missing'
        WHEN l.IsPublished = 0 THEN 'Draft'
        WHEN l.IsPublished = 1 THEN 'Ready'
    END AS Status
FROM [academic].[Courses] AS c
LEFT JOIN [content].[CourseModules] AS m
    ON m.CourseId = c.Id
LEFT JOIN [content].[Lessons] AS l
    ON l.ModuleId = m.Id
ORDER BY c.Title ASC, m.SortOrder ASC, l.SortOrder ASC;


-- Task 10

SELECT 
    ip.EmployeeNumber AS EmployeeNo,
    CONCAT(u.FirstName, ' ', u.LastName) AS Instructor,
    ip.AcademicTitle AS Title,
    c.Title AS Course,
    s.SectionCode AS Section,
    DATEDIFF(month, ip.HireDate, GETUTCDATE()) AS MonthsOfService,

    CASE 
        WHEN si.IsPrimary = 1 THEN 'Lead Instructor'
        ELSE 'Supporting Instructor'
    END AS Responsibility

FROM [identity].[InstructorProfiles] AS ip
INNER JOIN [identity].[Users] AS u
    ON ip.UserId = u.Id
INNER JOIN [delivery].[SectionInstructors] AS si
    ON si.InstructorId = ip.Id
INNER JOIN [delivery].[Sections] AS s
    ON si.SectionId = s.Id
INNER JOIN [academic].[Courses] AS c
    ON s.CourseId = c.Id
ORDER BY ip.HireDate ASC, Instructor ASC;


-- Task 11

SELECT 
    sp.StudentNumber AS StudentNo,
    CONCAT(u.FirstName, ' ', u.LastName) AS Name,
    c.Code AS Code,
    c.Title AS Course,
    s.SectionCode AS Section,
    c.PassingScore AS PassMark,
    e.FinalScore AS Score,
    (e.FinalScore - c.PassingScore) AS Difference,
    CASE 
        WHEN e.FinalScore IS NULL THEN 'Pending'
        WHEN e.FinalScore >= c.PassingScore THEN 'Passed'
        ELSE 'Failed'
    END AS Result
FROM [delivery].[Enrollments] AS e
INNER JOIN [identity].[StudentProfiles] AS sp
    ON e.StudentId = sp.Id
INNER JOIN [identity].[Users] AS u
    ON sp.UserId = u.Id
INNER JOIN [delivery].[Sections] AS s
    ON e.SectionId = s.Id
INNER JOIN [academic].[Courses] AS c
    ON s.CourseId = c.Id
ORDER BY c.Title ASC, e.FinalScore DESC;


-- Task 12

SELECT 
    c.Title AS Course,
    s.SectionCode AS Section,
    s.Capacity AS Capacity,
    COUNT(e.Id) AS SeatsTaken,
    (s.Capacity - COUNT(e.Id)) AS SeatsLeft,
    ROUND((COUNT(e.Id) * 100.0) / NULLIF(s.Capacity, 0), 2) AS OccupancyPercent
FROM [delivery].[Sections] AS s
INNER JOIN [academic].[Courses] AS c
    ON s.CourseId = c.Id
INNER JOIN [delivery].[Enrollments] AS e
    ON e.SectionId = s.Id
INNER JOIN [ref].[EnrollmentStatuses] AS es
    ON e.EnrollmentStatusId = es.Id
WHERE es.CountsTowardCapacity = 1
  AND c.IsActive = 1
GROUP BY c.Title, s.SectionCode, s.Capacity
HAVING COUNT(e.Id) >= 20
ORDER BY OccupancyPercent DESC, s.SectionCode ASC;


-- Task 13

SELECT 
    c.Code AS Code,
    c.Title AS Course,
    COUNT(e.FinalScore) AS Graded,
    MAX(e.FinalScore) AS Highest,
    MIN(e.FinalScore) AS Lowest,
    ROUND(AVG(e.FinalScore), 2) AS Average,
    SUM(CASE WHEN e.FinalScore >= c.PassingScore THEN 1 ELSE 0 END) AS Passed,
    SUM(CASE WHEN e.FinalScore < c.PassingScore THEN 1 ELSE 0 END) AS Failed
FROM [delivery].[Enrollments] AS e
INNER JOIN [delivery].[Sections] AS s
    ON e.SectionId = s.Id
INNER JOIN [academic].[Courses] AS c
    ON s.CourseId = c.Id
WHERE e.FinalScore IS NOT NULL
  AND c.IsActive = 1
GROUP BY c.Code, c.Title
HAVING COUNT(e.FinalScore) >= 10
   AND AVG(e.FinalScore) >= 85
ORDER BY Average DESC, c.Code ASC;


-- Task 14

SELECT 
    YEAR(e.EnrolledAtUtc) AS Year,
    MONTH(e.EnrolledAtUtc) AS MonthNumber,
    DATENAME(month, e.EnrolledAtUtc) AS Month,
    COUNT(e.Id) AS Enrollments,
    COUNT(DISTINCT e.StudentId) AS Students,
    COUNT(DISTINCT s.CourseId) AS Courses
FROM [delivery].[Enrollments] AS e
INNER JOIN [delivery].[Sections] AS s
    ON e.SectionId = s.Id
WHERE YEAR(e.EnrolledAtUtc) = YEAR(GETUTCDATE())
GROUP BY YEAR(e.EnrolledAtUtc),
MONTH(e.EnrolledAtUtc), 
DATENAME(month, e.EnrolledAtUtc)
HAVING COUNT(e.Id) >= 20
ORDER BY Year ASC, MonthNumber ASC;


-- Task 15
SELECT 
    c.Code AS Code,
    c.Title AS Title,
    c.Price AS Price
FROM [academic].[Courses] AS c
WHERE c.IsActive = 1
  AND c.Price > (
      SELECT AVG(Price) 
      FROM [academic].[Courses] 
      WHERE IsActive = 1
  )
ORDER BY c.Price DESC, c.Code ASC;


-- Task 16

SELECT 
    c.Code AS Code,
    c.Title AS Course,
    c.CreditHours AS CreditHours,
    c.Price AS Price
FROM [academic].[Courses] AS c
WHERE c.IsActive = 1
  AND c.CreditHours IN (
      SELECT TOP 2 CreditHours 
      FROM [academic].[Courses] 
      WHERE IsActive = 1 
      GROUP BY CreditHours 
      ORDER BY CreditHours DESC
  )
ORDER BY c.CreditHours DESC, c.Price DESC, c.Code ASC;


-- Task 17

SELECT 
    c.Code AS Code,
    c.Title AS Course,
    c.CreditHours AS CreditHours,
    c.Price AS Price
FROM [academic].[Courses] AS c
WHERE c.IsActive = 1
  AND c.Price = (
      SELECT MAX(Price)
      FROM [academic].[Courses]
      WHERE IsActive = 1
        AND Price < (
            SELECT MAX(Price)
            FROM [academic].[Courses]
            WHERE IsActive = 1
        )
  )
ORDER BY c.Title ASC, c.CreditHours DESC, c.Code ASC;

-- Task 18

SELECT 
    UPPER(d.Name) AS Department,
    c.Code AS Code,
    c.Title AS Course,
    c.Price AS Price
FROM [academic].[Courses] AS c
INNER JOIN [academic].[Departments] AS d
    ON c.DepartmentId = d.Id
WHERE c.IsActive = 1
  AND NOT EXISTS (
      SELECT 1 
      FROM [academic].[Courses] AS other
      WHERE other.DepartmentId = c.DepartmentId
        AND other.IsActive = 1
        AND other.Price > c.Price
  )
ORDER BY d.Name ASC, c.Title ASC, c.Code ASC;

-- Task 19

SELECT 
    d.Name AS Department,
    COUNT(CourseAverages.CourseId) AS GradedCourses,
    ROUND(AVG(CourseAverages.CourseAvg), 2) AS DepartmentAverage
FROM [academic].[Departments] AS d
INNER JOIN (
    SELECT 
        c.DepartmentId,
        c.Id AS CourseId,
        AVG(e.FinalScore) AS CourseAvg
    FROM [academic].[Courses] AS c
    INNER JOIN [delivery].[Sections] AS s
        ON s.CourseId = c.Id
    INNER JOIN [delivery].[Enrollments] AS e
        ON e.SectionId = s.Id
    WHERE e.FinalScore IS NOT NULL
    GROUP BY c.DepartmentId, c.Id
) AS CourseAverages
    ON CourseAverages.DepartmentId = d.Id
GROUP BY d.Name
ORDER BY DepartmentAverage DESC, d.Name ASC;


-- Task 20

SET STATISTICS IO ON;
SET STATISTICS TIME ON;

-- Developer A
SELECT DISTINCT
    s.Id,
    s.StudentNumber
FROM [identity].StudentProfiles AS s
INNER JOIN [delivery].Enrollments AS e
    ON e.StudentId = s.Id
ORDER BY s.StudentNumber, s.Id;

-- Developer B
SELECT
    s.Id,
    s.StudentNumber
FROM [identity].StudentProfiles AS s
WHERE EXISTS
(
    SELECT 1
    FROM [delivery].Enrollments AS e
    WHERE e.StudentId = s.Id
)
ORDER BY s.StudentNumber, s.Id;

SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;

SELECT TOP 10
    c.Code,
    c.Title,
    c.CreditHours,
    (
        SELECT AVG(ii.UnitPrice)
        FROM finance.InvoiceItems ii
        WHERE ii.Description = 'Line fee'
    ) AS AvgLineFee
FROM academic.Courses c;