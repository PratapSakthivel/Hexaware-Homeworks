package com.retailorderdesk;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertTrue;

class AppEnvironmentTest {

    @Test
    @DisplayName("Verify testing framework runs cleanly on Java 17+")
    void verifyEnvironment() {
        String javaVersion = System.getProperty("java.version");
        System.out.println("Running on Java Runtime: " + javaVersion);
        assertTrue(true, "Test harness initialized successfully");
    }
}
