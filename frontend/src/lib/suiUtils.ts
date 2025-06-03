import { PaginatedObjectsResponse, SuiObjectData } from "@mysten/sui/client";

export type ProposalDetails = {
  id: SuiID;
  title: string;
  description: string;
  voted_yes_count: number;
  voted_no_count: number;
  expiration: number;
  creator: string;
  voting_registry: string[];
};

export interface VoteNft {
  id: SuiID;
  proposalId: string;
  url: string;
}

export const getDashboardProposalIds = (data: SuiObjectData) => {
  if (data.content?.dataType !== "moveObject") return null;
  return data.content.fields as {
    id: SuiID;
    proposals_ids: string[];
  };
};

export const getProposalDetails = (
  data: SuiObjectData
): ProposalDetails | null => {
  if (data.content?.dataType !== "moveObject") return null;

  const { voted_yes_count, voted_no_count, expiration, ...rest } = data.content
    .fields as ProposalDetails;

  return {
    voted_yes_count: Number(voted_yes_count),
    voted_no_count: Number(voted_no_count),
    expiration: Number(expiration),
    ...rest,
  };
};
export const checkIfVotedNft = (nftData: VoteNft[], proposalId: string) => {
  return nftData.some((nft) => nft.proposalId === proposalId);
};

export function extractVoteNfts(nftResponse: PaginatedObjectsResponse) {
  if (nftResponse.data.length === 0) return [];

  return nftResponse.data.map((nftObject) => {
    return getVoteNft(nftObject.data);
  });
}

function getVoteNft(nftData: SuiObjectData | undefined | null): VoteNft {
  console.log("nftData", nftData);
  if (nftData?.content?.dataType !== "moveObject")
    return {
      id: {
        id: "",
      },
      proposalId: "",
      url: "",
    } as VoteNft;

  const { proposal_id: proposalId, url, id } = nftData.content.fields as any;

  return {
    proposalId,
    url,
    id,
  } as VoteNft;
}
