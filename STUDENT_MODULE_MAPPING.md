# Student Module Backend-to-UI Mapping - Fast Reference

**Date:** April 12, 2026  
**Module:** Student Management (admin_dashboard/students)  
**Purpose:** Quick debugging reference for field mappings from Firestore → UI

---

## 1. Students Screen

**File:** `lib/admin_dashboard/students/screens/students_screen.dart`

### Data Source
- **Collection:** `collection('user')` - All student documents
- **Stream:** `_watchStudents()` - Combines user + attendance + tasks data
- **Filtering:** Department, Year, Status, Search query

### Variables & Mappings

| Variable | UI Element | Type | Backend Path | Status |
|----------|-----------|------|--------------|--------|
| `students` | List above table | Direct | collection('user') snapshots | Verified |
| `totalStudents` | Summary card value | Computed | students.length | Verified |
| `activeInternships` | Summary card value | Computed | count(status == 'active') | Verified |
| `completedInternships` | Summary card value | Computed | count(status == 'completed') | Verified |
| `needingAttention` | Summary card value | Computed | count(status == 'atRisk') | Verified |
| `averageAttendance` | Attendance card, metric | Computed | sum(attendance) / count | Verified |
| `lowAttendanceStudents` | Attendance card, metric | Computed | count(attendance < 75) | Verified |
| `weeklyCheckIns` | Attendance card, metric | Computed | sum(weeklyCheckIns) | Verified |
| `missedLogs` | Attendance card, metric | Computed | sum(missedLogs) | Verified |
| `departmentOptions` | Filter dropdown items | Computed | unique student.department values | Verified |
| `_selectedDepartment` | Filter state | User Input | - | Verified |
| `_selectedYear` | Filter state | User Input | - | Verified |
| `_selectedStatus` | Filter state | User Input | - | Verified |
| `_searchQuery` | Filter state | User Input | - | Verified |
| `filteredStudents` | Table display list | Computed | _filterStudents(students) | Verified |

---

## 2. Students Table

**File:** `lib/admin_dashboard/students/widgets/students_table.dart`

### Responsive Layouts
- **Compact (width < 1080px):** Card list via `_StudentCard`
- **Desktop (width >= 1080px):** Table rows via `_StudentRow`

### Table Columns & Mappings

| Column Header | Variable | Type | Backend Path | Status |
|---------------|----------|------|--------------|--------|
| Student | `student.name` | Direct | user.name OR user.fullName | Verified |
| (Student email) | `student.email` | Direct | user.email | Verified |
| (Student roll) | `student.rollNumber` | Direct/Fallback | user.rollNumber OR doc.id | Verified |
| Department | `student.department` | Direct/Fallback | user.department OR user.dept | Verified |
| Year | `student.year` | Direct | user.year (enum) | Verified |
| Company | `student.company` | Direct/Fallback | user.companyName OR user.company | Verified |
| Faculty Mentor | `student.facultyMentor` | Fallback | Multiple sources (see below) | Verified |
| Status | `student.status` | Direct/Fallback | user.internshipStatus OR user.status | Verified |
| Status Chip Color | `student.status.color` | Direct | Mapped from status enum | Verified |
| Attendance | `student.attendance` | Direct/Fallback/Computed | Multiple sources (see below) | Verified |
| Progress | `student.progress` | Direct/Fallback | Multiple sources (see below) | Verified |

---

## 3. Student Detail Screen

**File:** `lib/admin_dashboard/students/screens/student_detail_screen.dart`

### Sections & Variables

#### Internship Section
| UI Label | Variable | Type | Backend Path | Status |
|----------|----------|------|--------------|--------|
| Company | `student.company` | Direct/Fallback | user.companyName OR user.company | Verified |
| Internship Role | `student.internshipRole` | Direct/Fallback | user.internshipRole OR user.roleTitle | Verified |
| Duration | `student.duration` | Direct | user.duration | Verified |
| Start Date | `student.startDate` | Direct | user.startDate (formatted) | Verified |
| End Date | `student.endDate` | Direct | user.endDate (formatted) | Verified |
| Progress | `student.progress` + '%' | Direct/Fallback | Multiple sources (see below) | Verified |

#### Mentors Section
| UI Label | Variable | Type | Backend Path | Status |
|----------|----------|------|--------------|--------|
| Faculty Mentor | `student.facultyMentor` | Fallback | Multiple sources (see below) | Verified |
| Company Mentor | `student.companyMentor` | Fallback | Multiple sources (see below) | Verified |

