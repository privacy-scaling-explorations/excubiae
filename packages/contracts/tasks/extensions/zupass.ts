/* eslint-disable no-console */
import { task } from "hardhat/config"
import ZupassModule from "../../ignition/modules/extensions/Zupass"

task("deploy:zupass", "Deploys the Zupass Extension Module")
    .addParam("eventId", "The Zupass event UUID converted to bigint")
    .addParam("signer1", "The Zupass event first signer converted to bigint")
    .addParam("signer2", "The Zupass event second signer converted to bigint")
    .addParam("verifier", "The ZupassGroth16Verifier contract address")
    .setAction(async (taskArgs, hre) => {
        const { checkerFactory, checker, policyFactory, policy } = await hre.ignition.deploy(ZupassModule, {
            parameters: {
                eventId: taskArgs.eventId,
                signer1: taskArgs.signer1,
                signer2: taskArgs.signer2,
                verifier: taskArgs.verifier
            }
        })

        console.log("Deployment addresses:")
        console.log(`CheckerFactory: ${await checkerFactory.getAddress()}`)
        console.log(`Checker: ${await checker.getAddress()}`)
        console.log(`PolicyFactory: ${await policyFactory.getAddress()}`)
        console.log(`Policy: ${await policy.getAddress()}`)
    })
