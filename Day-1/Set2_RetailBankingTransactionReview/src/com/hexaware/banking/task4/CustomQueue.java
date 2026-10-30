package com.hexaware.banking.task4;

import java.util.NoSuchElementException;

/**
 * Custom Queue built from scratch without library collections (FIFO Circular Buffer).
 * Used for the operations manual-review backlog.
 */
public class CustomQueue<T> {
    private Object[] data;
    private int head;
    private int tail;
    private int size;
    private static final int DEFAULT_CAPACITY = 16;

    public CustomQueue() {
        this(DEFAULT_CAPACITY);
    }

    public CustomQueue(int capacity) {
        this.data = new Object[capacity];
        this.head = 0;
        this.tail = 0;
        this.size = 0;
    }

    public void enqueue(T item) {
        if (size == data.length) {
            resize(data.length * 2);
        }
        data[tail] = item;
        tail = (tail + 1) % data.length;
        size++;
    }

    @SuppressWarnings("unchecked")
    public T dequeue() {
        if (isEmpty()) {
            throw new NoSuchElementException("Queue is empty");
        }
        T item = (T) data[head];
        data[head] = null;
        head = (head + 1) % data.length;
        size--;
        if (size > 0 && size == data.length / 4 && data.length > DEFAULT_CAPACITY) {
            resize(data.length / 2);
        }
        return item;
    }

    @SuppressWarnings("unchecked")
    public T peek() {
        if (isEmpty()) {
            throw new NoSuchElementException("Queue is empty");
        }
        return (T) data[head];
    }

    public boolean isEmpty() {
        return size == 0;
    }

    public int size() {
        return size;
    }

    private void resize(int newCap) {
        Object[] newArr = new Object[newCap];
        for (int i = 0; i < size; i++) {
            newArr[i] = data[(head + i) % data.length];
        }
        data = newArr;
        head = 0;
        tail = size;
    }
}