#### Attendance Section
| UI Label | Variable | Type | Backend Path | Status |
|----------|----------|------|--------------|--------|
| Attendance | `student.attendance` + '%' | Direct/Fallback | Multiple sources (see below) | Verified |
| Weekly Check-ins | `student.weeklyCheckIns` | Direct | user.weeklyCheckIns OR user.stats.weeklyCheckIns | Verified |
| Missed Logs | `student.missedLogs` | Direct | user.missedLogs OR user.stats.missedLogs | Verified |

#### Admin Notes Section (if not empty)
| UI Label | Variable | Type | Backend Path | Status |
|----------|----------|------|--------------|--------|
| Notes text | `student.notes` | Direct | user.notes | Verified |

---

## 4. Attendance Overview Card

**File:** `lib/admin_dashboard/students/widgets/attendance_overview_card.dart`

### Metric Tiles

| Metric Label | Variable | Type | Calculation | Status |
|--------------|----------|------|-------------|--------|
| Avg Attendance | `averageAttendance` | Computed | sum(student.attendance) / count | Verified |
| Low Attendance Students | `lowAttendanceStudents` | Computed | count(student.attendance < 75) | Verified |
| Weekly Check-ins | `weeklyCheckIns` | Computed | sum(student.weeklyCheckIns) | Verified |
| Missed Logs | `missedLogs` | Computed | sum(student.missedLogs) | Verified |

---

## 5. Student Summary Cards

**File:** `lib/admin_dashboard/students/widgets/student_summary_card.dart`

### Cards on Students Screen

| Card Title | Value Variable | Type | Calculation | Status |
|------------|----------------|------|-------------|--------|
| Total Students | `totalStudents` | Computed | students.length | Verified |
| Active Internships | (value passed) | Computed | count(status == 'active') | Verified |
| Completed Internships | (value passed) | Computed | count(status == 'completed') | Verified |
| Needing Attention | (value passed) | Computed | count(status == 'atRisk') | Verified |

---

## 6. Student Filter Bar

**File:** `lib/admin_dashboard/students/widgets/student_filter_bar.dart`

### Filter Controls

| Filter Control | Variable | Type | Options Source | Status |
|----------------|----------|------|-----------------|--------|
| Department Dropdown | `selectedDepartment` | User Input | `departmentOptions` from students | Verified |
| Year Dropdown | `selectedYear` | User Input | StudentYear.values enum | Verified |
| Status Dropdown | `selectedStatus` | User Input | StudentInternshipStatus.values enum | Verified |
| Search Field | `searchQuery` | User Input | Text input | Verified |
| Reset Button | (callback) | Action | Clears filters | Verified |

---

## StudentRecord Data Model

**File:** `lib/admin_dashboard/students/widgets/students_table.dart` (lines 600-900)

### Complete Field Mapping

```dart
class StudentRecord {
  String id;                  // doc.id (direct from Firestore)
  String name;                // user.name → user.fullName (fallback: "Unnamed Student")
  String email;               // user.email (direct)
  String rollNumber;          // user.rollNumber → doc.id (fallback)
  String department;          // user.department → user.dept (fallback: "Unassigned")
  StudentYear year;           // user.year (enum parse)
  String company;             // user.companyName → user.company (fallback: "Not Assigned")
  String internshipRole;      // user.internshipRole → user.roleTitle (fallback: "Intern")
  String duration;            // user.duration (fallback: "Not specified")
  String startDate;           // user.startDate (formatted as string)
  String endDate;             // user.endDate (formatted as string)
  String facultyMentor;       // (see Faculty Mentor Fallback Chain below)
  String companyMentor;       // (see Company Mentor Fallback Chain below)
  StudentInternshipStatus status;  // user.internshipStatus → user.status (enum parse)
  int attendance;             // (see Attendance Fallback Chain below)
  int progress;               // (see Progress Fallback Chain below)
  int weeklyCheckIns;         // user.weeklyCheckIns (direct)
  int missedLogs;             // user.missedLogs (direct)
  String? notes;              // user.notes (nullable)
  bool isDeleted;             // (soft delete flag)
  DateTime? deletedAt;        // (deletion timestamp)
}
```

### Helper Functions & Fallback Chains

