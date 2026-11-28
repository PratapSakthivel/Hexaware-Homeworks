package com.hexaware.crm;

public class EmailNotifier implements Notifier {
    @Override
    public void sendNotification(String recipient, String message) {
        if (Notifier.isValidRecipient(recipient)) {
            System.out.println("Sending Email to " + recipient + " | Body: " + message);
            logNotification(recipient, "SMTP_SECURE_GATEWAY");
        }
    }
}
