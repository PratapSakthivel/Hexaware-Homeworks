package com.hexaware.hospital.task4;

import java.util.NoSuchElementException;

/**
 * Custom FIFO Circular Queue built from scratch without library collections.
 * Models the hospital walk-in token line.
 */
public class CustomQueue<T> {
    private Object[] data;
    private int head;
    private int tail;
    private int count;
    private static final int INITIAL_CAPACITY = 16;

    public CustomQueue() {
        this.data = new Object[INITIAL_CAPACITY];
        this.head = 0;
        this.tail = 0;
        this.count = 0;
    }

    public void enqueue(T item) {
        if (count == data.length) {
            resize(data.length * 2);
        }
        data[tail] = item;
        tail = (tail + 1) % data.length;
        count++;
    }

    @SuppressWarnings("unchecked")
    public T dequeue() {
        if (isEmpty()) {
            throw new NoSuchElementException("Token line queue is empty");
        }
        T item = (T) data[head];
        data[head] = null;
        head = (head + 1) % data.length;
        count--;
        if (count > 0 && count == data.length / 4 && data.length > INITIAL_CAPACITY) {
            resize(data.length / 2);
        }
        return item;
    }

    @SuppressWarnings("unchecked")
    public T peek() {
        if (isEmpty()) {
            throw new NoSuchElementException("Token line queue is empty");
        }
        return (T) data[head];
    }

    public boolean isEmpty() {
        return count == 0;
    }

    public int size() {
        return count;
    }

    private void resize(int newCap) {
        Object[] newArr = new Object[newCap];
        for (int i = 0; i < count; i++) {
            newArr[i] = data[(head + i) % data.length];
        }
        data = newArr;
        head = 0;
        tail = count;
    }
}
