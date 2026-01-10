package com.acme.subs.auth;

import com.acme.subs.auth.dto.AuthResponse;
import com.acme.subs.auth.dto.LoginRequest;
import com.acme.subs.auth.dto.RegisterRequest;
import com.acme.subs.config.JwtService;
import com.acme.subs.users.User;
import com.acme.subs.users.UserRepository;
import com.acme.subs.alerts.AlertRule;
import com.acme.subs.alerts.AlertRuleRepository;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Service
public class AuthService {

    private final UserRepository userRepo;
    private final AlertRuleRepository alertRuleRepo;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;

    public AuthService(UserRepository userRepo,
                       AlertRuleRepository alertRuleRepo,
                       PasswordEncoder passwordEncoder,
                       JwtService jwtService) {
        this.userRepo = userRepo;
        this.alertRuleRepo = alertRuleRepo;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
    }

    @Transactional
    public AuthResponse register(RegisterRequest req) {
        userRepo.findByEmailIgnoreCase(req.email()).ifPresent(u -> {
            throw new IllegalArgumentException("email_already_registered");
        });

        User user = new User();
        user.setEmail(req.email().toLowerCase());
        user.setPasswordHash(passwordEncoder.encode(req.password()));
        user.setName(req.name());
        user = userRepo.save(user);

        // default alert rules: 7,3,1,0 enabled
        List<Integer> defaults = List.of(7, 3, 1, 0);
        for (Integer d : defaults) {
            AlertRule r = new AlertRule();
            r.setUserId(user.getId());
            r.setDaysBefore(d);
            r.setEnabled(true);
            alertRuleRepo.save(r);
        }

        String token = jwtService.generateAccessToken(user.getId(), user.getEmail());
        return new AuthResponse(token, user.getId(), user.getEmail(), user.getPlan());
    }

    public AuthResponse login(LoginRequest req) {
        User user = userRepo.findByEmailIgnoreCase(req.email())
                .orElseThrow(() -> new IllegalArgumentException("invalid_credentials"));

        if (!passwordEncoder.matches(req.password(), user.getPasswordHash())) {
            throw new IllegalArgumentException("invalid_credentials");
        }

        String token = jwtService.generateAccessToken(user.getId(), user.getEmail());
        return new AuthResponse(token, user.getId(), user.getEmail(), user.getPlan());
    }
}
