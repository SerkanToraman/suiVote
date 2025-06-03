import { useNetworkVariable } from "@/networkConfig";
import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";

export const useVoteNfts = () => {
  const account = useCurrentAccount();
  const packadeId = useNetworkVariable("packageId");

  return useSuiClientQuery(
    "getOwnedObjects",
    {
      owner: account?.address as string,
      options: {
        showContent: true,
      },
      filter: {
        StructType: `${packadeId}::proposal::VoteProofNFT`,
      },
    },
    {
      enabled: !!account,
    }
  );
};
