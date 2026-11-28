# Set 2: Retail Inventory Manager – Collection Choice Rationale

| Requirement | Chosen Collection | Time Complexity | Justification |
|:---|:---|:---:|:---|
| **SKU Look-up** | `HashMap<String, Product>` | $O(1)$ | Instant constant-time retrieval by product SKU. |
| **Multi-Tier Sorting** | `ArrayList<Product>` + `Comparable` | $O(n \log n)$ | Dual-pivot Quicksort / TimSort preserving category & stock hierarchies. |
| **Activity Log** | `ArrayDeque<String>` | $O(1)$ amortized | Circular array buffer ideal for LIFO recent activity stack without linked node allocation overhead. |
