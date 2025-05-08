// create a modal when clicked on a card
import type { ProposalDetails } from "@/lib/suiUtils";

export function Modal({
  id,
  onClose,
  proposalDetails,
  onVote,
}: {
  id: string;
  onClose: () => void;
  proposalDetails: ProposalDetails;
  onVote: (vote: boolean) => void;
}) {
  return (
    <div
      className="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50"
      onClick={onClose}
    >
      <div
        className="bg-white rounded-lg p-4 w-[30rem] max-w-xl max-h-[80vh] overflow-y-auto relative"
        onClick={(e) => e.stopPropagation()}
      >
        <button
          onClick={onClose}
          className="absolute top-2 right-2 text-gray-500 hover:text-gray-700"
        >
          ✕
        </button>

        <div className="mt-2">
          <h2 className="text-xl font-bold text-black mb-3">
            {proposalDetails.title}
          </h2>
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
            <div className="flex gap-3 justify-between">
              <button
                className="bg-green-500 w-full text-white px-3 py-1.5 rounded-lg"
                onClick={() => {
                  onVote(true);
                }}
              >
                Vote Yes
              </button>
              <button
                className="bg-red-500 w-full text-white px-3 py-1.5 rounded-lg"
                onClick={() => {
                  onVote(false);
                }}
              >
                Vote No
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
