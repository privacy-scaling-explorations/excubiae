#!node_modules/.bin/ts-node
import { readdirSync, rmSync } from "fs"

const folderName = "packages"

const gitIgnored = [
    "node_modules",
    "dist",
    "build",
    "artifacts",
    "typechain-types",
    "cache",
    "cache_forge",
    "docs",
    "out",
    "coverage.json",
    "lib",
    "lcov.info"
]

async function main() {
    const folders = readdirSync(folderName, { withFileTypes: true })
        .filter((file) => file.isDirectory())
        .map((dir) => dir.name)

    folders.map((app) => gitIgnored.map((f) => rmSync(`${folderName}/${app}/${f}`, { recursive: true, force: true })))
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error)
        process.exit(1)
    })
