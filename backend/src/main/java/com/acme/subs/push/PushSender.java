package com.acme.subs.push;

import com.acme.subs.devices.UserDeviceRepository;
import com.google.firebase.messaging.FirebaseMessaging;
import com.google.firebase.messaging.Message;
import com.google.firebase.messaging.Notification;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.util.UUID;

@Component
public class PushSender {

    private final UserDeviceRepository deviceRepo;

    @Value("${app.firebase.enabled:false}")
    private boolean enabled;

    public PushSender(UserDeviceRepository deviceRepo) {
        this.deviceRepo = deviceRepo;
    }

    public void sendToUser(UUID userId, String title, String body, UUID subscriptionId) {
        var devices = deviceRepo.findByUserId(userId);
        if (devices.isEmpty()) {
            System.out.println("[PushSender] No devices found for user: " + userId);
            return;
        }

        System.out.println("[PushSender] Sending notification to " + devices.size() + " device(s) for user: " + userId);
        
        for (var d : devices) {
            if (!enabled) {
                System.out.println("[FCM disabled] would send to " + d.getPlatform() + " token=" + d.getFcmToken()
                        + " title=" + title + " body=" + body);
                continue;
            }

            try {
                Message msg = Message.builder()
                        .setToken(d.getFcmToken())
                        .setNotification(Notification.builder()
                                .setTitle(title)
                                .setBody(body)
                                .build())
                        .putData("subscriptionId", subscriptionId.toString())
                        .build();

                String messageId = FirebaseMessaging.getInstance().send(msg);
                System.out.println("[PushSender] ✅ Notification sent successfully! MessageId: " + messageId 
                        + " Platform: " + d.getPlatform() + " UserId: " + userId);
            } catch (Exception e) {
                System.err.println("[PushSender] ❌ Failed to send notification to " + d.getPlatform() 
                        + " token: " + d.getFcmToken().substring(0, Math.min(20, d.getFcmToken().length())) + "...");
                e.printStackTrace();
            }
        }
    }
}
