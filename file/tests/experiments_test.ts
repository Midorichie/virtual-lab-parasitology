import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.5.4/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensures experiment creation with proper authorization",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const deployer = accounts.get("deployer")!;
        const researcher = accounts.get("wallet_1")!;
        
        // Register researcher first
        let block = chain.mineBlock([
            Tx.contractCall("laboratory", "register-researcher", 
                [types.ascii("Parasitology")], 
                researcher.address
            )
        ]);
        assertEquals(block.receipts[0].result.expectOk(), true);
        
        // Create experiment
        block = chain.mineBlock([
            Tx.contractCall("experiments", "create-experiment", [
                types.ascii("Plasmodium falciparum"),
                types.ascii("Human RBC"),
                types.utf8("Standard malaria culture protocol")
            ], researcher.address)
        ]);
        
        block.receipts[0].result.expectOk().expectUint(1);
        
        // Verify experiment details
        const experimentResult = chain.callReadOnlyFn(
            "experiments",
            "get-experiment",
            [types.uint(1)],
            researcher.address
        );
        
        const experiment = experimentResult.result.expectSome().expectTuple();
        assertEquals(experiment['researcher'], researcher.address);
        assertEquals(experiment['status'], types.ascii("INITIATED"));
    }
});

Clarinet.test({
    name: "Prevents unauthorized experiment creation",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const unauthorized = accounts.get("wallet_2")!;
        
        let block = chain.mineBlock([
            Tx.contractCall("experiments", "create-experiment", [
                types.ascii("Plasmodium falciparum"),
                types.ascii("Human RBC"),
                types.utf8("Standard malaria culture protocol")
            ], unauthorized.address)
        ]);
        
        block.receipts[0].result.expectErr().expectUint(401);
    }
});

Clarinet.test({
    name: "Validates experiment status transitions",
    async fn(chain: Chain, accounts: Map<string, Account>) {
        const researcher = accounts.get("wallet_1")!;
        
        // Register and create experiment
        let block = chain.mineBlock([
            Tx.contractCall("laboratory", "register-researcher", 
                [types.ascii("Parasitology")], 
                researcher.address
            ),
            Tx.contractCall("experiments", "create-experiment", [
                types.ascii("Test Parasite"),
                types.ascii("Test Host"),
                types.utf8("Test Protocol")
            ], researcher.address)
        ]);
        
        // Test valid transition
        block = chain.mineBlock([
            Tx.contractCall("experiments", "update-experiment-status", [
                types.uint(1),
                types.ascii("IN_PROGRESS"),
                types.none()
            ], researcher.address)
        ]);
        block.receipts[0].result.expectOk().expectBool(true);
        
        // Test invalid transition
        block = chain.mineBlock([
            Tx.contractCall("experiments", "update-experiment-status", [
                types.uint(1),
                types.ascii("COMPLETED"),
                types.none()
            ], researcher.address)
        ]);
        block.receipts[0].result.expectErr();
    }
});
