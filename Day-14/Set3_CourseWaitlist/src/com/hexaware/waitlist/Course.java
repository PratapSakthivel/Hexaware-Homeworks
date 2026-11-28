package com.hexaware.waitlist;

public class Course {
    private final String code;
    private final String name;
    private final int capacity;

    public Course(String code, String name, int capacity) {
        this.code = code;
        this.name = name;
        this.capacity = capacity;
    }

    public String getCode() { return code; }
    public String getName() { return name; }
    public int getCapacity() { return capacity; }
}
