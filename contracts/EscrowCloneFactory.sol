// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";


contract EscrowCloneFactory {
    address public implementationContract;
    
    address[] public allClones;

    event EscrowCloneDeployed(address _clone);
    
    /// @dev Client launches the escrow contract 
    constructor(address _implementation) {
        implementationContract = _implementation;
    }

    /// @dev Client deploys the escrow contract
    function createNewEscrow(address payable _client, address payable _dev, address payable _freeflow, bool isEth) external returns (address instance) {
        instance = Clones.clone(implementationContract);
        
        (bool success,) = instance.call(
            abi.encodeWithSignature(
                "initialize(address,address,address,bool)", 
                _client,
                _dev,
                _freeflow,
                isEth
            ));

        allClones.push(instance);
        
        require(success);
        emit EscrowCloneDeployed(instance);
        return instance;
    }
}