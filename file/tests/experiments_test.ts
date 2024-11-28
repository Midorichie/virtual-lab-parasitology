```typescript
import { Clarinet, Tx, Chain, Account, types } from 'https://deno.land/x/clarinet@v1.5.4/index.ts';
import { assertEquals } from 'https://deno.land/std@0.170.0/testing/asserts.ts';

Clarinet.test({
    name: "Ensures that experiment creation works",
    async fn(chain: Chain, accounts: Map) {
        const deployer = accounts.get("deployer")!;
        
        let block = chain.mineBlock([
            Tx.contractCall("experiments", "create-experiment", [
                types.ascii("Plasmodium falciparum"),
                types.ascii("Human RBC"),
                types.utf8("Standard malaria culture protocol")
            ], deployer.address)
        ]);
        
        assertEquals(block.receipts.length, 1);
        assertEquals(block.height, 2);
        
        block.receipts[0].result.expectOk().expectUint(1);
    },
});
```
