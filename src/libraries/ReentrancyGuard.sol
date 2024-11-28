// SPDX-License-Identifier: GPL-2.0-or-later

pragma solidity ^0.8.24;

abstract contract ReentrancyGuard {
    // uint256(keccak256("ReentrancyGuard")) - 1
    uint256 internal constant REENTRANCY_GUARD_SLOT = 0x8e94fed44239eb2314ab7a406345e6c5a8f0ccedf3b600de3d004e672c33abf4;

    error ReentrancyGuardReentrantCall();

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        if (_reentrancyGuardEntered()) {
            revert ReentrancyGuardReentrantCall();
        }
        assembly {
            // Any calls to nonReentrant after this point will fail
            sstore(REENTRANCY_GUARD_SLOT, 1)
        }
    }

    function _nonReentrantAfter() private {
        assembly {
            sstore(REENTRANCY_GUARD_SLOT, 0)
        }
    }

    function _reentrancyGuardEntered() internal view returns (bool isEntered) {
        assembly {
            isEntered := sload(REENTRANCY_GUARD_SLOT)
        }
    }
}
