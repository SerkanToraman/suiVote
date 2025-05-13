import { Transaction } from "@mysten/sui/transactions";

//Clock needs to be passed as tx.object("0x6")
export const voteContract = (
  packageId: string,
  proposalId: string,
  voteYes: boolean
): Transaction => {
  const tx = new Transaction();
  tx.moveCall({
    target: `${packageId}::proposal::vote`,
    arguments: [tx.object(proposalId), tx.pure.bool(voteYes), tx.object("0x6")],
  });

  return tx;
};
