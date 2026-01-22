package com.acme.subs.config;

import com.google.auth.oauth2.GoogleCredentials;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseOptions;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;

import jakarta.annotation.PostConstruct;
import java.io.FileInputStream;
import java.io.InputStream;

@Configuration
public class FirebaseConfig {

    @Value("${app.firebase.enabled:false}")
    private boolean enabled;

    @Value("${app.firebase.serviceAccountPath}")
    private String serviceAccountPath;

    @PostConstruct
    public void init() throws Exception {
        if (!enabled) {
            System.out.println("[FirebaseConfig] ⚠️ Firebase is DISABLED. Notifications will not be sent.");
            return;
        }

        if (!FirebaseApp.getApps().isEmpty()) {
            System.out.println("[FirebaseConfig] ✅ Firebase already initialized");
            return;
        }

        InputStream is;
        
        // Suporta classpath: ou caminho absoluto de arquivo
        if (serviceAccountPath.startsWith("classpath:")) {
            String resourcePath = serviceAccountPath.replace("classpath:", "");
            is = getClass().getClassLoader().getResourceAsStream(resourcePath);
            if (is == null) {
                System.err.println("[FirebaseConfig] ❌ Firebase service account not found in classpath: " + resourcePath);
                throw new IllegalStateException("Firebase service account not found in classpath: " + resourcePath);
            }
            System.out.println("[FirebaseConfig] Loading Firebase service account from classpath: " + resourcePath);
        } else {
            // Caminho absoluto de arquivo (ex: /app/firebase-service-account.json)
            try {
                is = new FileInputStream(serviceAccountPath);
                System.out.println("[FirebaseConfig] Loading Firebase service account from file: " + serviceAccountPath);
            } catch (Exception e) {
                System.err.println("[FirebaseConfig] ❌ Firebase service account file not found: " + serviceAccountPath);
                throw new IllegalStateException("Firebase service account file not found: " + serviceAccountPath, e);
            }
        }

        FirebaseOptions options = FirebaseOptions.builder()
                .setCredentials(GoogleCredentials.fromStream(is))
                .build();

        FirebaseApp.initializeApp(options);
        System.out.println("[FirebaseConfig] ✅ Firebase initialized successfully!");
    }
}
