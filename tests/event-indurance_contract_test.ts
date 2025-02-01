import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.5.4/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensure that event registration works correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        const organizer = accounts.get("wallet_1")!;
        const currentBlock = chain.blockHeight;
        
        let block = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "register-event",
                [
                    types.uint(1), // event-id
                    types.uint(currentBlock + 1000), // event-date
                    types.uint(50000000), // premium-amount (0.05 STX)
                    types.uint(100) // max-participants
                ],
                organizer.address
            )
        ]);
        
        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 2);
        assertEquals(block.receipts[0].result, '(ok true)');
    }
});

Clarinet.test({
    name: "Ensure that insurance purchase works correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const organizer = accounts.get("wallet_1")!;
        const participant = accounts.get("wallet_2")!;
        const currentBlock = chain.blockHeight;
        
        // First register an event
        let block = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "register-event",
                [
                    types.uint(1),
                    types.uint(currentBlock + 1000),
                    types.uint(50000000),
                    types.uint(100)
                ],
                organizer.address
            )
        ]);
        
        // Then purchase insurance
        let purchaseBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "purchase-insurance",
                [types.uint(1)],
                participant.address
            )
        ]);
        
        assertEquals(purchaseBlock.receipts.length, 1);
        assertEquals(purchaseBlock.receipts[0].result, '(ok true)');
    }
});

Clarinet.test({
    name: "Ensure event cancellation and claims work correctly",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const organizer = accounts.get("wallet_1")!;
        const participant = accounts.get("wallet_2")!;
        const currentBlock = chain.blockHeight;
        
        // Setup: Register event and purchase insurance
        let setupBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "register-event",
                [
                    types.uint(1),
                    types.uint(currentBlock + 1000),
                    types.uint(50000000),
                    types.uint(100)
                ],
                organizer.address
            ),
            Tx.contractCall(
                "event-insurance",
                "purchase-insurance",
                [types.uint(1)],
                participant.address
            )
        ]);
        
        // Cancel event
        let cancelBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "cancel-event",
                [types.uint(1)],
                organizer.address
            )
        ]);
        
        // Claim insurance
        let claimBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "claim-insurance",
                [types.uint(1)],
                participant.address
            )
        ]);
        
        assertEquals(cancelBlock.receipts[0].result, '(ok true)');
        assertEquals(claimBlock.receipts[0].result, '(ok true)');
    }
});

Clarinet.test({
    name: "Ensure proper error handling for invalid operations",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const organizer = accounts.get("wallet_1")!;
        const participant = accounts.get("wallet_2")!;
        const unauthorized = accounts.get("wallet_3")!;
        const currentBlock = chain.blockHeight;
        
        // Try to purchase insurance for non-existent event
        let invalidPurchaseBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "purchase-insurance",
                [types.uint(999)],
                participant.address
            )
        ]);
        
        // Try unauthorized event cancellation
        let invalidCancelBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "cancel-event",
                [types.uint(1)],
                unauthorized.address
            )
        ]);
        
        assertEquals(invalidPurchaseBlock.receipts[0].result, '(err u4)'); // ERR_EVENT_NOT_FOUND
        assertEquals(invalidCancelBlock.receipts[0].result, '(err u1)'); // ERR_UNAUTHORIZED
    }
});

Clarinet.test({
    name: "Ensure proper validation of event dates and amounts",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const organizer = accounts.get("wallet_1")!;
        const currentBlock = chain.blockHeight;
        
        // Try to register event with past date
        let invalidDateBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "register-event",
                [
                    types.uint(1),
                    types.uint(currentBlock - 1000), // Past date
                    types.uint(50000000),
                    types.uint(100)
                ],
                organizer.address
            )
        ]);
        
        // Try to register event with zero premium
        let invalidAmountBlock = chain.mineBlock([
            Tx.contractCall(
                "event-insurance",
                "register-event",
                [
                    types.uint(2),
                    types.uint(currentBlock + 1000),
                    types.uint(0), // Zero premium
                    types.uint(100)
                ],
                organizer.address
            )
        ]);
        
        assertEquals(invalidDateBlock.receipts[0].result, '(err u9)'); // ERR_INVALID_DATE
        assertEquals(invalidAmountBlock.receipts[0].result, '(err u2)'); // ERR_INVALID_AMOUNT
    }
});