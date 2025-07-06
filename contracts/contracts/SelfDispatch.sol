// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

import { SelfVerificationRoot } from "@selfxyz/contracts/contracts/abstract/SelfVerificationRoot.sol";
import { ISelfVerificationRoot } from "@selfxyz/contracts/contracts/interfaces/ISelfVerificationRoot.sol";
import { SelfCircuitLibrary } from "@selfxyz/contracts/contracts/libraries/SelfCircuitLibrary.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IApp } from "./IApp.sol";

contract SelfDispatch is SelfVerificationRoot, Ownable {
    IApp public immutable app;
    string public dobReadable;

    mapping(uint256 => bool) internal _nullifiers;

    event MessageDispatched(address indexed claimer, address to);

    error RegisteredNullifier();

    constructor(
        address _identityVerificationHub,
        uint256 _scope,
        uint256[] memory _attestationIds,
        address _app
    ) SelfVerificationRoot(_identityVerificationHub, _scope, _attestationIds) Ownable(_msgSender()) {
        app = IApp(_app);
    }

    function setVerificationConfig(
        ISelfVerificationRoot.VerificationConfig memory newVerificationConfig
    ) external onlyOwner {
        _setVerificationConfig(newVerificationConfig);
    }

    function verifySelfProof(ISelfVerificationRoot.DiscloseCircuitProof memory proof) public override {
        if (_nullifiers[proof.pubSignals[NULLIFIER_INDEX]]) {
            revert RegisteredNullifier();
        }

        super.verifySelfProof(proof);

        if (_isEligible(getRevealedDataPacked(proof.pubSignals))) {
            _nullifiers[proof.pubSignals[NULLIFIER_INDEX]] = true;
            app.sendString(
                40245,
                "Eligible dispatch",
                bytes(0)
            );
            emit MessageDispatched(address(uint160(proof.pubSignals[USER_IDENTIFIER_INDEX])), claimableAmount);
        } else {
            revert("Not eligible: Age or birthday requirements not met");
        }
    }

    function _isEligible(uint256[3] memory revealedDataPacked) internal returns (bool) {
        // Check birthday window eligibility
        // Check age eligibility based on country
        string memory nationality = SelfCircuitLibrary.getNationality(revealedDataPacked);

        uint256 minimumAge;
        if (keccak256(abi.encodePacked(country)) == keccak256(abi.encodePacked("USA"))) {
            minimumAge = 21;
        } else {
            minimumAge = 18;
        }

        bool meetsAgeRequirement = SelfCircuitLibrary.getOlderThan(revealedDataPacked, minimumAge);

        return meetsAgeRequirement;
    }
}
