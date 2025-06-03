// create a modal when clicked on a card
import type { ProposalDetails } from "@/lib/suiUtils";
import { useNetworkVariable } from "@/networkConfig";
import {
  useCurrentWallet,
  useSignAndExecuteTransaction,
  useSuiClient,
} from "@mysten/dapp-kit";
import { voteContract } from "@/lib/contracts";

export function VoteModal({
  id,
  onClose,
  proposalDetails,
  isModalOpen,
  onVote,
  hasVoted,
  isLoadingVoteNfts,
  isLoadingDashboard,
}: {
  id: string;
  onClose: () => void;
  isModalOpen: boolean;
  proposalDetails: ProposalDetails;
  onVote: (vote: boolean) => void;
  hasVoted: boolean;
  isLoadingVoteNfts: boolean;
  isLoadingDashboard: boolean;
}) {
  const { connectionStatus } = useCurrentWallet();
  const suiClient = useSuiClient();
  const packageId = useNetworkVariable("packageId");
  const {
    mutate: signAndExecuteTransaction,
    isPending,
    reset,
  } = useSignAndExecuteTransaction();

  if (!isModalOpen) return null;

  const vote = (voteYes: boolean) => {
    const tx = voteContract(packageId, proposalDetails.id.id, voteYes);
    signAndExecuteTransaction(
      { transaction: tx },
      {
        onError: () => {
          alert("Error voting");
        },
        onSuccess: async ({ digest }) => {
          const { effects } = await suiClient.waitForTransaction({
            digest,
            options: {
              showEffects: true,
            },
          });
          const eventResult = await suiClient.queryEvents({
            query: {
              Transaction: digest,
            },
          });
          if (eventResult.data.length > 0) {
            const firstEvent = eventResult.data[0].parsedJson as {
              proposal_id: string;
              voter: string;
              vote_yes: boolean;
            };
            console.log("event", firstEvent);
          }
          onVote(voteYes);
          reset();
          console.log("effects", effects);
        },
      }
    );
  };

  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      onClick={onClose}
    >
      {isLoadingVoteNfts || isLoadingDashboard ? (
        <div className="flex items-center justify-center">
          <div className="animate-spin rounded-full h-12 w-12 border-t-2 border-b-2 border-gray-900"></div>
        </div>
      ) : (
        <div
          className="bg-white rounded-lg p-4 w-[30rem] max-w-xl max-h-[80vh] overflow-y-auto relative"
          onClick={(e) => e.stopPropagation()}
        >
          <div className="mt-2">
            <div className="flex justify-between">
              <h2 className="text-xl font-bold text-black mb-3">
                {proposalDetails.title}
              </h2>
              {hasVoted ? (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-green-100 text-green-800">
                  Voted
                </span>
              ) : (
                <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-red-100 text-red-800">
                  Not Voted
                </span>
              )}
            </div>
            <div className="space-y-3">
              <p className="text-gray-700">{proposalDetails.description}</p>

              <div className="flex gap-3 justify-between">
                <div className="bg-green-100 p-2 rounded-lg">
                  <p className="text-gray-700">
                    👍 Yes: {proposalDetails.voted_yes_count}
                  </p>
                </div>
                <div className="bg-red-100 p-2 rounded-lg">
                  <p className="text-gray-700">
                    👎 No: {proposalDetails.voted_no_count}
                  </p>
                </div>
              </div>
              {/* Buttons to vote yes or no */}
              {connectionStatus === "connected" && !hasVoted ? (
                <div className="flex gap-3 justify-between">
                  <button
                    className={`bg-green-500 w-full text-white px-3 py-1.5 rounded-lg ${
                      isPending ? "opacity-50 cursor-not-allowed" : ""
                    }`}
                    onClick={() => {
                      vote(true);
                    }}
                    disabled={isPending}
                  >
                    {isPending ? "Voting..." : "Vote Yes"}
                  </button>
                  <button
                    className={`bg-red-500 w-full text-white px-3 py-1.5 rounded-lg ${
                      isPending ? "opacity-50 cursor-not-allowed" : ""
                    }`}
                    onClick={() => {
                      vote(false);
                    }}
                    disabled={isPending}
                  >
                    {isPending ? "Voting..." : "Vote No"}
                  </button>
                </div>
              ) : connectionStatus === "connected" ? (
                <></>
              ) : (
                <p className="text-gray-700">
                  Please connect your wallet to vote
                </p>
              )}
            </div>
            <div className="mt-4 flex justify-end">
              <button
                type="button"
                onClick={onClose}
                className="w-full inline-flex justify-center rounded-md border border-gray-300 bg-white px-4 py-2 text-sm font-medium text-gray-700 shadow-sm hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-indigo-500 focus:ring-offset-2"
              >
                Cancel
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
