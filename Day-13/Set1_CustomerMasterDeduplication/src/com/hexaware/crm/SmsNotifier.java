package com.hexaware.crm;

public class SmsNotifier implements Notifier {
    @Override
    public void sendNotification(String recipient, String message) {
        if (Notifier.isValidRecipient(recipient)) {
            System.out.println("Sending SMS to " + recipient + " | Msg: " + message);
            logNotification(recipient, "TELECOM_SMS_AGGREGATOR");
        }
    }
}
