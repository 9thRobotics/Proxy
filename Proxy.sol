// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Proxy {
    address public implementation;
    address public admin;

    event ImplementationChanged(address indexed previousImplementation, address indexed newImplementation);

    modifier onlyAdmin() {
        require(msg.sender == admin, "Not authorized");
        _;
    }

    constructor() {
        admin = msg.sender; // Set the deployer as the admin
    }

    function setImplementation(address newImplementation) external onlyAdmin {
        require(newImplementation != address(0), "Invalid implementation address");
        require(isContract(newImplementation), "Implementation address must be a contract");
        
        address previousImplementation = implementation;
        implementation = newImplementation; // Set the new implementation address
        
        emit ImplementationChanged(previousImplementation, newImplementation);
    }

    fallback() external payable {
        require(implementation != address(0), "Implementation address not set");

        // Delegate call to the implementation contract
        (bool success, bytes memory data) = implementation.delegatecall(msg.data);
        require(success, "Delegatecall failed");

        // Return any data returned by the implementation
        assembly {
            return(add(data, 0x20), mload(data))
        }
    }

    receive() external payable {
        // Allow the contract to accept Ether
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
