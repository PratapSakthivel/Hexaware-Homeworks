# Set 3: Attendance Report Generator – String Immutability & Thread Safety Note

## 1. Why Strings are Immutable in Java
1. **String Constant Pool (SCP):** Multiple references point to the exact same literal. If strings were mutable, altering one reference would silently corrupt all others.
2. **Security:** Strings carry database URLs, usernames, passwords, and file paths. Immutability prevents malicious tampering across method calls.
3. **Thread Safety:** Immutable objects are inherently thread-safe without synchronization locks.
4. **Caching HashCodes:** `hashCode()` is computed once lazily and cached, making Strings ideal keys for `HashMap`.

## 2. Thread Safety Comparison: String vs StringBuilder vs StringBuffer
- **`String`:** Immutable, thread-safe.
- **`StringBuilder`:** Mutable, non-synchronized, not thread-safe. Optimized for single-threaded loops.
- **`StringBuffer`:** Mutable, methods synchronized with internal monitor locks. Thread-safe for shared concurrency.
