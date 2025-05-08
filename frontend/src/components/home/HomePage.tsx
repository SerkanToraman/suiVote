import { WalletStatus } from "./WalletStatus";
import { useNetworkVariable } from "../../networkConfig";
import { getDashboardProposalIds } from "../../lib/suiUtils";
// import { OwnedObjects } from "./OwnedObjects";
import { ObjectCard } from "./cards";
import { useSuiClientQuery } from "@mysten/dapp-kit";
function HomePage() {
  const dashboardId = useNetworkVariable("dashboardId");
  console.log("dashboardId", dashboardId);

  const { data: dashboard } = useSuiClientQuery("getObject", {
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
          <ObjectCard key={index} id={id} />
        ))}
      </div>
    </div>
  );
}

export default HomePage;
