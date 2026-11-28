package com.hexaware.inventory;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

// Task 4: Generic Repository with Bounded Type Parameter
public class Repository<T> {
    private final Map<String, T> storage = new HashMap<>();

    public void save(String id, T entity) {
        storage.put(id, entity);
    }

    public Optional<T> findById(String id) {
        return Optional.ofNullable(storage.get(id));
    }

    public Map<String, T> findAll() {
        return storage;
    }
}
