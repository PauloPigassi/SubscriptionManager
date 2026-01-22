package com.acme.subs.storage;

import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "app.s3")
public class S3StorageProperties {

    private String bucket;
    private String region;
    private String publicBaseUrl;
    private int uploadExpirationMinutes = 15;

    public String getBucket() {
        return bucket;
    }

    public void setBucket(String bucket) {
        this.bucket = bucket;
    }

    public String getRegion() {
        return region;
    }

    public void setRegion(String region) {
        this.region = region;
    }

    public String getPublicBaseUrl() {
        return publicBaseUrl;
    }

    public void setPublicBaseUrl(String publicBaseUrl) {
        this.publicBaseUrl = publicBaseUrl;
    }

    public int getUploadExpirationMinutes() {
        return uploadExpirationMinutes;
    }

    public void setUploadExpirationMinutes(int uploadExpirationMinutes) {
        this.uploadExpirationMinutes = uploadExpirationMinutes;
    }
}
