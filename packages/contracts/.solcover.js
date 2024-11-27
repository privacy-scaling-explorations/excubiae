module.exports = {
    istanbulFolder: "../../coverage/contracts",
    skipFiles: [
        "test/Base.t.sol",
        "test/base/BaseERC721Checker.sol",
        "test/base/BaseERC721Policy.sol",
        "test/base/BaseVoting.sol",
        "test/utils/NFT.sol",
        "test/wrappers/BaseERC721CheckerHarness.sol",
        "test/wrappers/BaseERC721PolicyHarness.sol"
    ]
}
