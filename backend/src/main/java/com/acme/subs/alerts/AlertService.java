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
            Subscription sub = subRepo.findById(alert.getSubscriptionId()).orElse(null);
            if (sub == null || !sub.isActive()) {
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

            pushSender.sendToUser(alert.getUserId(), title, body, sub.getId());

            alert.setStatus("SENT");
            alert.setSentAt(Instant.now());
            alertRepo.save(alert);
        } catch (Exception e) {
            alert.setStatus("FAILED");
            alert.setErrorMessage(e.getMessage());
            alertRepo.save(alert);
        }
    }
}
