package com.acme.subs.devices;

import com.acme.subs.devices.dto.RegisterDeviceRequest;
import jakarta.validation.Valid;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;

@RestController
@RequestMapping("/v1/devices")
public class DeviceController {

    private final UserDeviceRepository repo;

    public DeviceController(UserDeviceRepository repo) {
        this.repo = repo;
    }

    @PostMapping
    public void register(Authentication auth, @Valid @RequestBody RegisterDeviceRequest req) {
        UUID userId = (UUID) auth.getPrincipal();

        UserDevice d = new UserDevice();
        d.setUserId(userId);
        d.setPlatform(req.platform().toUpperCase());
        d.setFcmToken(req.fcmToken());
        repo.save(d);
    }
}
