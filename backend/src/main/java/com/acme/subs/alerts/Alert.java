package com.acme.subs.alerts;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "alerts")
public class Alert {

    @Id @GeneratedValue
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "subscription_id", nullable = false)
    private UUID subscriptionId;

    @Column(name = "days_before", nullable = false)
    private int daysBefore;

    @Column(name = "scheduled_at", nullable = false)
    private Instant scheduledAt;

    @Column(name = "sent_at")
    private Instant sentAt;

    @Column(nullable = false)
    private String status = "PENDING"; // PENDING/SENT/FAILED/SKIPPED

    @Column(name = "error_message")
    private String errorMessage;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    public static Alert pending(UUID userId, UUID subId, int daysBefore, Instant scheduledAt) {
        Alert a = new Alert();
        a.userId = userId;
        a.subscriptionId = subId;
        a.daysBefore = daysBefore;
        a.scheduledAt = scheduledAt;
        a.status = "PENDING";
        return a;
    }

    // getters/setters
    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public UUID getSubscriptionId() { return subscriptionId; }
    public int getDaysBefore() { return daysBefore; }
    public Instant getScheduledAt() { return scheduledAt; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Instant getSentAt() { return sentAt; }
    public void setSentAt(Instant sentAt) { this.sentAt = sentAt; }
    public String getErrorMessage() { return errorMessage; }
    public void setErrorMessage(String errorMessage) { this.errorMessage = errorMessage; }
}
