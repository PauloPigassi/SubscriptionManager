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
        if (devices.isEmpty()) return;

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

                FirebaseMessaging.getInstance().send(msg);
            } catch (Exception e) {
                // no MVP: log
                e.printStackTrace();
            }
        }
    }
}
