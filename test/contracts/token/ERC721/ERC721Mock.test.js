const {artifacts} = require('hardhat');
const {shouldBehaveLikeERC721} = require('./behaviors/ERC721.behavior');

const implementation = {
  contractName: 'ERC721Mock',
  nfMaskLength: 32,
  name: 'ERC721Mock',
  symbol: 'E721',
  revertMessages: {
    NonApproved: 'ERC721: non-approved sender',
    SelfApproval: 'ERC721: self-approval',
    SelfApprovalForAll: 'ERC721: self-approval',
    ZeroAddress: 'ERC721: zero address',
    TransferToZero: 'ERC721: transfer to zero',
    MintToZero: 'ERC721: mint to zero',
    TransferRejected: 'ERC721: transfer refused',
    NonExistingNFT: 'ERC721: non-existing NFT',
    NonOwnedNFT: 'ERC721: non-owned NFT',
    ExistingOrBurntNFT: 'ERC721: existing/burnt NFT',
    NotMinter: 'MinterRole: not a Minter',
  },
  interfaces: {ERC721: true, ERC721Metadata: true, ERC721BatchTransfer: true},
  methods: {
    'batchTransferFrom(address,address,uint256[])': async function (contract, from, to, tokenIds, overrides) {
      return contract.batchTransferFrom(from, to, tokenIds, overrides);
    },
    'mint(address,uint256)': async function (contract, to, tokenId, overrides) {
      return contract.mint(to, tokenId, overrides);
    },
    'safeMint(address,uint256,bytes)': async function (contract, to, tokenId, data, overrides) {
      return contract.methods['safeMint(address,uint256,bytes)'](to, tokenId, data, overrides);
    },
    'batchMint(address,uint256[])': async function (contract, to, tokenIds, overrides) {
      return contract.batchMint(to, tokenIds, overrides);
    },
  },
  deploy: async function (deployer) {
    return artifacts.require('ERC721Mock').new({from: deployer});
  },
  mint: async function (contract, to, id, _value, overrides) {
    return contract.methods['safeMint(address,uint256,bytes)'](to, id, '0x', overrides);
  },
};

describe('ERC721Mock', function () {
  this.timeout(0);
  shouldBehaveLikeERC721(implementation);
});