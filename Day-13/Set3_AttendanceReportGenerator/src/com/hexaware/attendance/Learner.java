package com.hexaware.attendance;

import java.util.Objects;

public class Learner {
    private final String learnerId;
    private final String name;

    public Learner(String learnerId, String name) {
        this.learnerId = learnerId;
        this.name = name;
    }

    public String getLearnerId() { return learnerId; }
    public String getName() { return name; }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        Learner learner = (Learner) o;
        return Objects.equals(learnerId, learner.learnerId);
    }

    @Override
    public int hashCode() {
        return Objects.hash(learnerId);
    }

    @Override
    public String toString() {
        return learnerId + ":" + name;
    }
}
