package com.hexaware.crm;

public interface Notifier {
    void sendNotification(String recipient, String message);

    // Default method (Task 4)
    default void logNotification(String recipient, String channel) {
        System.out.println("[AUDIT LOG] Notification dispatched via " + channel + " to " + recipient);
    }

    // Static helper method (Task 4)
    static boolean isValidRecipient(String recipient) {
        return recipient != null && !recipient.trim().isEmpty();
    }
}
