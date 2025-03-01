import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";

describe("KoloBank", function () {

  async function deployKoloBankFixture() {



    const [owner, Account1, Account2] = await hre.ethers.getSigners();

    const KoloBank = await hre.ethers.getContractFactory("KoloBank");
    const ERC20 = await hre.ethers.getContractFactory("ERC20");

    const DAI = await ERC20.deploy("DAI", "DAI", 18, 10000);
    const USDC = await ERC20.deploy("USDC", "USDC", 18, 10000);
    const USDT = await ERC20.deploy("USDT", "USDT", 18, 10000);

    const deployedBank = await KoloBank.deploy(Account1.address, [DAI.target, USDC.target, USDT.target], 30)
    

    return { DAI, USDC, owner, USDT, Account1, Account2, deployedBank }


  }

  describe("Deployment", function () {
    it("Should", async function () {
      const { DAI, USDC, owner, USDT, Account1, Account2, deployedBank } = await loadFixture(deployKoloBankFixture);
      expect(await deployedBank.target).not.equal(0);

    });

    it("Should set the right owner", async function () {
      const { DAI, USDC, owner, USDT, Account1, Account2, deployedBank } = await loadFixture(deployKoloBankFixture);

      expect(await deployedBank.owner()).to.equal(Account1.address);
    });
  });
  describe("saving", async function () {
    it("It should save DAI", async function () { 
      const { DAI, USDC, owner, USDT, Account1, Account2, deployedBank } = await loadFixture(deployKoloBankFixture);
      await DAI.transfer(Account1.address, 100000)
      await DAI.connect(Account1).approve(deployedBank.target, 1000)
      console.log((await DAI.balanceOf(Account1.address)))
      await deployedBank.save(Account1.address, DAI.target, 10);
      console.log((await DAI.balanceOf(Account1.address)))
    })

    it("It should save DAI", async function () {
      const { DAI, USDC, owner, USDT, Account1, Account2, deployedBank } = await loadFixture(deployKoloBankFixture);
      await DAI.transfer(Account1.address, 100000)
      await DAI.connect(Account1).approve(deployedBank.target, 100000)
      console.log((await DAI.balanceOf(Account1.address)))
      await deployedBank.save(Account1.address, DAI.target, 100000);
      console.log((await DAI.balanceOf(Account1.address)))
      console.log((await DAI.balanceOf(owner.address)))
      await deployedBank.withdraw(Account1.address)
      console.log((await DAI.balanceOf(owner.address)))
      console.log((await DAI.balanceOf(Account1.address)))
      
    })
    
    

  })
})




