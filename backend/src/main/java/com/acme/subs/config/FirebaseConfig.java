package com.acme.subs.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Value("${app.firebase.enabled:false}")
    private boolean enabled;

    @Value("${app.firebase.serviceAccountPath}")
    private String serviceAccountPath;

    @PostConstruct
    public void init() throws Exception {
        if (!enabled) return;

        if (!FirebaseApp.getApps().isEmpty()) return;

        InputStream is = getClass().getClassLoader()
                .getResourceAsStream(serviceAccountPath.replace("classpath:", ""));

        if (is == null) {
            throw new IllegalStateException("Firebase service account not found at: " + serviceAccountPath);
        }

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(is))
                .build();

        FirebaseApp.initializeApp(options);
    }
}
