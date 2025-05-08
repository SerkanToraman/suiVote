import { SuiObjectData } from "@mysten/sui/client";

export type ProposalDetails = {
  id: string;
  title: string;
  description: string;
  voted_yes_count: number;
  voted_no_count: number;
  expiration: number;
  creator: string;
  voting_registry: string[];
};

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
