package com.hexaware.hospital.task4;

import java.util.EmptyStackException;

/**
 * Custom LIFO Dynamic Resizing Stack built from scratch without library collections.
 * Models the doctor's 'recent patients viewed' browsing history.
 */
public class CustomStack<T> {
    private Object[] data;
    private int top;
    private static final int INITIAL_CAPACITY = 16;

    public CustomStack() {
        this.data = new Object[INITIAL_CAPACITY];
        this.top = -1;
    }

    public void push(T item) {
        if (top == data.length - 1) {
            resize(data.length * 2);
        }
        data[++top] = item;
    }

    @SuppressWarnings("unchecked")
    public T pop() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        T item = (T) data[top];
        data[top] = null;
        top--;
        if (top > 0 && top == data.length / 4 && data.length > INITIAL_CAPACITY) {
            resize(data.length / 2);
        }
        return item;
    }

    @SuppressWarnings("unchecked")
    public T peek() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        return (T) data[top];
    }

    public boolean isEmpty() {
        return top == -1;
    }

    public int size() {
        return top + 1;
    }

    private void resize(int newCap) {
        Object[] newArr = new Object[newCap];
        System.arraycopy(data, 0, newArr, 0, top + 1);
        data = newArr;
    }
}
