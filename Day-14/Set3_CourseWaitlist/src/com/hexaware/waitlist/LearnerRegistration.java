package com.hexaware.waitlist;

import java.util.Objects;

public class LearnerRegistration implements Comparable<LearnerRegistration> {
    private final String studentId;
    private final String name;
    private final int seniorityYears;
    private final long registrationTimestamp;
    private final int entranceScore;

    public LearnerRegistration(String studentId, String name, int seniorityYears, long registrationTimestamp, int entranceScore) {
        this.studentId = studentId;
        this.name = name;
        this.seniorityYears = seniorityYears;
        this.registrationTimestamp = registrationTimestamp;
        this.entranceScore = entranceScore;
    }

    public String getStudentId() { return studentId; }
    public String getName() { return name; }
    public int getSeniorityYears() { return seniorityYears; }
    public long getRegistrationTimestamp() { return registrationTimestamp; }
    public int getEntranceScore() { return entranceScore; }

    // Natural Comparable: Seniority DESC, then Registration Time ASC
    @Override
    public int compareTo(LearnerRegistration other) {
        int sen = Integer.compare(other.seniorityYears, this.seniorityYears);
        if (sen != 0) return sen;
        return Long.compare(this.registrationTimestamp, other.registrationTimestamp);
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        LearnerRegistration that = (LearnerRegistration) o;
        return Objects.equals(studentId, that.studentId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(studentId);
    }

    @Override
    public String toString() {
        return String.format("[%s] %-15s | Seniority: %2dyrs | Score: %3d | Time: %d",
            studentId, name, seniorityYears, entranceScore, registrationTimestamp);
    }
}
