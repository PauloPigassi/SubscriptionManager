package com.acme.subs.storage;

import com.acme.subs.subscriptions.dto.SubscriptionIconUploadResponse;
import java.net.URI;
import java.time.Duration;
import java.util.UUID;
import org.springframework.boot.autoconfigure.condition.ConditionalOnProperty;
import org.springframework.stereotype.Service;
import software.amazon.awssdk.services.s3.model.PutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.S3Presigner;
import software.amazon.awssdk.services.s3.presigner.model.PresignedPutObjectRequest;
import software.amazon.awssdk.services.s3.presigner.model.PutObjectPresignRequest;

@Service
@ConditionalOnProperty(prefix = "app.s3", name = {"bucket", "region"})
public class S3IconService {

    private final S3Presigner presigner;
    private final S3StorageProperties properties;

    public S3IconService(S3Presigner presigner, S3StorageProperties properties) {
        this.presigner = presigner;
        this.properties = properties;
    }

    public SubscriptionIconUploadResponse createUpload(UUID userId, UUID subscriptionId, String fileName, String contentType) {
        String sanitized = sanitizeFileName(fileName);
        String key = "subscriptions/%s/%s/icon/%s-%s".formatted(
                userId,
                subscriptionId,
                UUID.randomUUID(),
                sanitized
        );
        String resolvedContentType = (contentType == null || contentType.isBlank())
                ? "image/png"
                : contentType;
        PutObjectRequest putObjectRequest = PutObjectRequest.builder()
                .bucket(properties.getBucket())
                .key(key)
                .contentType(resolvedContentType)
                .build();
        PutObjectPresignRequest presignRequest = PutObjectPresignRequest.builder()
                .signatureDuration(Duration.ofMinutes(properties.getUploadExpirationMinutes()))
                .putObjectRequest(putObjectRequest)
                .build();
        PresignedPutObjectRequest presignedRequest = presigner.presignPutObject(presignRequest);
        String iconUrl = buildPublicUrl(key);
        return new SubscriptionIconUploadResponse(presignedRequest.url().toString(), iconUrl);
    }

    private String buildPublicUrl(String key) {
        String base = properties.getPublicBaseUrl();
        if (base == null || base.isBlank()) {
            base = "https://%s.s3.%s.amazonaws.com".formatted(
                    properties.getBucket(),
                    properties.getRegion()
            );
        }
        String normalizedBase = base.endsWith("/") ? base.substring(0, base.length() - 1) : base;
        return URI.create(normalizedBase + "/" + key).toString();
    }

    private String sanitizeFileName(String fileName) {
        String trimmed = fileName == null ? "icon" : fileName.trim();
        if (trimmed.isEmpty()) {
            return "icon";
        }
        return trimmed.replaceAll("[^a-zA-Z0-9._-]", "_");
    }
}
