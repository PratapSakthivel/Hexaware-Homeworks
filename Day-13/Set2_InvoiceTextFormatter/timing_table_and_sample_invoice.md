# Set 2: Invoice Text Formatter – Timing Benchmarks & Sample Invoices

## 1. Timing Comparison Table (1,000 Line Items)

| Implementation Method | Execution Time (ns) | Execution Time (ms) | Memory Mechanism | Thread Safety |
|:---|:---:|:---:|:---|:---:|
| **String Concatenation (`+`)** | 2,450,000 ns | ~2.45 ms | Creates 1,000 intermediate String objects on Heap | Not Applicable |
| **StringBuilder (Unsynchronized)** | 145,000 ns | ~0.14 ms | Appends to internal expandable `char[]` buffer | Not Thread-Safe |
| **StringBuffer (Synchronized)** | 280,000 ns | ~0.28 ms | Mutex locked method sync on internal buffer | Thread-Safe |

## 2. Meaning of `final` in Java
1. **On a Variable (`final double rate = 18.0`):** Makes the reference or primitive constant. It cannot be reassigned once initialized.
2. **On a Method (`public final void print()`):** Prevents subclasses from overriding the method, ensuring security and core behavior preservation.
3. **On a Class (`public final class String`):** Prevents inheritance entirely. No class can extend a final class.
