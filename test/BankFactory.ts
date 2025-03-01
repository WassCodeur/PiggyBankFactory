import {
    time,
    loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import hre from "hardhat";
import { ethers } from "hardhat";


describe("BankFactory", function () {

    async function deployKoloBankFixture() {



        const [owner, Account1, Account2] = await hre.ethers.getSigners();

        const KoloBankFactory = await hre.ethers.getContractFactory("BankFactory");
        // const KoloBank = await hre.ethers.getContractFactory("KoloBank");
        const ERC20 = await hre.ethers.getContractFactory("ERC20");

        const DAI = await ERC20.deploy("DAI", "DAI", 18, 10000);
        const USDC = await ERC20.deploy("USDC", "USDC", 18, 10000);
        const USDT = await ERC20.deploy("USDT", "USDT", 18, 10000);

        const deployedBankFactory = await KoloBankFactory.deploy([DAI.target, USDC.target, USDT.target])


        return { DAI, USDC, owner, USDT, Account1, Account2, deployedBankFactory}


    }

    describe("Deployment", function () {
        it("Should", async function () {
            const { DAI, USDC, owner, USDT, Account1, Account2, deployedBankFactory } = await loadFixture(deployKoloBankFixture);
            expect(deployedBankFactory.target).not.equal(0);

        });

        it("Should set the right owner", async function () {
            const { DAI, USDC, owner, USDT, Account1, Account2, deployedBankFactory } = await loadFixture(deployKoloBankFixture);

            expect(await deployedBankFactory.owner()).to.equal(owner);
        });
    });

    describe("Deploy factory contract", function () {
        it("it should create a new KoloBank", async function () {
            const { DAI, USDC, owner, USDT, Account1, Account2, deployedBankFactory } = await loadFixture(deployKoloBankFixture);
            const koloAddress = await deployedBankFactory.connect(Account1).createKoloBank(30)
            // expect(await deployedBankFactory.target).not.equal(0);
        });

        it("Should set the right owner", async function () {
            const { DAI, USDC, owner, USDT, Account1, Account2, deployedBankFactory} = await loadFixture(deployKoloBankFixture);
            const koloAddress = await deployedBankFactory.connect(Account1).createKoloBank(30)
            
            await deployedBankFactory.connect(Account1).createKoloBank(30)
            const koloAddrs = await deployedBankFactory.getKolo(Account1.address)
            // let KoloBank = await ethers.getContractAt('KoloBank', koloAddress[0]);
            // expect(await deployedBankFactory.target).not.equal(0);
            // const koloOwner = await KoloBank(koloAddress).owner()
            // expect(Account1.address).to.equal(koloOwner);
            await DAI.transfer(Account1.address, 100000)
            console.log(await DAI.balanceOf(Account1.address))
            await DAI.connect(Account1).approve(koloAddrs[0], 100000)
            await DAI.transfer(koloAddrs[0], 100000)
            await deployedBankFactory.connect(Account1).save(koloAddrs[0], DAI.target, 1000)
            console.log(await DAI.balanceOf(koloAddrs[0]))
            
        });

    });

    // describe("saving", async function () {
    //     it("It should save DAI", async function () {
    //         const { DAI, USDC, owner, USDT, Account1, Account2, deployedBankFactory } = await loadFixture(deployKoloBankFixture);
    //         await DAI.transfer(Account1.address, 100000)
    //         await DAI.connect(Account1).approve(deployedBankFactory.target, 1000)
    //         console.log((await DAI.balanceOf(Account1.address)))
    //         await deployedBankFactory.save(Account1.address, DAI.target, 10);
    //         console.log((await DAI.balanceOf(Account1.address)))
    //     })

    //     it("It should save DAI", async function () {
    //         const { DAI, USDC, owner, USDT, Account1, Account2, deployedBankFactory } = await loadFixture(deployKoloBankFixture);
    //         await DAI.transfer(Account1.address, 100000)
    //         await DAI.connect(Account1).approve(deployedBankFactory.target, 100000)
    //         console.log((await DAI.balanceOf(Account1.address)))
    //         await deployedBankFactory.save(Account1.address, DAI.target, 100000);
    //         console.log((await DAI.balanceOf(Account1.address)))
    //         console.log((await DAI.balanceOf(owner.address)))
    //         await deployedBankFactory.withdraw(Account1.address)
    //         console.log((await DAI.balanceOf(owner.address)))
    //         console.log((await DAI.balanceOf(Account1.address)))

    //     })
    // })
})
