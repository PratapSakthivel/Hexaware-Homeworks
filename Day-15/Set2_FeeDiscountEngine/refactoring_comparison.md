# Set 2: Fee and Discount Engine – Refactoring & Optional Misuse Note

## 1. Correcting Misuses of `Optional`
1. **Misuse 1: Optional as a Method Parameter (`void setFee(Optional<Double> fee)`):**
   - *Fix:* Use regular `Double fee` or overloading. Forcing callers to wrap arguments in `Optional.of()` adds boilerplate and unnecessary heap allocation.
2. **Misuse 2: Optional as a Class Field:**
   - *Fix:* `Optional` does not implement `Serializable`. Keep fields null or default.
3. **Misuse 3: Calling `isPresent()` followed immediately by `get()`:**
   - *Fix:* Replace imperative checking with functional `.ifPresent()`, `.map()`, or `.orElse()`.

## 2. Four Kinds of Method References in Java
1. **Static:** `String::valueOf`
2. **Bound Instance:** `instance::auditFee`
3. **Unbound Instance:** `String::trim`
4. **Constructor:** `StringBuilder::new`
