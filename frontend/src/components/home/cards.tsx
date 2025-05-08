// create a card which displays the title and name of the object

import { getProposalDetails } from "@/lib/suiUtils";
import { useSuiClientQuery } from "@mysten/dapp-kit";
import { useState } from "react";
import { formatUnixTimestamp, isExpired } from "@/lib/utils";
import { Modal } from "./modal";

export function ObjectCard({ id }: { id: string }) {
  const [isModalOpen, setIsModalOpen] = useState(false);
  const { data: proposals } = useSuiClientQuery("getObject", {
    id: id,
    options: {
      showContent: true,
    },
  });
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
        <h2 className="text-xl font-bold text-gray-800 mb-2">
          {proposalDetails?.title}
        </h2>
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
        <Modal
          id={id}
          onClose={() => setIsModalOpen(false)}
          proposalDetails={proposalDetails}
          onVote={(vote: boolean) => {
            console.log("VotedYes", vote);
          }}
        />
      )}
    </>
  );
}
