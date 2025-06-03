import { WalletStatus } from "./WalletStatus";
import { useNetworkVariable } from "../../networkConfig";
import {
  getDashboardProposalIds,
  extractVoteNfts,
  checkIfVotedNft,
} from "../../lib/suiUtils";
// import { OwnedObjects } from "./OwnedObjects";
import { ObjectCard } from "./cards";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useVoteNfts } from "../../hooks/useVoteNfts";

function HomePage() {
  const dashboardId = useNetworkVariable("dashboardId");

  const {
    data: voteNfts,
    refetch: refetchVoteNfts,
    isLoading: isLoadingVoteNfts,
  } = useVoteNfts();

  const voteNftsData = voteNfts ? extractVoteNfts(voteNfts) : [];

  console.log("voteNftsData", voteNftsData);

  const {
    data: dashboard,
    refetch: refetchDashboard,
    isLoading: isLoadingDashboard,
  } = useSuiClientQuery("getObject", {
    id: dashboardId,
    options: {
      showContent: true,
    },
  });

  if (!dashboard || !dashboard.data) return null;

  const objectIds = getDashboardProposalIds(dashboard.data)?.proposals_ids;

  console.log("objectIds", objectIds);

  return (
    <div className="flex-1 overflow-auto mt-[57px] py-2 w-[70%] mx-auto">
      <WalletStatus />
      {/* <OwnedObjects /> */}
      {/* Proposals */}
      <div className="flex flex-wrap gap-4">
        {objectIds?.map((id, index) => (
          <ObjectCard
            key={index}
            id={id}
            hasVoted={checkIfVotedNft(voteNftsData, id)}
            voteNft={voteNftsData.find((nft) => nft.proposalId === id)}
            refetchDashboard={refetchDashboard}
            refetchVoteNfts={refetchVoteNfts}
            isLoadingVoteNfts={isLoadingVoteNfts}
            isLoadingDashboard={isLoadingDashboard}
          />
        ))}
      </div>
    </div>
  );
}

export default HomePage;
