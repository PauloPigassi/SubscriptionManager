package com.acme.subs.subscriptions.dto;

import jakarta.validation.constraints.*;
import java.time.Instant;
import java.util.UUID;

public record SubscriptionCreateRequest(
        UUID catalogServiceId,
        @NotBlank String name,
        String category,
        @Min(0) int amountCents,
        @NotBlank String billingCycle,
        int intervalCount,
        String intervalUnit,
        @NotNull Instant nextRenewalAt,
        String notes
) {}
