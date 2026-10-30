package com.acme.subs.alerts;

import com.acme.subs.alerts.dto.AlertRuleDto;
import com.acme.subs.alerts.dto.AlertRulesUpdateRequest;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;

@RestController
@RequestMapping("/v1/alert-rules")
public class AlertRuleController {

    private final AlertRuleService service;

    public AlertRuleController(AlertRuleService service) {
        this.service = service;
    }

    @GetMapping
    public List<AlertRuleDto> list(Authentication auth) {
        UUID userId = (UUID) auth.getPrincipal();
        return service.list(userId);
    }

    @PutMapping
    public List<AlertRuleDto> replace(Authentication auth, @Valid @RequestBody AlertRulesUpdateRequest req) {
        UUID userId = (UUID) auth.getPrincipal();
        return service.replace(userId, req.rules());
    }
}
