# Set 1: Customer Master De-duplication – equals() and hashCode() Contract Note

## 1. The Core Contract
In Java, `equals()` and `hashCode()` must obey a strict mathematical contract:
1. **Reflexive, Symmetric, Transitive, Consistent:**
   - For any non-null reference `x`, `x.equals(x)` is `true`.
   - If `x.equals(y)` is `true`, `y.equals(x)` must be `true`.
2. **If `x.equals(y) == true`, then `x.hashCode() == y.hashCode()` MUST be true.**
   - If two customer objects have the same normalized email, they must hash to the exact same hash bucket in `HashSet` or `HashMap`.
3. **If `x.equals(y) == false`, hash codes DO NOT need to be distinct**, but distinct hash codes improve hash table performance by preventing hash collisions.

## 2. Marker vs Functional Interfaces
- **Marker Interface (`Auditable`):** Contains zero methods. Informs the JVM or framework (e.g., Hibernate, Jackson) of metadata permissions without forcing implementation.
- **Functional Interface (`CustomerValidator`):** Contains exactly one abstract method (`@FunctionalInterface`). Can be instantiated via concise lambda expressions:
```java
CustomerValidator emailCheck = c -> c.getNormalizedEmail().contains("@");
```
