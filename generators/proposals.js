import {
  TESTNET_PACKAGE_ID,
  TESTNET_ADMIN_CAP,
  TESTNET_DASHBOARD_ID,
} from "../frontend/src/constants";

const generatePTBCommand = ({
  packageId,
  adminCapId,
  dashboardId,
  numProposals,
}) => {
  let command = "sui client ptb";

  for (let i = 1; i <= numProposals; i++) {
    // Generate timestamp: current date + 1 year + incremental seconds
    const currentDate = new Date();
    const oneYearFromNow = new Date(
      currentDate.setFullYear(currentDate.getFullYear() + 1)
    );
    const timestamp = oneYearFromNow.getTime() + i * 1000; // Add 1 second per proposal
    const timestampId = Math.floor(Math.random() * 100000 * i);

    const title = `Proposal ${timestampId}`;
    const description = `Proposal description ${timestampId}`;

    // Add proposal creation command
    command += ` \\
  --move-call ${packageId}::proposal::create \\
  @${adminCapId} \\
  '"${title}"' '"${description}"' ${timestamp} \\
  --assign proposal_id`;

    // Add dashboard registration command
    command += ` \\
  --move-call ${packageId}::dashboard::register_proposal \\
  @${dashboardId} \\
  @${adminCapId} proposal_id`;
  }

  return command;
};

// Inputs
const inputs = {
  packageId: TESTNET_PACKAGE_ID,
  adminCapId: TESTNET_ADMIN_CAP,
  dashboardId: TESTNET_DASHBOARD_ID,
  numProposals: 3, // Specify the number of proposals to generate
};

// Generate the command
const ptbCommand = generatePTBCommand(inputs);
console.log(ptbCommand);
