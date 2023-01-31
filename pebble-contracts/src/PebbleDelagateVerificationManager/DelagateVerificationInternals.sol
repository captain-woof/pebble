// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

contract DelagateVerificationInternals {
    // CONSTANTS
    uint256 private constant DELEGATOR_TO_NONCE_SLOT =
        uint256(keccak256("PEBBLE:DELEGATOR_TO_NONCE_SLOT"));

    // Data
    mapping(address => uint256) private __delegatorToNonceMapping;

    // Modifiers
    modifier delegatorNonceCorrect(address _delegator, uint256 _nonceToCheck) {
        require(
            _getAndUpdateDelegatorNonce(_delegator) == _nonceToCheck,
            "PEBBLE: DELEGATOR NONCE INCORRECT"
        );
        _;
    }

    // Functions

    /**
    @dev Gets a delegator's next allowed nonce
    @param _delegator Address of delegator
    @return nonce Delegator's next allowed nonce
     */
    function _getDelegatorNonce(address _delegator)
        internal
        view
        returns (uint256 nonce)
    {
        nonce = _getDelegatorToNonceMapping()[_delegator];
    }

    /**
    @dev Updates (increments) a delegator's next allowed nonce
    @param _delegator Address of delegator
     */
    function _updateDelegatorNonce(address _delegator) internal {
        ++_getDelegatorToNonceMapping()[_delegator];
    }

    /**
    @dev Gets and updates (increments) a delegator's next allowed nonce
    @param _delegator Address of delegator
    @return nonce Delegator's next allowed nonce
     */
    function _getAndUpdateDelegatorNonce(address _delegator)
        internal
        returns (uint256 nonce)
    {
        nonce = _getDelegatorToNonceMapping()[_delegator];
        _updateDelegatorNonce(_delegator);
    }

    ///////////////
    // SLOT HELPERS
    ///////////////

    /**
    @dev Gets delegator to their next allowed nonce mapping at correct slot
     */
    function _getDelegatorToNonceMapping()
        private
        view
        returns (mapping(address => uint256) storage)
    {
        mapping(address => uint256)
            storage delegatorToNonceMapping = __delegatorToNonceMapping;
        uint256 slotNum = DELEGATOR_TO_NONCE_SLOT;

        assembly {
            delegatorToNonceMapping.slot := slotNum
        }

        return delegatorToNonceMapping;
    }
}
