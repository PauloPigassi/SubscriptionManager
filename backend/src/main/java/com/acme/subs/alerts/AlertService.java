package com.acme.subs.alerts;

import com.acme.subs.push.PushSender;
import com.acme.subs.subscriptions.Subscription;
import com.acme.subs.subscriptions.SubscriptionRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Instant;

@Service
public class AlertService {

    private final AlertRepository alertRepo;
    private final SubscriptionRepository subRepo;
    private final PushSender pushSender;

    public AlertService(AlertRepository alertRepo, SubscriptionRepository subRepo, PushSender pushSender) {
        this.alertRepo = alertRepo;
        this.subRepo = subRepo;
        this.pushSender = pushSender;
    }

    @Transactional
    public void send(Alert alert) {
        try {
            System.out.println("[AlertService] Processing alert: " + alert.getId() + " for subscription: " + alert.getSubscriptionId());
            
            Subscription sub = subRepo.findById(alert.getSubscriptionId()).orElse(null);
            if (sub == null || !sub.isActive()) {
                System.out.println("[AlertService] ⚠️ Subscription not found or inactive, skipping alert");
                alert.setStatus("SKIPPED");
                alertRepo.save(alert);
                return;
            }

            String when = switch (alert.getDaysBefore()) {
                case 0 -> "hoje";
                case 1 -> "amanhã";
                default -> "em " + alert.getDaysBefore() + " dias";
            };

            String title = "Renovação " + when;
            String body = sub.getName() + " renova " + when + " (" + (sub.getAmountCents() / 100.0) + " " + sub.getCurrency() + ")";

            System.out.println("[AlertService] Sending push notification - Title: " + title + " Body: " + body);
            pushSender.sendToUser(alert.getUserId(), title, body, sub.getId());

            alert.setStatus("SENT");
            alert.setSentAt(Instant.now());
            alertRepo.save(alert);
            System.out.println("[AlertService] ✅ Alert sent successfully!");
        } catch (Exception e) {
            System.err.println("[AlertService] ❌ Failed to send alert: " + e.getMessage());
            alert.setStatus("FAILED");
            alert.setErrorMessage(e.getMessage());
            alertRepo.save(alert);
            e.printStackTrace();
        }
    }
}
