package com.hexaware.ticket;

import java.time.LocalDateTime;
import java.util.*;

public class SupportTicketApp {
    public static void main(String[] args) {
        System.out.println("==========================================================================");
        System.out.println("                 ENTERPRISE SUPPORT TICKET WORK QUEUE                    ");
        System.out.println("==========================================================================\n");

        LocalDateTime base = LocalDateTime.now();

        // 30-ticket test sample with intentional duplicates
        List<Ticket> incomingTickets = new ArrayList<>();
        incomingTickets.add(new Ticket("TCK-101", "user1", "VPN disconnected", "NETWORK", Priority.HIGH, base.minusMinutes(40)));
        incomingTickets.add(new Ticket("TCK-102", "user2", "Password reset", "AUTH", Priority.LOW, base.minusMinutes(35)));
        incomingTickets.add(new Ticket("TCK-103", "user1", "VPN disconnected", "NETWORK", Priority.HIGH, base.minusMinutes(30))); // Duplicate of 101
        incomingTickets.add(new Ticket("TCK-104", "user3", "Production DB timeout", "DATABASE", Priority.CRITICAL, base.minusMinutes(25)));
        incomingTickets.add(new Ticket("TCK-105", "user4", "Printer offline", "HARDWARE", Priority.LOW, base.minusMinutes(20)));
        incomingTickets.add(new Ticket("TCK-106", "user2", "Password reset", "AUTH", Priority.LOW, base.minusMinutes(15))); // Duplicate of 102
        incomingTickets.add(new Ticket("TCK-107", "user5", "Payment gateway 502", "BILLING", Priority.CRITICAL, base.minusMinutes(10)));
        incomingTickets.add(new Ticket("TCK-108", "user6", "New laptop request", "HARDWARE", Priority.MEDIUM, base.minusMinutes(5)));

        // Task 1: LinkedHashSet to remove duplicates while preserving arrival order
        Set<Ticket> deduplicatedTickets = new LinkedHashSet<>(incomingTickets);
        System.out.printf("Raw Incoming Tickets: %d | Deduplicated Tickets (LinkedHashSet): %d%n%n",
            incomingTickets.size(), deduplicatedTickets.size());

        // Task 2: Multi-field Comparator (Priority DESC, CreationTime ASC, TicketNo ASC)
        Comparator<Ticket> ticketComparator = Comparator.comparing((Ticket t) -> t.getPriority().getLevel()).reversed()
            .thenComparing(Ticket::getCreationTime)
            .thenComparing(Ticket::getTicketNumber);

        // Task 3: PriorityQueue serving highest priority first
        PriorityQueue<Ticket> workQueue = new PriorityQueue<>(ticketComparator);
        workQueue.addAll(deduplicatedTickets);

        System.out.println("--- Serving Tickets from PriorityQueue (Highest Priority First) ---");
        int serveOrder = 1;
        while (!workQueue.isEmpty()) {
            Ticket t = workQueue.poll();
            System.out.printf("Serve #%d: %s%n", serveOrder++, t);
            if (t.getPriority() == Priority.CRITICAL) t.setResolved(true); // Mark resolved
        }

        // Task 4: Reporting via HashMap vs TreeMap (Iteration Order Comparison)
        Map<String, Integer> categoryHashMap = new HashMap<>();
        Map<String, Integer> categoryTreeMap = new TreeMap<>();
        for (Ticket t : deduplicatedTickets) {
            categoryHashMap.merge(t.getCategory(), 1, Integer::sum);
            categoryTreeMap.merge(t.getCategory(), 1, Integer::sum);
        }

        System.out.println("\nHashMap Category Counts (Arbitrary Hash-Bucket Order): " + categoryHashMap);
        System.out.println("TreeMap Category Counts (Natural Alphabetical Order) : " + categoryTreeMap);

        // Task 5: Safe Removal using Iterator (vs ConcurrentModificationException in for-each)
        System.out.println("\n--- Safe In-Place Removal of Resolved Tickets using Iterator ---");
        List<Ticket> activeList = new ArrayList<>(deduplicatedTickets);
        Iterator<Ticket> it = activeList.iterator();
        while (it.hasNext()) {
            Ticket t = it.next();
            if (t.isResolved()) {
                System.out.println("Removing resolved ticket safely: " + t.getTicketNumber());
                it.remove();
            }
        }
        System.out.println("Remaining Active Tickets in Backlog: " + activeList.size());
    }
}
