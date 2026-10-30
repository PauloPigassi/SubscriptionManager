package com.acme.subs.alerts;

import com.acme.subs.alerts.dto.AlertRuleDto;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

@Service
public class AlertRuleService {

    private final AlertRuleRepository ruleRepo;
    private final AlertRepository alertRepo;

    public AlertRuleService(AlertRuleRepository ruleRepo, AlertRepository alertRepo) {
        this.ruleRepo = ruleRepo;
        this.alertRepo = alertRepo;
    }

    public List<AlertRuleDto> list(UUID userId) {
        return ruleRepo.findByUserIdOrderByDaysBeforeDesc(userId).stream()
                .map(r -> new AlertRuleDto(r.getDaysBefore(), r.isEnabled()))
                .toList();
    }

    /**
     * Substitui o conjunto de regras do usuário. Regras existentes são atualizadas no lugar
     * (evita conflito com UNIQUE(user_id, days_before)), as ausentes são removidas.
     */
    @Transactional
    public List<AlertRuleDto> replace(UUID userId, List<AlertRuleDto> rules) {
        // último valor vence em caso de daysBefore duplicado
        Map<Integer, Boolean> requested = new LinkedHashMap<>();
        for (AlertRuleDto r : rules) requested.put(r.daysBefore(), r.enabled());

        Map<Integer, AlertRule> existing = new HashMap<>();
        for (AlertRule r : ruleRepo.findByUserIdOrderByDaysBeforeDesc(userId)) existing.put(r.getDaysBefore(), r);

        List<AlertRule> toDelete = existing.values().stream()
                .filter(r -> !requested.containsKey(r.getDaysBefore()))
                .toList();
        ruleRepo.deleteAll(toDelete);

        requested.forEach((days, enabled) -> {
            AlertRule r = existing.get(days);
            if (r == null) {
                r = new AlertRule();
                r.setUserId(userId);
                r.setDaysBefore(days);
            }
            r.setEnabled(enabled);
            ruleRepo.save(r);
        });

        // Alertas já agendados para regras desligadas/removidas não devem mais disparar
        List<Integer> activeDays = requested.entrySet().stream()
                .filter(Map.Entry::getValue)
                .map(Map.Entry::getKey)
                .toList();
        if (activeDays.isEmpty()) {
            alertRepo.skipAllPending(userId);
        } else {
            alertRepo.skipPendingExcept(userId, activeDays);
        }

        return list(userId);
    }
}
