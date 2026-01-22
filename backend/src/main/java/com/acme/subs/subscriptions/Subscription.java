package com.acme.subs.subscriptions;

import jakarta.persistence.*;
import java.time.Instant;
import java.util.UUID;

@Entity
@Table(name = "subscriptions")
public class Subscription {

    @Id @GeneratedValue
    private UUID id;

    @Column(name = "user_id", nullable = false)
    private UUID userId;

    @Column(name = "catalog_service_id")
    private UUID catalogServiceId;

    @Column(nullable = false)
    private String name;

    private String category;

    @Column(name = "amount_cents", nullable = false)
    private int amountCents;

    @Column(nullable = false)
    private String currency = "BRL";

    @Column(name = "billing_cycle", nullable = false)
    private String billingCycle; // MONTHLY/YEARLY/WEEKLY/CUSTOM

    @Column(name = "interval_count", nullable = false)
    private int intervalCount = 1;

    @Column(name = "interval_unit", nullable = false)
    private String intervalUnit = "MONTH"; // MONTH/YEAR (para CUSTOM)

    @Column(name = "next_renewal_at", nullable = false)
    private Instant nextRenewalAt;

    @Column(name = "is_active", nullable = false)
    private boolean active = true;

    private String notes;

    @Column(name = "created_at", nullable = false)
    private Instant createdAt = Instant.now();

    @Column(name = "updated_at", nullable = false)
    private Instant updatedAt = Instant.now();

    // getters/setters
    public UUID getId() { return id; }
    public UUID getUserId() { return userId; }
    public void setUserId(UUID userId) { this.userId = userId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public int getAmountCents() { return amountCents; }
    public void setAmountCents(int amountCents) { this.amountCents = amountCents; }
    public String getCurrency() { return currency; }
    public void setCurrency(String currency) { this.currency = currency; }
    public String getBillingCycle() { return billingCycle; }
    public void setBillingCycle(String billingCycle) { this.billingCycle = billingCycle; }
    public Instant getNextRenewalAt() { return nextRenewalAt; }
    public void setNextRenewalAt(Instant nextRenewalAt) { this.nextRenewalAt = nextRenewalAt; }
    public boolean isActive() { return active; }
    public void setActive(boolean active) { this.active = active; }
    public int getIntervalCount() { return intervalCount; }
    public void setIntervalCount(int intervalCount) { this.intervalCount = intervalCount; }
    public String getIntervalUnit() { return intervalUnit; }
    public void setIntervalUnit(String intervalUnit) { this.intervalUnit = intervalUnit; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public UUID getCatalogServiceId() { return catalogServiceId; }
    public void setCatalogServiceId(UUID catalogServiceId) { this.catalogServiceId = catalogServiceId; }
    public String getNotes() { return notes; }
    public void setNotes(String notes) { this.notes = notes; }
    public Instant getCreatedAt() { return createdAt; }
    public Instant getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Instant updatedAt) { this.updatedAt = updatedAt; }
}
