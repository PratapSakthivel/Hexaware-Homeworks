package com.hexaware.retail.task4;

import com.hexaware.retail.model.Order;
import com.hexaware.retail.model.OrderEdit;

import java.time.LocalDateTime;
import java.util.*;

/**
 * Task 4: Custom Stack & Queue vs Built-in Equivalents
 * - Custom Stack: models 'undo last order edit'
 * - Custom Queue: models 'warehouse dispatch line'
 * - Built-in replacement: Deque / ArrayDeque / Queue
 * - Empirical benchmarks and theoretical comparison.
 */
public class DispatchAndUndoDemo {

    public static void runDemo(List<Order> sampleOrders) {
        System.out.println("================================================================================");
        System.out.println("   TASK 4: CUSTOM STACK (UNDO EDITS) & QUEUE (DISPATCH) VS BUILT-IN EQUIVALENTS");
        System.out.println("================================================================================");

        // -------------------------------------------------------------------------
        // PART 1: UNDO LAST ORDER EDIT USING STACK (LIFO)
        // -------------------------------------------------------------------------
        System.out.println("--- Part 1: Order Edit History & Undo Mechanism (LIFO) ---");
        Order targetOrder = new Order(100101, "CUST-4421", 500.00, LocalDateTime.now());
        System.out.println("Initial Order State : " + targetOrder);

        CustomStack<OrderEdit> customUndoStack = new CustomStack<>();

        // Perform 3 sequential edits
        System.out.println("\n[Customer Support Edits]");
        double edit1Amount = 450.00;
        customUndoStack.push(new OrderEdit(targetOrder.getOrderId(), targetOrder.getAmount(), edit1Amount, "Applied $50 loyalty discount"));
        targetOrder.setAmount(edit1Amount);
        System.out.printf("  1. Applied Discount  -> New Amount: $%.2f | Stack size: %d%n", targetOrder.getAmount(), customUndoStack.size());

        double edit2Amount = 420.00;
        customUndoStack.push(new OrderEdit(targetOrder.getOrderId(), targetOrder.getAmount(), edit2Amount, "Applied price match promo"));
        targetOrder.setAmount(edit2Amount);
        System.out.printf("  2. Price Match Promo -> New Amount: $%.2f | Stack size: %d%n", targetOrder.getAmount(), customUndoStack.size());

        double edit3Amount = 350.00;
        customUndoStack.push(new OrderEdit(targetOrder.getOrderId(), targetOrder.getAmount(), edit3Amount, "Agent entered wrong manual adjustment"));
        targetOrder.setAmount(edit3Amount);
        System.out.printf("  3. Accidental Edit   -> New Amount: $%.2f | Stack size: %d%n", targetOrder.getAmount(), customUndoStack.size());

        System.out.printf("%nCurrent Order State before Undo: $%.2f%n", targetOrder.getAmount());

        // Perform Undo using CustomStack
        System.out.println("\n[Undo Operations using CustomStack]");
        while (!customUndoStack.isEmpty()) {
            OrderEdit lastEdit = customUndoStack.pop();
            targetOrder.setAmount(lastEdit.getOldAmount());
            System.out.printf("  <- UNDO: Reverted (%s). Order restored to $%.2f (Remaining history: %d)%n",
                    lastEdit.getEditReason(), targetOrder.getAmount(), customUndoStack.size());
        }
        System.out.printf("Final Order State after full Undo: %s%n", targetOrder);

        // Replacing CustomStack with built-in Deque (ArrayDeque)
        System.out.println("\n[Built-in Replacement: java.util.ArrayDeque as Stack]");
        Deque<OrderEdit> builtInStack = new ArrayDeque<>();
        builtInStack.push(new OrderEdit(targetOrder.getOrderId(), 500.00, 450.00, "Discount"));
        builtInStack.push(new OrderEdit(targetOrder.getOrderId(), 450.00, 400.00, "Promo"));
        System.out.printf("  Built-in Stack pushed 2 edits. Top edit to undo: %s%n", builtInStack.peek());
        OrderEdit undone = builtInStack.pop();
        System.out.printf("  Successfully popped with built-in: %s%n", undone);

        // -------------------------------------------------------------------------
        // PART 2: WAREHOUSE DISPATCH LINE USING QUEUE (FIFO)
        // -------------------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------------------");
        System.out.println("--- Part 2: Warehouse Dispatch Line Queue (FIFO) ---");
        System.out.println("-------------------------------------------------------------------------");

        CustomQueue<Order> dispatchQueue = new CustomQueue<>();
        int queueCount = Math.min(5, sampleOrders.size());
        System.out.printf("Enqueuing %d incoming orders into warehouse dispatch line:%n", queueCount);
        for (int i = 0; i < queueCount; i++) {
            Order o = sampleOrders.get(i);
            dispatchQueue.enqueue(o);
            System.out.printf("  [+] Enqueued Order #%d (ID: %d, Amt: $%.2f)%n", i + 1, o.getOrderId(), o.getAmount());
        }

        System.out.printf("%nDispatching orders from front of CustomQueue (FIFO order):%n");
        while (!dispatchQueue.isEmpty()) {
            Order dispatched = dispatchQueue.dequeue();
            System.out.printf("  [-] Dispatched -> Order ID: %d | Amount: $%.2f | Remainder in line: %d%n",
                    dispatched.getOrderId(), dispatched.getAmount(), dispatchQueue.size());
        }

        // Replacing CustomQueue with built-in Queue (ArrayDeque)
        System.out.println("\n[Built-in Replacement: java.util.Queue<Order> via ArrayDeque]");
        Queue<Order> builtInQueue = new ArrayDeque<>();
        for (int i = 0; i < 3; i++) {
            builtInQueue.offer(sampleOrders.get(i));
        }
        System.out.printf("  Built-in Queue front order: %s%n", builtInQueue.peek());
        System.out.printf("  Dispatched via poll(): %s%n", builtInQueue.poll());

        // -------------------------------------------------------------------------
        // PART 3: EMPIRICAL PERFORMANCE BENCHMARK (100,000 OPERATIONS)
        // -------------------------------------------------------------------------
        System.out.println("\n-------------------------------------------------------------------------");
        System.out.println("--- Part 3: Empirical Benchmark (100,000 Operations Each) ---");
        System.out.println("-------------------------------------------------------------------------");
        int ops = 100_000;

        // Custom Stack Benchmark
        CustomStack<Integer> cs = new CustomStack<>();
        long start = System.nanoTime();
        for (int i = 0; i < ops; i++) cs.push(i);
        for (int i = 0; i < ops; i++) cs.pop();
        long customStackNanos = System.nanoTime() - start;

        // Built-in ArrayDeque (as Stack) Benchmark
        Deque<Integer> adStack = new ArrayDeque<>();
        start = System.nanoTime();
        for (int i = 0; i < ops; i++) adStack.push(i);
        for (int i = 0; i < ops; i++) adStack.pop();
        long builtInStackNanos = System.nanoTime() - start;

        // Legacy java.util.Stack (Synchronized Vector)
        Stack<Integer> legacyStack = new Stack<>();
        start = System.nanoTime();
        for (int i = 0; i < ops; i++) legacyStack.push(i);
        for (int i = 0; i < ops; i++) legacyStack.pop();
        long legacyStackNanos = System.nanoTime() - start;

        // Custom Queue Benchmark
        CustomQueue<Integer> cq = new CustomQueue<>();
        start = System.nanoTime();
        for (int i = 0; i < ops; i++) cq.enqueue(i);
        for (int i = 0; i < ops; i++) cq.dequeue();
        long customQueueNanos = System.nanoTime() - start;

        // Built-in ArrayDeque (as Queue) Benchmark
        Queue<Integer> adQueue = new ArrayDeque<>();
        start = System.nanoTime();
        for (int i = 0; i < ops; i++) adQueue.offer(i);
        for (int i = 0; i < ops; i++) adQueue.poll();
        long builtInQueueNanos = System.nanoTime() - start;

        // Built-in LinkedList (as Queue) Benchmark
        Queue<Integer> llQueue = new LinkedList<>();
        start = System.nanoTime();
        for (int i = 0; i < ops; i++) llQueue.offer(i);
        for (int i = 0; i < ops; i++) llQueue.poll();
        long linkedListQueueNanos = System.nanoTime() - start;

        System.out.println("+---------------------------------------+---------------------+-------------------+");
        System.out.println("| Data Structure / Implementation       | Time (100k ops)     | Relative Speed    |");
        System.out.println("+---------------------------------------+---------------------+-------------------+");
        System.out.printf("| CustomStack (Dynamic Array)           | %10.2f ms       | Baseline          |%n", customStackNanos / 1e6);
        System.out.printf("| Built-in ArrayDeque (as Stack)        | %10.2f ms       | %5.2fx faster     |%n",
                builtInStackNanos / 1e6, (double) customStackNanos / builtInStackNanos);
        System.out.printf("| Legacy java.util.Stack (Synchronized) | %10.2f ms       | %5.2fx slower     |%n",
                legacyStackNanos / 1e6, (double) legacyStackNanos / customStackNanos);
        System.out.printf("| CustomQueue (Circular Array)          | %10.2f ms       | Baseline          |%n", customQueueNanos / 1e6);
        System.out.printf("| Built-in ArrayDeque (as Queue)        | %10.2f ms       | %5.2fx faster     |%n",
                builtInQueueNanos / 1e6, (double) customQueueNanos / builtInQueueNanos);
        System.out.printf("| Built-in LinkedList (as Queue)        | %10.2f ms       | %5.2fx slower     |%n",
                linkedListQueueNanos / 1e6, (double) linkedListQueueNanos / customQueueNanos);
        System.out.println("+---------------------------------------+---------------------+-------------------+");

        System.out.println("\n--- Architectural Comparison & Takeaways ---");
        System.out.println("1. Stack Implementation:");
        System.out.println("   - CustomStack uses dynamic array resizing with geometric growth, giving O(1) amortized push/pop.");
        System.out.println("   - Java's legacy `java.util.Stack` inherits from `Vector` where every method is synchronized.");
        System.out.println("     This synchronization adds unnecessary lock contention and performance overhead in single-threaded tasks.");
        System.out.println("   - `ArrayDeque` is the recommended modern replacement for Stack in Java, delivering peak cache locality.");
        System.out.println("2. Queue Implementation:");
        System.out.println("   - CustomQueue uses circular modular arithmetic ((tail+1)%length), avoiding O(n) array shift costs.");
        System.out.println("   - Built-in `ArrayDeque` uses bitwise mask circular buffering (power-of-two capacity), which is ultra-fast.");
        System.out.println("   - Built-in `LinkedList` allocates a new Node object per enqueue, leading to heavy GC pressure & pointer indirection.\n");
    }
}
