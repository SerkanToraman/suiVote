import { useCurrentAccount, useSuiClientQuery } from "@mysten/dapp-kit";

export function OwnedObjects() {
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

  if (!account) {
    return;
  }

  if (error) {
    return <div className="flex">Error: {error.message}</div>;
  }

  if (isPending || !data) {
    return <div className="flex">Loading...</div>;
  }

  return (
    <div className="flex flex-col my-2">
      {data.data.length === 0 ? (
        <p className="text-gray-500">No objects owned by the connected wallet</p>
      ) : (
        <h2 className="text-xl font-bold">Objects owned by the connected wallet</h2>
      )}
      {data.data.map((object) => (
        <div key={object.data?.objectId} className="flex">
          <p className="text-gray-500">Object ID: {object.data?.objectId}</p>
        </div>
      ))}
    </div>
  );
}
