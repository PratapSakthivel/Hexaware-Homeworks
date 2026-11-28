package com.hexaware.ticket;

import java.time.LocalDateTime;
import java.util.Objects;

public class Ticket {
    private final String ticketNumber;
    private final String user;
    private final String summary;
    private final String category;
    private final Priority priority;
    private final LocalDateTime creationTime;
    private boolean isResolved;

    public Ticket(String ticketNumber, String user, String summary, String category, Priority priority, LocalDateTime creationTime) {
        this.ticketNumber = ticketNumber;
        this.user = user;
        this.summary = summary;
        this.category = category;
        this.priority = priority;
        this.creationTime = creationTime;
        this.isResolved = false;
    }

    public String getTicketNumber() { return ticketNumber; }
    public String getUser() { return user; }
    public String getSummary() { return summary; }
    public String getCategory() { return category; }
    public Priority getPriority() { return priority; }
    public LocalDateTime getCreationTime() { return creationTime; }
    public boolean isResolved() { return isResolved; }
    public void setResolved(boolean resolved) { isResolved = resolved; }

    // Task 1: Deduplication based on same user and summary
    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Ticket ticket = (Ticket) o;
        return Objects.equals(user, ticket.user) && Objects.equals(summary, ticket.summary);
    }

    @Override
    public int hashCode() {
        return Objects.hash(user, summary);
    }

    @Override
    public String toString() {
        return String.format("[%s] %-8s | User: %-10s | %-12s | %s (%s)",
            ticketNumber, priority, user, category, summary, creationTime.toLocalTime());
    }
}
