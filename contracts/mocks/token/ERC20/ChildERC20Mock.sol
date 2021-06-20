// SPDX-License-Identifier: MIT

pragma solidity >=0.7.6 <0.8.0;

import {ManagedIdentity, Ownable, Recoverable, RecoverableERC20} from "@animoca/ethereum-contracts-core-1.0.0/contracts/utils/Recoverable.sol";
import {IForwarderRegistry, UsingUniversalForwarding} from "ethereum-universal-forwarder/src/solc_0.7/ERC2771/UsingUniversalForwarding.sol";
import {ChildERC20} from "../../../token/ERC20/ChildERC20.sol";
import {IERC20Mintable} from "../../../token/ERC20/IERC20Mintable.sol";

contract ChildERC20Mock is Recoverable, UsingUniversalForwarding, ChildERC20, IERC20Mintable {
    uint256 internal _inEscrow;

    constructor(
        address[] memory recipients,
        uint256[] memory values,
        IForwarderRegistry forwarderRegistry,
        address universalForwarder
    ) ChildERC20("Child ERC20 Mock", "CE20", 18, "uri") Ownable(msg.sender) UsingUniversalForwarding(forwarderRegistry, universalForwarder) {
        _batchMint(recipients, values);
    }

    /// @dev See {IERC165-supportsInterface}.
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC20Mintable).interfaceId || super.supportsInterface(interfaceId);
    }

    function _msgSender() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (address payable) {
        return UsingUniversalForwarding._msgSender();
    }

    function _msgData() internal view virtual override(ManagedIdentity, UsingUniversalForwarding) returns (bytes memory ret) {
        return UsingUniversalForwarding._msgData();
    }

    function deposit(address user, bytes calldata depositData) public virtual override {
        _requireDepositorRole(_msgSender());
        uint256 amount = abi.decode(depositData, (uint256));
        _inEscrow -= amount;
        _transfer(address(this), user, amount);
    }

    function withdraw(uint256 amount) public virtual override {
        _inEscrow += amount;
        super.withdraw(amount);
    }

    function onERC20Received(
        address operator,
        address from,
        uint256 amount,
        bytes calldata data
    ) public virtual override returns (bytes4) {
        _inEscrow += amount;
        return super.onERC20Received(operator, from, amount, data);
    }

    function recoverERC20s(
        address[] calldata accounts,
        address[] calldata tokens,
        uint256[] calldata amounts
    ) external virtual override {
        _requireOwnership(_msgSender());
        uint256 length = accounts.length;
        require(length == tokens.length && length == amounts.length, "Recov: inconsistent arrays");
        for (uint256 i = 0; i != length; ++i) {
            address token = tokens[i];
            uint256 amount = amounts[i];
            if (token == address(this)) {
                uint256 recoverable = _balances[address(this)] - _inEscrow;
                require(amount <= recoverable, "Recov: insufficient balance");
            }
            require(RecoverableERC20(token).transfer(accounts[i], amount), "Recov: transfer failed");
        }
    }

    /**
     * Mints `amount` tokens and assigns them to `account`, increasing the total supply.
     * @dev Reverts if `account` is the zero address.
     * @dev Emits a {IERC20-Transfer} event with `from` set to the zero address.
     * @param to the account to deliver the tokens to.
     * @param value the amount of tokens to mint.
     */
    function mint(address to, uint256 value) public virtual override {
        _requireOwnership(_msgSender());
        _mint(to, value);
    }

    /**
     * Mints `amounts` tokens and assigns them to `accounts`, increasing the total supply.
     * @dev Reverts if `accounts` and `amounts` have different lengths.
     * @dev Reverts if one of `accounts` is the zero address.
     * @dev Emits an {IERC20-Transfer} event for each transfer with `from` set to the zero address.
     * @param recipients the accounts to deliver the tokens to.
     * @param values the amounts of tokens to mint to each of `accounts`.
     */
    function batchMint(address[] memory recipients, uint256[] memory values) public virtual override {
        _requireOwnership(_msgSender());
        _batchMint(recipients, values);
    }
}