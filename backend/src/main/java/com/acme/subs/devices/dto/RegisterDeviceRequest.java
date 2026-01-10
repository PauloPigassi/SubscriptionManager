package com.acme.subs.devices.dto;

import jakarta.validation.constraints.NotBlank;

public record RegisterDeviceRequest(
        @NotBlank String platform,
        @NotBlank String fcmToken
) {}
