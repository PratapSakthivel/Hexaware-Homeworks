# Set 1: Support Ticket Queue – Iterator Note & ConcurrentModificationException

## 1. Why for-each Throws ConcurrentModificationException
The enhanced for-each loop in Java uses an `Iterator` internally:
```java
for (Ticket t : list) {
    if (t.isResolved()) list.remove(t); // THROWS ConcurrentModificationException!
}
```
- **The Mechanism:** `ArrayList` maintains an internal `modCount` tracking structural modifications.
- The iterator caches this as `expectedModCount`.
- When `list.remove(t)` is invoked directly on the list, `modCount` increments, but `expectedModCount` remains stale.
- On the next `iterator.next()` call, `if (modCount != expectedModCount)` evaluates to true, immediately throwing `ConcurrentModificationException` to prevent non-deterministic iteration.

## 2. The Solution: Explicit `Iterator.remove()`
Calling `it.remove()` updates `expectedModCount = modCount` synchronically, allowing safe removal during traversal.
