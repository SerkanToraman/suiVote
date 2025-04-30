import { useState } from "react";
import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";
import { WalletStatus } from "./components/WalletStatus";
import { ConnectButton } from "@mysten/dapp-kit";

function App() {
  const [count, setCount] = useState(0);

  const account = useCurrentAccount();

  const { data, isPending, error } = useSuiClientQuery(
    "getOwnedObjects",
    {
      owner: account?.address as string,
    },
    {
      enabled: !!account,
    }
  );

  console.log(data);

  return (
    <>
      <div className="sticky top-0 flex justify-between px-4 py-2 border-b border-gray-200">
        <div>
          <h1 className="text-2xl font-bold">My dApp</h1>
        </div>

        <div>
          <ConnectButton connectText="Connect Wallet" />
        </div>
      </div>

      <div className="container mx-auto">
        <div className="mt-5 pt-2 px-4 min-h-[500px] bg-gray-100">
          <WalletStatus />
        </div>
      </div>
    </>
  );
}

export default App;
