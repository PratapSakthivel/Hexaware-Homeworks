package com.hexaware.retail.task4;

import java.util.EmptyStackException;

/**
 * Custom generic LIFO Stack implementation using a dynamically resizing array.
 *
 * @param <T> Element type
 */
public class CustomStack<T> {
    private Object[] elements;
    private int top;
    private static final int INITIAL_CAPACITY = 8;

    public CustomStack() {
        this.elements = new Object[INITIAL_CAPACITY];
        this.top = -1;
    }

    /**
     * Pushes an item onto the top of the stack.
     * Amortized O(1) time complexity.
     */
    public void push(T item) {
        if (top == elements.length - 1) {
            resize(elements.length * 2);
        }
        elements[++top] = item;
    }

    /**
     * Removes and returns the top item of the stack.
     * O(1) time complexity.
     */
    @SuppressWarnings("unchecked")
    public T pop() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        T item = (T) elements[top];
        elements[top] = null; // Avoid memory leak
        top--;
        if (top > 0 && top == elements.length / 4) {
            resize(elements.length / 2);
        }
        return item;
    }

    /**
     * Looks at the object at the top of this stack without removing it.
     * O(1) time complexity.
     */
    @SuppressWarnings("unchecked")
    public T peek() {
        if (isEmpty()) {
            throw new EmptyStackException();
        }
        return (T) elements[top];
    }

    public boolean isEmpty() {
        return top == -1;
    }

    public int size() {
        return top + 1;
    }

    private void resize(int newCapacity) {
        Object[] newArr = new Object[newCapacity];
        System.arraycopy(elements, 0, newArr, 0, top + 1);
        elements = newArr;
    }
}
