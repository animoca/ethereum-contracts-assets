// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {UInt256ToDecimalString} from "@animoca/ethereum-contracts-core/contracts/utils/types/UInt256ToDecimalString.sol";
import {ManagedIdentity} from "@animoca/ethereum-contracts-core/contracts/metatx/ManagedIdentity.sol";
import {Ownable} from "@animoca/ethereum-contracts-core/contracts/access/Ownable.sol";

abstract contract NFTBaseMetadataURI is ManagedIdentity, Ownable {
    using UInt256ToDecimalString for uint256;

    event BaseMetadataURISet(string baseMetadataURI);

    string public baseMetadataURI;

    function setBaseMetadataURI(string calldata baseMetadataURI_) external {
        _requireOwnership(_msgSender());
        baseMetadataURI = baseMetadataURI_;
        emit BaseMetadataURISet(baseMetadataURI_);
    }

    function _uri(uint256 id) internal view virtual returns (string memory) {
        return string(abi.encodePacked(baseMetadataURI, id.toDecimalString()));
    }
}
