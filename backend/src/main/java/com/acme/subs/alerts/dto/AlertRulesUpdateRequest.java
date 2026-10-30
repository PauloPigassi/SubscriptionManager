package com.acme.subs.alerts.dto;

import jakarta.validation.Valid;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;

import java.util.List;

public record AlertRulesUpdateRequest(
        @NotNull @Size(max = 10) List<@Valid AlertRuleDto> rules
) {}