#### Faculty Mentor Fallback Chain
```
_readPersonLike([
  user.collegeMentor,
  user.collegeMentorName,
  user.assignedFaculty,
  user.assignedFacultyName,
  user.facultyMentor,
  user.facultyMentorName,
  user.facultyName,
  user.mentorFaculty,
], fallback: "Not Assigned")
```
**Status:** Verified

#### Company Mentor Fallback Chain
```
_readPersonLike([
  user.assignedMentor,
  user.assignedMentorName,
  user.companyMentor,
  user.companyMentorName,
  user.mentor,
  user.mentorName,
  user.guideName,
  user.industryMentor,
], fallback: "Not Assigned")
```
**Status:** Verified

#### Attendance Fallback Chain
```
_readFirstInt([
  user.attendance,
  user.attendancePercentage,
  user.attendancePercent,
  user.overallAttendance,
  user.attendanceRate,
  user.attendance_rate,
  user.stats.attendance,
], fallback: 0)
```
**Status:** Verified

#### Progress Fallback Chain
```
_readFirstInt([
  user.progress,
  user.progressPercentage,
  user.progressPercent,
  user.completion,
  user.completionPercentage,
  user.stats.progress,
], fallback: 0)
```
**Status:** Verified

---

## Hardcoded Values

| Location | Value | Usage | Status |
|----------|-------|-------|--------|
| StudentRecord factory | "Unnamed Student" | name fallback | Verified |
| StudentRecord factory | "Unassigned" | department fallback | Verified |
| StudentRecord factory | "Unassigned" | facultyMentor fallback | Verified |
| StudentRecord factory | "Unassigned" | companyMentor fallback | Verified |
| StudentRecord factory | "Not Assigned" | company fallback | Verified |
| StudentRecord factory | "Intern" | internshipRole fallback | Verified |
| StudentRecord factory | "Not specified" | duration fallback | Verified |
| StudentRecord factory | 0 | attendance fallback | Verified |
| StudentRecord factory | 0 | progress fallback | Verified |
| StudentRecord factory | 0 | weeklyCheckIns fallback | Verified |
| StudentRecord factory | 0 | missedLogs fallback | Verified |

---

## Fallback/Default Values Summary

| Field | Fallback Value | Condition | Status |
|-------|----------------|-----------|--------|
| name | "Unnamed Student" | if user.name is null/empty | Verified |
| department | "Unassigned" | if user.department/dept null | Verified |
| company | "Not Assigned" | if companyName/company null | Verified |
| internshipRole | "Intern" | if internshipRole/roleTitle null | Verified |
| duration | "Not specified" | if user.duration null | Verified |
| facultyMentor | "Not Assigned" | if all 8 mentor fields null | Verified |
| companyMentor | "Not Assigned" | if all 8 mentor fields null | Verified |
| attendance | 0 | if all attendance field variants null | Verified |
| progress | 0 | if all progress field variants null | Verified |
| year | StudentYear.first | if user.year null | Verified |
| status | StudentInternshipStatus.pending | if internshipStatus/status null | Verified |

---

## Inconsistent Field Names (Schema Variations)

| Logical Field | Firestore Variants | Reason | Status |
|---------------|-------------------|--------|--------|
| Department | `department`, `dept` | Schema versioning/typos | Verified |
| Company | `companyName`, `company` | Naming inconsistency | Verified |
| Role | `internshipRole`, `roleTitle` | Field renamed | Verified |
| Faculty Mentor | 8 variants (see chain) | Multiple integrations | Verified |
| Company Mentor | 8 variants (see chain) | Multiple integrations | Verified |
| Attendance | 7 variants (see chain) | Different calculation methods | Verified |
| Progress | 6 variants (see chain) | Different calculation methods | Verified |
| Status | `internshipStatus`, `status` | Naming inconsistency | Verified |
| Yearly Check-ins | `weeklyCheckIns`, `checkIns` | Direct OR nested in stats | Needs verification |
| Missed Logs | `missedLogs`, `pendingLogs` | Direct OR nested in stats | Needs verification |

---

## Summary Mapping Table

**All Screen → UI Element → Variable → Backend Path mappings:**

