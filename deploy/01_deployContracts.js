const { network } = require("hardhat");
module.exports = async ({ getNamedAccounts, deployments }) => {
  console.log("deploy contract")
  const { deploy } = deployments;
  const { deployer } = await getNamedAccounts();

  await deploy("TXtest", {
    from: deployer,
    log: true,
    args: [],
  });
};

module.exports.tags = ["all", "TXtest"];
