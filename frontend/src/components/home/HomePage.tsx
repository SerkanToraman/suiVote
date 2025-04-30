import { WalletStatus } from "./WalletStatus";
import { OwnedObjects } from "./OwnedObjects";
function HomePage() {
  return (
    <div className="flex-1 overflow-auto mt-[57px] py-2">
      <WalletStatus />
      <OwnedObjects />
    </div>
  );
}

export default HomePage;
