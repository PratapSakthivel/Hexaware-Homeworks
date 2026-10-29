package com.hexaware.retail.task4;

import java.util.NoSuchElementException;

/**
 * Custom generic FIFO Queue implementation using a circular dynamically resizing array.
 *
 * @param <T> Element type
 */
public class CustomQueue<T> {
    private Object[] elements;
    private int head;
    private int tail;
    private int count;
    private static final int INITIAL_CAPACITY = 8;

    public CustomQueue() {
        this.elements = new Object[INITIAL_CAPACITY];
        this.head = 0;
        this.tail = 0;
        this.count = 0;
    }

    /**
     * Inserts the specified element at the tail of the queue.
     * Amortized O(1) time complexity.
     */
    public void enqueue(T item) {
        if (count == elements.length) {
            resize(elements.length * 2);
        }
        elements[tail] = item;
        tail = (tail + 1) % elements.length;
        count++;
    }

    /**
     * Retrieves and removes the head of this queue.
     * O(1) time complexity.
     */
    @SuppressWarnings("unchecked")
    public T dequeue() {
        if (isEmpty()) {
            throw new NoSuchElementException("Queue is empty");
        }
        T item = (T) elements[head];
        elements[head] = null; // Avoid memory leak
        head = (head + 1) % elements.length;
        count--;
        if (count > 0 && count == elements.length / 4 && elements.length > INITIAL_CAPACITY) {
            resize(elements.length / 2);
        }
        return item;
    }

    /**
     * Retrieves, but does not remove, the head of this queue.
     * O(1) time complexity.
     */
    @SuppressWarnings("unchecked")
    public T peek() {
        if (isEmpty()) {
            throw new NoSuchElementException("Queue is empty");
        }
        return (T) elements[head];
    }

    public boolean isEmpty() {
        return count == 0;
    }

    public int size() {
        return count;
    }

    private void resize(int newCapacity) {
        Object[] newArr = new Object[newCapacity];
        for (int i = 0; i < count; i++) {
            newArr[i] = elements[(head + i) % elements.length];
        }
        elements = newArr;
        head = 0;
        tail = count;
    }
}
