package com.acme.subs.subscriptions.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.Instant;

public record SubscriptionUpdateRequest(
        @JsonProperty("name") String name,
        @JsonProperty("amountCents") Integer amountCents,
        @JsonProperty("billingCycle") String billingCycle,
        @JsonProperty("intervalCount") Integer intervalCount,
        @JsonProperty("intervalUnit") String intervalUnit,
        @JsonProperty("nextRenewalAt") Instant nextRenewalAt,
        @JsonProperty("category") String category,
        @JsonProperty("notes") String notes
) {}
