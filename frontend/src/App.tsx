import { ConnectButton } from "@mysten/dapp-kit";

//Components
import HomePage from "./components/home/HomePage";

function App() {
  return (
    <div className="h-screen flex flex-col bg-black  text-white">
      <div className="fixed top-0 left-0 right-0 z-20 flex justify-between px-4 py-2 border-b border-gray-200 bg-black">
        <div>
          <h1 className="text-2xl font-bold ">My dApp</h1>
        </div>
        <ConnectButton />
      </div>

      <HomePage />
    </div>
  );
}

export default App;
