package com.acme.subs.auth.dto;

import java.util.UUID;

public record AuthResponse(
        String accessToken,
        UUID userId,
        String email,
        String plan
) {}
