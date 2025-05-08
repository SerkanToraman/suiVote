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
  packageId:
    "0x8307d6870af34b725330e15da85878b07522fd0bb151bc7f34f30cb3bc3b79c0",
  adminCapId:
    "0x1c0b53bffda96ad0e1e97222ad538fef461d7e74a60dfa1c2d6284e78a912668",
  dashboardId:
    "0xec174d304dc1f1d293f5bb05507f7f1105b78bd746c656ebeb9128602a2d2b92",
  numProposals: 3, // Specify the number of proposals to generate
};

// Generate the command
const ptbCommand = generatePTBCommand(inputs);
console.log(ptbCommand);
