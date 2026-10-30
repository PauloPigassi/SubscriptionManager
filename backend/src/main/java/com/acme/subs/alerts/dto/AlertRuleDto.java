package com.acme.subs.alerts.dto;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;

public record AlertRuleDto(
        @Min(0) @Max(60) int daysBefore,
        boolean enabled
) {}
