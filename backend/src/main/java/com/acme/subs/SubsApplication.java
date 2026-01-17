package com.acme.subs;

import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.annotation.Bean;
import org.springframework.scheduling.annotation.EnableScheduling;

import com.acme.subs.alerts.AlertScheduler;

@SpringBootApplication
@EnableScheduling
public class SubsApplication {

    public static void main(String[] args) {
        SpringApplication.run(SubsApplication.class, args);
    }

    // @Bean
    // public CommandLineRunner init(AlertScheduler alertScheduler) {
    //     return args -> {
    //         try {
    //             System.out.println("[SubsApplication] Application ready, generating alerts...");
    //             alertScheduler.generateUpcomingAlerts(); // Cria os alertas
    //             alertScheduler.dispatchPendingAlerts(); // Envia os alertas pendentes
    //             System.out.println("[SubsApplication] ✅ Alerts generated and dispatched");
    //         } catch (Exception e) {
    //             System.err.println("[SubsApplication] ❌ Error generating alerts: " + e.getMessage());
    //             e.printStackTrace();
    //         }
    //     };
    // }
}
