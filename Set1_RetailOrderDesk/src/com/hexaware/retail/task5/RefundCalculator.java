package com.hexaware.retail.task5;

import java.util.*;

/**
 * Task 5: Refund Coin/Note Minimization - Greedy vs Dynamic Programming
 * - Solves standard refund amounts using the Greedy approach on canonical currency systems.
 * - Demonstrates explicit denomination sets where Greedy fails.
 * - Implements Dynamic Programming (Bottom-Up Tabulation) to guarantee optimal coin change.
 */
public class RefundCalculator {

    public static class ChangeResult {
        public final int totalCoins;
        public final Map<Integer, Integer> coinCounts; // coin -> count
        public final List<Integer> coinsUsed;
        public final boolean isOptimal;

        public ChangeResult(int totalCoins, Map<Integer, Integer> coinCounts, List<Integer> coinsUsed, boolean isOptimal) {
            this.totalCoins = totalCoins;
            this.coinCounts = coinCounts;
            this.coinsUsed = coinsUsed;
            this.isOptimal = isOptimal;
        }

        @Override
        public String toString() {
            StringBuilder sb = new StringBuilder();
            sb.append("Total: ").append(totalCoins).append(" coins/notes [");
            for (Map.Entry<Integer, Integer> entry : coinCounts.entrySet()) {
                sb.append(entry.getValue()).append("x$").append(entry.getKey()).append(" ");
            }
            sb.append("]");
            return sb.toString().trim();
        }
    }

    /**
     * Greedy Approach:
     * Iteratively selects the largest available denomination less than or equal to the remaining amount.
     * Time Complexity: O(k log k) to sort denominations + O(k) selection = O(k)
     * Space Complexity: O(k) for breakdown map.
     */
    public static ChangeResult computeGreedyChange(int[] denominations, int amount) {
        // Sort descending
        int[] sorted = Arrays.stream(denominations).boxed()
                .sorted(Collections.reverseOrder())
                .mapToInt(Integer::intValue)
                .toArray();

        int remaining = amount;
        int totalCoins = 0;
        Map<Integer, Integer> breakdown = new LinkedHashMap<>();
        List<Integer> coinsList = new ArrayList<>();

        for (int coin : sorted) {
            if (remaining >= coin) {
                int count = remaining / coin;
                totalCoins += count;
                remaining %= coin;
                breakdown.put(coin, count);
                for (int i = 0; i < count; i++) {
                    coinsList.add(coin);
                }
            }
        }

        if (remaining != 0) {
            // Cannot make change with greedy
            return new ChangeResult(-1, breakdown, coinsList, false);
        }

        return new ChangeResult(totalCoins, breakdown, coinsList, false);
    }

    /**
     * Dynamic Programming Approach (Bottom-Up Tabulation):
     * Guarantees global minimum coin count regardless of denomination canonicality.
     *
     * Recurrence:
     *   dp[0] = 0
     *   dp[i] = min_{c in coins, c <= i} (1 + dp[i - c])
     *
     * Time Complexity: O(amount * k), where k = number of denominations.
     * Space Complexity: O(amount) for DP table and backtracking path.
     */
    public static ChangeResult computeDpChange(int[] denominations, int amount) {
        int[] dp = new int[amount + 1];
        int[] lastCoin = new int[amount + 1];
        Arrays.fill(dp, Integer.MAX_VALUE - 1);
        Arrays.fill(lastCoin, -1);
        dp[0] = 0;

        for (int i = 1; i <= amount; i++) {
            for (int coin : denominations) {
                if (coin <= i && dp[i - coin] + 1 < dp[i]) {
                    dp[i] = dp[i - coin] + 1;
                    lastCoin[i] = coin;
                }
            }
        }

        if (dp[amount] >= Integer.MAX_VALUE - 1) {
            return new ChangeResult(-1, Collections.emptyMap(), Collections.emptyList(), true);
        }

        // Reconstruct coins used
        Map<Integer, Integer> breakdown = new LinkedHashMap<>();
        List<Integer> coinsList = new ArrayList<>();
        int curr = amount;
        while (curr > 0) {
            int coin = lastCoin[curr];
            coinsList.add(coin);
            breakdown.put(coin, breakdown.getOrDefault(coin, 0) + 1);
            curr -= coin;
        }

        return new ChangeResult(dp[amount], breakdown, coinsList, true);
    }

