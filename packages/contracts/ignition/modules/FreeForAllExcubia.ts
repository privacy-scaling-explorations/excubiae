import { buildModule } from "@nomicfoundation/hardhat-ignition/modules"

const FreeForAllExcubiaModule = buildModule("FreeForAllExcubiaModule", (m) => {
    const freeForAllExcubia = m.contract("FreeForAllExcubia")

    return { freeForAllExcubia }
})

export default FreeForAllExcubiaModule
