package com.hexaware.attendance;

import java.time.LocalDate;

// Task 4: Immutable Record
public record AttendanceRecord(String learnerId, String courseCode, LocalDate date, boolean isPresent) {
}
