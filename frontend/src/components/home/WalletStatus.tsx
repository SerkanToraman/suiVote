import { useCurrentAccount } from "@mysten/dapp-kit";

export function WalletStatus() {
  const account = useCurrentAccount();

  return (
    <div className="my-2 w-full">
      <h2 className="mb-2">Wallet Status</h2>

      {account ? (
        <div className="flex flex-col">
          <p>Wallet connected</p>
          <p>Address: {account.address}</p>
        </div>
      ) : (
        <p>Wallet not connected</p>
      )}
    </div>
  );
}
