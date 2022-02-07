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

<<<<<<< HEAD:contracts/Freeflow/EscrowCloneFactory.sol
    function createNewEscrow(address freeflow, address _client, address payable _payee, uint256 _initialAmount) payable external returns (address instance) {
=======
    function createNewEscrow(address _client, address payable _dev, address payable _freeflow, bool isEth) payable external returns (address instance) {
>>>>>>> 40ee5704b2ffd4224e31ff8b8e2fb50bfe4579a9:contracts/EscrowCloneFactory.sol
        instance = Clones.clone(implementationContract);
        
        (bool success, ) = instance.call{
            value: msg.value
            }(
                abi.encodeWithSignature(
<<<<<<< HEAD:contracts/Freeflow/EscrowCloneFactory.sol
                    "initialize(address,address,address)", 
                    freeflow,
                    _client,
                    _payee,
                    _initialAmount
=======
                    "initialize(address,address,address,bool)", 
                    _client,
                    _dev,
                    _freeflow,
                    isEth
>>>>>>> 40ee5704b2ffd4224e31ff8b8e2fb50bfe4579a9:contracts/EscrowCloneFactory.sol
                ));

        allClones.push(instance);
        
        require(success);
        emit EscrowCloneDeployed(instance);
        return instance;
    }
}