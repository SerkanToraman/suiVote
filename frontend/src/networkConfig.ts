import { getFullnodeUrl } from "@mysten/sui/client";
import { createNetworkConfig } from "@mysten/dapp-kit";
import {
  DEVNET_DASHBOARD_ID,
  DEVNET_PACKAGE_ID,
  MAINNET_DASHBOARD_ID,
  MAINNET_PACKAGE_ID,
  TESTNET_PACKAGE_ID,
} from "./constants";
import { TESTNET_DASHBOARD_ID } from "./constants";

const { networkConfig, useNetworkVariable, useNetworkVariables } =
  createNetworkConfig({
    devnet: {
      url: getFullnodeUrl("devnet"),
      variables: {
        dashboardId: DEVNET_DASHBOARD_ID,
        packageId: DEVNET_PACKAGE_ID,
      },
    },
    testnet: {
      url: getFullnodeUrl("testnet"),
      variables: {
        dashboardId: TESTNET_DASHBOARD_ID,
        packageId: TESTNET_PACKAGE_ID,
      },
    },
    mainnet: {
      url: getFullnodeUrl("mainnet"),
      variables: {
        dashboardId: MAINNET_DASHBOARD_ID,
        packageId: MAINNET_PACKAGE_ID,
      },
    },
  });

export { useNetworkVariable, useNetworkVariables, networkConfig };