    public static void runRefundDemo() {
        System.out.println("================================================================================");
        System.out.println("   TASK 5: REFUND COIN/NOTE MINIMIZATION (GREEDY VS DYNAMIC PROGRAMMING)");
        System.out.println("================================================================================");

        // Scenario A: Standard / Canonical Currency System (Greedy is Optimal)
        System.out.println("--- Scenario A: Standard Currency System (Greedy Works Optimally) ---");
        int[] standardDenominations = {2000, 500, 200, 100, 50, 20, 10, 5, 2, 1};
        int refundAmountA = 3887;

        ChangeResult greedyA = computeGreedyChange(standardDenominations, refundAmountA);
        ChangeResult dpA = computeDpChange(standardDenominations, refundAmountA);

        System.out.printf("Refund Amount: $%d%n", refundAmountA);
        System.out.println("Available Denominations: " + Arrays.toString(standardDenominations));
        System.out.printf("  Greedy Result : %s%n", greedyA);
        System.out.printf("  DP Result     : %s%n", dpA);
        System.out.println("  Conclusion    : In standard currency, Greedy achieves the provable global optimum.\n");

        // Scenario B: Non-Canonical Denominations (WHERE GREEDY FAILS)
        System.out.println("--- Scenario B: Non-Canonical Denominations (WHERE GREEDY FAILS) ---");
        int[] nonCanonical = {1, 3, 4};
        int refundAmountB = 6;

        System.out.printf("Denomination Set: %s%n", Arrays.toString(nonCanonical));
        System.out.printf("Target Refund Amount: $%d%n", refundAmountB);

        ChangeResult greedyB = computeGreedyChange(nonCanonical, refundAmountB);
        ChangeResult dpB = computeDpChange(nonCanonical, refundAmountB);

        System.out.println("\n1. Greedy Step-by-Step Execution:");
        System.out.println("   - Remaining amount: $6. Largest coin <= 6 is 4. Pick 1x $4. Remaining: $2.");
        System.out.println("   - Remaining amount: $2. Largest coin <= 2 is 1. Pick 1x $1. Remaining: $1.");
        System.out.println("   - Remaining amount: $1. Largest coin <= 1 is 1. Pick 1x $1. Remaining: $0.");
        System.out.printf("   => GREEDY RESULT: %d coins %s%n", greedyB.totalCoins, greedyB.coinsUsed);

        System.out.println("\n2. Dynamic Programming Optimal Execution:");
        System.out.println("   - DP explores subproblems: dp[6] = 1 + dp[6 - 3] = 1 + dp[3] = 1 + 1 = 2 coins ($3 + $3).");
        System.out.printf("   => DP OPTIMAL RESULT: %d coins %s%n", dpB.totalCoins, dpB.coinsUsed);

        System.out.println("\n+---------------------+-------------------+---------------------+---------------+");
        System.out.println("| Algorithm           | Coins Used        | Total Coins Count   | Optimality    |");
        System.out.println("+---------------------+-------------------+---------------------+---------------+");
        System.out.printf("| Greedy Approach     | %-17s | %-19d | SUB-OPTIMAL   |%n", greedyB.coinsUsed, greedyB.totalCoins);
        System.out.printf("| Dynamic Programming | %-17s | %-19d | OPTIMAL       |%n", dpB.coinsUsed, dpB.totalCoins);
        System.out.println("+---------------------+-------------------+---------------------+---------------+");

        // Scenario C: Another Classic Counterexample: [1, 5, 6, 9], Amount = 11
        int[] nonCanonical2 = {1, 5, 6, 9};
        int refundAmountC = 11;
        ChangeResult greedyC = computeGreedyChange(nonCanonical2, refundAmountC);
        ChangeResult dpC = computeDpChange(nonCanonical2, refundAmountC);

        System.out.println("\nAdditional Counterexample: Denominations [1, 5, 6, 9], Amount = $11:");
        System.out.printf("  Greedy picks: %s (Total: %d coins) [Picks 9, then 1, 1]%n", greedyC.coinsUsed, greedyC.totalCoins);
        System.out.printf("  DP picks    : %s (Total: %d coins) [Picks 6 and 5]%n", dpC.coinsUsed, dpC.totalCoins);

        System.out.println("\n--- Complexity & Algorithmic Rationale ---");
        System.out.println("1. Greedy Algorithm: Time O(k), Space O(1).");
        System.out.println("   - Extremely fast and memory-efficient.");
        System.out.println("   - Only optimal when the denomination system is 'canonical' (satisfies matroid greedy-choice property).");
        System.out.println("2. Dynamic Programming: Time O(amount * k), Space O(amount).");
        System.out.println("   - Evaluates overlapping subproblems via optimal substructure.");
        System.out.println("   - Guaranteed to find the true global minimum for ANY arbitrary set of currency denominations.\n");
    }
}
