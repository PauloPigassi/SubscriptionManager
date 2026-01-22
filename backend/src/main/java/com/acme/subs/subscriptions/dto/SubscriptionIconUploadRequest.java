package com.acme.subs.subscriptions.dto;

import jakarta.validation.constraints.NotBlank;

public record SubscriptionIconUploadRequest(
        @NotBlank String fileName,
        String contentType
) {}
