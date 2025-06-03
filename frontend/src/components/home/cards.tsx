// create a card which displays the title and name of the object

import { getProposalDetails, VoteNft } from "@/lib/suiUtils";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useState } from "react";
import { formatUnixTimestamp, isExpired } from "@/lib/utils";
import { VoteModal } from "./VoteModal";

export function ObjectCard({
  id,
  hasVoted,
  voteNft,
  refetchDashboard,
  refetchVoteNfts,
  isLoadingVoteNfts,
  isLoadingDashboard,
}: {
  id: string;
  hasVoted: boolean;
  voteNft: VoteNft | undefined;
  refetchDashboard: () => void;
  refetchVoteNfts: () => void;
  isLoadingVoteNfts: boolean;
  isLoadingDashboard: boolean;
}) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { data: proposals, refetch: refetchProposal } = useSuiClientQuery(
    "getObject",
    {
      id: id,
      options: {
        showContent: true,
      },
    }
  );
  if (!proposals || !proposals.data) return null;
  const proposalDetails = getProposalDetails(proposals.data);
  if (!proposalDetails) return null;

  const hasExpired = isExpired(proposalDetails?.expiration);

  return (
    <>
      <div
        className="bg-white rounded-lg shadow-md p-4 hover:shadow-lg transition-shadow w-[20rem] cursor-pointer"
        onClick={() => setIsModalOpen(true)}
      >
        {hasExpired && <p className="text-red-500 text-sm mb-2">Expired</p>}
        {/* <h1 className="text-xl font-bold text-gray-800 mb-2 break-words">{id}</h1> */}
        <div className="flex justify-between">
          <h2 className="text-xl font-bold text-gray-800 mb-2">
            {proposalDetails?.title}
          </h2>
          {voteNft && (
            <img
              src={voteNft?.url}
              alt="Vote NFT"
              className="w-10 h-10 rounded-full "
            />
          )}
        </div>
        <p className="text-gray-600">{proposalDetails?.description}</p>
        <p className="text-gray-600">
          👍 {proposalDetails?.voted_yes_count} 👎{" "}
          {proposalDetails?.voted_no_count}
        </p>
        <p className="text-gray-600">
          Expiration:{" "}
          {proposalDetails?.expiration
            ? formatUnixTimestamp(proposalDetails.expiration)
            : ""}
        </p>
        {/* <p className="text-gray-600">Creator: {proposalDetails?.creator}</p> */}
        <p className="text-gray-600">
          Voting Registry: {proposalDetails?.voting_registry}
        </p>
      </div>
      {isModalOpen && proposalDetails && !hasExpired && (
        <VoteModal
          id={id}
          onClose={() => setIsModalOpen(false)}
          isModalOpen={isModalOpen}
          proposalDetails={proposalDetails}
          onVote={(vote: boolean) => {
            setIsModalOpen(false);
            console.log("VotedYes", vote);
            refetchDashboard();
            refetchVoteNfts();
            refetchProposal();
          }}
          hasVoted={hasVoted}
          isLoadingVoteNfts={isLoadingVoteNfts}
          isLoadingDashboard={isLoadingDashboard}
        />
      )}
    </>
  );
}
