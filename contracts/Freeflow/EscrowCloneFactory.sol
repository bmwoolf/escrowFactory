// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.6;

import "@openzeppelin/contracts/proxy/Clones.sol";


contract EscrowCloneFactory {
    address public implementationContract;
    address public immutable freeflow;
    
    address[] public allClones;

    event EscrowCloneDeployed(address _clone);

    constructor(address _implementation) {
        implementationContract = _implementation;
        freeflow = msg.sender;
    }

    function createNewEscrow(address freeflow, address _payer, address payable _payee, uint256 _initialAmount) payable external returns (address instance) {
        instance = Clones.clone(implementationContract);
        
        (bool success, ) = instance.call{
            value: msg.value
            }(
                abi.encodeWithSignature(
                    "initialize(address,address,address)", 
                    freeflow,
                    _payer,
                    _payee,
                    _initialAmount
                ));

        allClones.push(instance);
        
        require(success);
        emit EscrowCloneDeployed(instance);
        return instance;
    }
}