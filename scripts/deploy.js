async function main() {
  console.log("deploy")
  const [deployer] = await ethers.getSigners();

  console.log("Deploying contracts with the account:", deployer.address);

  console.log("Account balance:", (await deployer.getBalance()).toString());

  const TKO = await ethers.getContractFactory("TXtest");
  const contract = await TKO.deploy("Secure Owner");
  console.log(contract.address)
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
});