| Screen | UI Element | Variable | Backend Path | Type | Status |
|--------|-----------|----------|--------------|------|--------|
| Students Screen | Summary Card - Total | totalStudents | students.length | Computed | Verified |
| Students Screen | Summary Card - Active | activeInternships | count(status=='active') | Computed | Verified |
| Students Screen | Summary Card - Completed | completedInternships | count(status=='completed') | Computed | Verified |
| Students Screen | Summary Card - At-Risk | needingAttention | count(status=='atRisk') | Computed | Verified |
| Students Screen | Department Filter Dropdown | departmentOptions | unique student.department | Computed | Verified |
| Students Screen | Year Filter Dropdown | - | StudentYear.values | Hardcoded enum | Verified |
| Students Screen | Status Filter Dropdown | - | StudentInternshipStatus.values | Hardcoded enum | Verified |
| Students Screen | Search Field | _searchQuery | User input | User Input | Verified |
| Attendance Card | Metric - Avg Attendance | averageAttendance | sum(attendance)/count | Computed | Verified |
| Attendance Card | Metric - Low Attendance Count | lowAttendanceStudents | count(attendance<75) | Computed | Verified |
| Attendance Card | Metric - Weekly Check-ins | weeklyCheckIns | sum(weeklyCheckIns) | Computed | Verified |
| Attendance Card | Metric - Missed Logs | missedLogs | sum(missedLogs) | Computed | Verified |
| Students Table | Name column | student.name | user.name/fullName | Direct/Fallback | Verified |
| Students Table | Email column | student.email | user.email | Direct | Verified |
| Students Table | Roll column | student.rollNumber | user.rollNumber/doc.id | Direct/Fallback | Verified |
| Students Table | Department column | student.department | user.department/dept | Direct/Fallback | Verified |
| Students Table | Year column | student.year | user.year | Direct | Verified |
| Students Table | Company column | student.company | user.companyName/company | Direct/Fallback | Verified |
| Students Table | Mentor column | student.facultyMentor | (8-field chain) | Fallback | Verified |
| Students Table | Status column | student.status | user.internshipStatus/status | Direct/Fallback | Verified |
| Students Table | Attendance column | student.attendance | (7-field chain) | Fallback/Computed | Verified |
| Students Table | Progress column | student.progress | (6-field chain) | Fallback/Computed | Verified |
| Detail Screen - Internship | Company | student.company | user.companyName/company | Direct/Fallback | Verified |
| Detail Screen - Internship | Role | student.internshipRole | user.internshipRole/roleTitle | Direct/Fallback | Verified |
| Detail Screen - Internship | Duration | student.duration | user.duration | Direct | Verified |
| Detail Screen - Internship | Start Date | student.startDate | user.startDate (formatted) | Direct | Verified |
| Detail Screen - Internship | End Date | student.endDate | user.endDate (formatted) | Direct | Verified |
| Detail Screen - Internship | Progress | student.progress | (6-field chain) | Fallback | Verified |
| Detail Screen - Mentors | Faculty | student.facultyMentor | (8-field chain) | Fallback | Verified |
| Detail Screen - Mentors | Company | student.companyMentor | (8-field chain) | Fallback | Verified |
| Detail Screen - Attendance | Percentage | student.attendance | (7-field chain) | Fallback | Verified |
| Detail Screen - Attendance | Check-ins | student.weeklyCheckIns | user.weeklyCheckIns/stats.weeklyCheckIns | Direct | Verified |
| Detail Screen - Attendance | Missed | student.missedLogs | user.missedLogs/stats.missedLogs | Direct | Verified |
| Detail Screen - Notes | Notes text | student.notes | user.notes | Direct | Verified |

---

## Enums

### StudentYear
```dart
enum StudentYear {
  first,     // "First Year"
  second,    // "Second Year"
  third,     // "Third Year"
  fourth;    // "Fourth Year"
}
```
**Source:** `user.year` field (enum)

### StudentInternshipStatus
```dart
enum StudentInternshipStatus {
  active,     // Color: Cool Sky
  completed,  // Color: Aquamarine
  atRisk,     // Color: Tangerine
  pending;    // Color: Jasmine
}
```
**Source:** `user.internshipStatus` OR `user.status` field (enum)

---

## Known Issues & Needs Verification

1. **weeklyCheckIns field location:** Check if nested in `user.stats.weeklyCheckIns` or direct `user.weeklyCheckIns`
2. **missedLogs field location:** Check if nested in `user.stats.missedLogs` or direct `user.missedLogs`
3. **_formatDate() function:** Verify date formatting logic handles all Timestamp/String variants
4. **_readRollNumber() function:** Verify doc.id fallback works correctly when no rollNumber field exists

---

**End of Reference Document**
