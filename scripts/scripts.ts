import hre, { ethers } from "hardhat";




async function main() {

    console.log("-----------------------deploy contract---------------\n\n")

    const [owner, Account1, Account2] = await hre.ethers.getSigners();

    const ERC20 = await hre.ethers.getContractFactory("ERC20");

    const DAI = await ERC20.deploy("DAI", "DAI", 18, 10000);
    const USDC = await ERC20.deploy("USDC", "USDC", 18, 10000);
    const USDT = await ERC20.deploy("USDT", "USDT", 18, 10000);

    const tokenAddresses = [DAI.target, USDC.target, USDT.target]

    const deployedBankFactory = await ethers.deployContract("BankFactory", [DAI.target, USDC.target, USDT.target] );

    await deployedBankFactory.waitForDeployment();

    console.log(
        `BankFactoryContract contract successfully deployed to: ${deployedBankFactory.target}`
    );


    console.log(
        `DAI Address: ${DAI.target}`
    );
    console.log(
        `USDC Address: ${USDC.target}`
    );
    console.log(
        `USDT Address: ${USDT.target}`
    );


}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
    console.error(error);
    process.exitCode = 1;
});