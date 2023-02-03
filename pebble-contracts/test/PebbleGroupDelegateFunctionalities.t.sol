// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.17;

import "forge-std/Test.sol";
import {PebbleSetupLibraryTest} from "test/helpers/PebbleSetup.sol";
import {PebbleUtilsTest} from "test/helpers/PebbleUtils.sol";
import {PebbleDelegateHelpersTest} from "test/helpers/PebbleDelegate.sol";
import {Pebble} from "src/Pebble.sol";
import {PebbleProxy} from "src/PebbleProxy.sol";
import {PebbleDelegatee} from "src/PebbleDelegatee.sol";

/**
forge test --match-path ./test/PebbleGroupDelegateFunctionalities.t.sol -vvv --via-ir --gas-price 1
 */
contract PebbleGroupDelegateFunctionalitiesTest is Test {
    // Data
    Pebble pebbleImplementation;
    PebbleProxy pebbleProxy;
    PebbleDelegatee pebbleDelegatee;
    uint256 delegateFeesBasis = 500;
    address delegateeCaller =
        PebbleUtilsTest.convertStringToAddress("DELEGATEE_CALLER");
    address[] pebbleAdmins;

    // Events
    event Invite(
        uint256 indexed groupId,
        address indexed creator,
        address indexed participant
    );
    event AllInvitesAccepted(uint256 indexed groupId);
    event SendMessage(
        uint256 indexed groupId,
        address indexed sender,
        bytes encryptedMessage
    );

    // Setup
    function setUp() external {
        pebbleAdmins.push(msg.sender);
        pebbleAdmins.push(address(this));

        (pebbleImplementation, pebbleProxy) = PebbleSetupLibraryTest
            .setupNewPebbleEnvironment(pebbleAdmins, new address[](0));
        pebbleDelegatee = Pebble(address(pebbleProxy))
            .deployAndAssignDelegateeContract(delegateFeesBasis);
    }

    // Delegate fees basis can set by Delegatee admin (Pebble admin)
    function testUpdateDelegateFeesByDelegateeAdmin(
        uint16 _delegateFeesBasis
    ) external {
        pebbleDelegatee.setDelegateFeesBasis(_delegateFeesBasis);
        require(
            _delegateFeesBasis == pebbleDelegatee.delegateFeesBasis(),
            "INCORRECT DELEGATE FEES BASIS SET"
        );
    }

    // Delegate fees basis cannot be set by non-Delegatee admin (Pebble admin)
    function testFailUpdateDelegateFeesByNonDelegateeAdmin(
        address _nonDelegateeAdmin,
        uint16 _delegateFeesBasis
    ) external {
        vm.assume(_nonDelegateeAdmin != pebbleAdmins[0]);
        vm.assume(_nonDelegateeAdmin != pebbleAdmins[1]);
        vm.startPrank(_nonDelegateeAdmin);
        pebbleDelegatee.setDelegateFeesBasis(_delegateFeesBasis);
        vm.stopPrank();
    }

    // Adding funds should work with `fallback()` and `receive()`
    function testAddFundsWithFallbackOrReceive(
        address _depositor,
        uint256 _amountToDeposit
    ) external {
        vm.assume(_depositor != address(pebbleImplementation));
        vm.assume(_depositor != address(pebbleProxy));
        vm.assume(_depositor != address(pebbleDelegatee));
        _amountToDeposit = bound(
            _amountToDeposit,
            1,
            UINT256_MAX - 0.001 ether
        );

        vm.startPrank(_depositor);

        vm.deal(_depositor, _amountToDeposit + 0.001 ether); // Extra for gas
        (bool success, ) = address(pebbleDelegatee).call{
            value: _amountToDeposit
        }("");
        require(
            success &&
                pebbleDelegatee.addressToFundsMapping(_depositor) ==
                _amountToDeposit,
            "INCORRECT AMOUNT DEPOSITED"
        );
        vm.stopPrank();
    }

    // Adding funds should work with `addFunds()`
    function testAddFundsWithAddFunds(
        address _depositor,
        uint256 _amountToDeposit
    ) external {
        vm.assume(_depositor != address(pebbleImplementation));
        vm.assume(_depositor != address(pebbleProxy));
        vm.assume(_depositor != address(pebbleDelegatee));
        _amountToDeposit = bound(
            _amountToDeposit,
            1,
            UINT256_MAX - 0.001 ether
        );

        vm.startPrank(_depositor);

        vm.deal(_depositor, _amountToDeposit + 0.001 ether); // Extra for gas
        pebbleDelegatee.addFunds{value: _amountToDeposit}();
        require(
            pebbleDelegatee.addressToFundsMapping(_depositor) ==
                _amountToDeposit,
            "INCORRECT AMOUNT DEPOSITED"
        );
        vm.stopPrank();
    }

    // Withdrawing all funds should work
    function testWithdrawAllFunds(
        address _depositor,
        uint256 _amountToDeposit
    ) external {
        vm.assume(_depositor != address(pebbleImplementation));
        vm.assume(_depositor != address(pebbleProxy));
        vm.assume(_depositor != address(pebbleDelegatee));
        _amountToDeposit = bound(
            _amountToDeposit,
            1,
            UINT256_MAX - 0.001 ether
        );

        // First, deposit
        vm.startPrank(_depositor);

        vm.deal(_depositor, _amountToDeposit + 0.001 ether); // Extra for gas
        pebbleDelegatee.addFunds{value: _amountToDeposit}();

        // Now, try withdrawing
        uint256 balanceBefore = _depositor.balance;
        pebbleDelegatee.withdrawFunds();

        require(
            _depositor.balance - balanceBefore == _amountToDeposit,
            "INCORRECT BALANCE WITHDRAWN"
        );

        require(
            pebbleDelegatee.addressToFundsMapping(_depositor) == 0,
            "INCORRECT FUNDS REMAINING AFTER WITHDRAW"
        );
    }

    // Withdrawing some funds should work
    function testWithdrawSomeFunds(
        address _depositor,
        uint256 _amountToDeposit,
        uint256 _amountToWithdraw
    ) external {
        vm.assume(_depositor != address(pebbleImplementation));
        vm.assume(_depositor != address(pebbleProxy));
        vm.assume(_depositor != address(pebbleDelegatee));
        _amountToDeposit = bound(
            _amountToDeposit,
            1,
            UINT256_MAX - 0.001 ether
        );
        _amountToWithdraw = bound(
            _amountToWithdraw,
            1,
            UINT256_MAX - 0.001 ether
        );
        vm.assume(_amountToDeposit > _amountToWithdraw);

        // First, deposit
        vm.startPrank(_depositor);

        vm.deal(_depositor, _amountToDeposit + 0.001 ether); // Extra for gas
        pebbleDelegatee.addFunds{value: _amountToDeposit}();

        // Now, try withdrawing
        uint256 balanceBefore = _depositor.balance;
        pebbleDelegatee.withdrawFunds(_amountToWithdraw);

        require(
            _depositor.balance - balanceBefore == _amountToWithdraw,
            "INCORRECT BALANCE WITHDRAWN"
        );

        require(
            pebbleDelegatee.addressToFundsMapping(_depositor) ==
                _amountToDeposit - _amountToWithdraw,
            "INCORRECT FUNDS REMAINING AFTER WITHDRAW"
        );
    }

    // Withdrawing some funds should work
    function testFailWithdrawFundsMoreThanDeposited(
        address _depositor,
        uint256 _amountToDeposit,
        uint256 _amountToWithdraw
    ) external {
        vm.assume(_depositor != address(pebbleImplementation));
        vm.assume(_depositor != address(pebbleProxy));
        vm.assume(_depositor != address(pebbleDelegatee));
        _amountToDeposit = bound(
            _amountToDeposit,
            1,
            (UINT256_MAX / 2) - 0.001 ether
        );
        _amountToWithdraw = bound(
            _amountToWithdraw,
            (UINT256_MAX / 2),
            UINT256_MAX - 0.001 ether
        );
        vm.assume(_amountToDeposit < _amountToWithdraw);

        // First, deposit
        vm.startPrank(_depositor);

        vm.deal(_depositor, _amountToDeposit + 0.001 ether); // Extra for gas
        pebbleDelegatee.addFunds{value: _amountToDeposit}();

        // Now, try withdrawing
        pebbleDelegatee.withdrawFunds(_amountToWithdraw);
    }

    // Delegating compensates delgatee caller
    function testDelegateCompensation() external {
        /**
         * Delegation would be tested with creating group function
         * Results should be the same for other functions too
         */
        uint256 delegateeFundsBefore = pebbleDelegatee.addressToFundsMapping(
            delegateeCaller
        );

        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(46);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY,
                initialPenultimateSharedKeyFromCreatorX,
                initialPenultimateSharedKeyFromCreatorY,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group (delegate)
        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce,
            v,
            r,
            s
        );

        vm.stopPrank();

        // Check if delegatee caller has more funds now
        require(
            delegateeFundsBefore <
                pebbleDelegatee.addressToFundsMapping(delegateeCaller),
            "DELEGATEE CALLER WAS NOT COMPENSATED"
        );
    }

    // Groups should be correctly created
    function testCreateGroup() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY,
                initialPenultimateSharedKeyFromCreatorX,
                initialPenultimateSharedKeyFromCreatorY,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group (delegate)
        vm.expectEmit(false, true, true, false); // Expect correct `Invite` events to be fired
        emit Invite(0, addresses[0], groupParticipantsOtherThanCreator[0]);
        vm.expectEmit(false, true, true, false); // Expect correct `Invite` events to be fired
        emit Invite(0, addresses[0], groupParticipantsOtherThanCreator[1]);

        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce,
            v,
            r,
            s
        );

        vm.stopPrank();
    }

    // Groups cannot be created with incorrect signature
    function testFailCreateGroupWithIncorrectSignature() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            ,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY,
                initialPenultimateSharedKeyFromCreatorX,
                initialPenultimateSharedKeyFromCreatorY,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group (delegate)
        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce,
            v,
            bytes32("WEIRD"),
            s
        );

        vm.stopPrank();
    }

    // Groups should not be created with delegator signature replay
    function testFailCreateGroupWithSignatureReplay() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY,
                initialPenultimateSharedKeyFromCreatorX,
                initialPenultimateSharedKeyFromCreatorY,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group (delegate)
        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce,
            v,
            r,
            s
        );

        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce + 1,
            v,
            r,
            s
        );

        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key For Creator - X
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyForCreatorX()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX + 1,
                initialPenultimateSharedKeyForCreatorY,
                initialPenultimateSharedKeyFromCreatorX,
                initialPenultimateSharedKeyFromCreatorY,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group
        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX + 1,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key For Creator - Y
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyForCreatorY()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY + 1,
                initialPenultimateSharedKeyFromCreatorX,
                initialPenultimateSharedKeyFromCreatorY,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group
        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY + 1,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key From Creator - X
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyFromCreatorX()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY,
                initialPenultimateSharedKeyFromCreatorX + 1,
                initialPenultimateSharedKeyFromCreatorY,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group
        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX + 1,
            initialPenultimateSharedKeyFromCreatorY,
            groupCreatorDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Group cannot be created with faulty Initial Penultimate Shared Key From Creator - Y
    function testFailCreateGroupWithFaultyInitialPenultimateSharedKeyFromCreatorY()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        (
            uint256 groupCreatorDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses[0],
                groupParticipantsOtherThanCreator,
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY,
                initialPenultimateSharedKeyFromCreatorX,
                initialPenultimateSharedKeyFromCreatorY + 1,
                Pebble(address(pebbleProxy)),
                privateKeys[0],
                vm
            );

        // Create group
        vm.deal(addresses[0], 100 ether);
        vm.startPrank(addresses[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.createGroupForDelegator(
            addresses[0],
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY + 1,
            groupCreatorDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Group ids must not be repeated
    function testGroupIdsUniqueness() external {
        // Create participants for Group 1
        (
            uint256[] memory privateKeys1,
            ,
            ,
            address[] memory addresses1
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer for Group 1
        uint256 random1 = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group for Group 1
        address[] memory groupParticipantsOtherThanCreator1 = new address[](2);
        groupParticipantsOtherThanCreator1[0] = addresses1[1];
        groupParticipantsOtherThanCreator1[1] = addresses1[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX1,
            uint256 initialPenultimateSharedKeyForCreatorY1
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random1);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX1,
            uint256 initialPenultimateSharedKeyFromCreatorY1
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys1[0],
                initialPenultimateSharedKeyForCreatorX1,
                initialPenultimateSharedKeyForCreatorY1
            );

        (
            uint256 groupCreatorDelegatorNonce1,
            uint8 v1,
            bytes32 r1,
            bytes32 s1
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses1[0],
                groupParticipantsOtherThanCreator1,
                initialPenultimateSharedKeyForCreatorX1,
                initialPenultimateSharedKeyForCreatorY1,
                initialPenultimateSharedKeyFromCreatorX1,
                initialPenultimateSharedKeyFromCreatorY1,
                Pebble(address(pebbleProxy)),
                privateKeys1[0],
                vm
            );

        // Create group for Group 1
        vm.deal(addresses1[0], 100 ether);
        vm.startPrank(addresses1[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        uint256 group1 = pebbleDelegatee.createGroupForDelegator(
            addresses1[0],
            groupParticipantsOtherThanCreator1,
            initialPenultimateSharedKeyForCreatorX1,
            initialPenultimateSharedKeyForCreatorY1,
            initialPenultimateSharedKeyFromCreatorX1,
            initialPenultimateSharedKeyFromCreatorY1,
            groupCreatorDelegatorNonce1,
            v1,
            r1,
            s1
        );
        vm.stopPrank();

        // Create participants for Group 2
        (
            uint256[] memory privateKeys2,
            ,
            ,
            address[] memory addresses2
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer for Group 2
        uint256 random2 = PebbleUtilsTest.createRandomInteger(60);

        // Prepare arguments for creating group for Group 2
        address[] memory groupParticipantsOtherThanCreator2 = new address[](2);
        groupParticipantsOtherThanCreator2[0] = addresses2[1];
        groupParticipantsOtherThanCreator2[1] = addresses2[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX2,
            uint256 initialPenultimateSharedKeyForCreatorY2
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random2);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX2,
            uint256 initialPenultimateSharedKeyFromCreatorY2
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys2[0],
                initialPenultimateSharedKeyForCreatorX2,
                initialPenultimateSharedKeyForCreatorY2
            );

        (
            uint256 groupCreatorDelegatorNonce2,
            uint8 v2,
            bytes32 r2,
            bytes32 s2
        ) = PebbleDelegateHelpersTest.getCreateGroupForDelegatorParams(
                addresses2[0],
                groupParticipantsOtherThanCreator2,
                initialPenultimateSharedKeyForCreatorX2,
                initialPenultimateSharedKeyForCreatorY2,
                initialPenultimateSharedKeyFromCreatorX2,
                initialPenultimateSharedKeyFromCreatorY2,
                Pebble(address(pebbleProxy)),
                privateKeys2[0],
                vm
            );

        // Create group for Group 2
        vm.deal(addresses2[0], 100 ether);
        vm.startPrank(addresses2[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        uint256 group2 = pebbleDelegatee.createGroupForDelegator(
            addresses2[0],
            groupParticipantsOtherThanCreator2,
            initialPenultimateSharedKeyForCreatorX2,
            initialPenultimateSharedKeyForCreatorY2,
            initialPenultimateSharedKeyFromCreatorX2,
            initialPenultimateSharedKeyFromCreatorY2,
            groupCreatorDelegatorNonce2,
            v2,
            r2,
            s2
        );
        vm.stopPrank();

        require(group2 - group1 == 1, "PEBBLE TEST: GROUP IDs NOT UNIQUE");
    }

    // Invited participants should be able to accept invite
    function testInvitedParticipantsInvitationAcceptance() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        (
            uint256 groupParticipantDelegatorNonce1,
            uint8 v1,
            bytes32 r1,
            bytes32 s1
        ) = PebbleDelegateHelpersTest.getAcceptGroupInviteForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce1,
            v1,
            r1,
            s1
        );
        vm.stopPrank();

        // Accept invite - Participant 2
        vm.startPrank(groupParticipantsOtherThanCreator[1]);
        penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        timestampForWhichUpdatedKeysAreMeant = Pebble(address(pebbleProxy))
            .getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        penultimateKeysForNum = penultimateKeysFor.length;
        (penultimateKeysXUpdated, penultimateKeysYUpdated) = Pebble(
            address(pebbleProxy)
        ).getParticipantsGroupPenultimateSharedKey(groupId, penultimateKeysFor);

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[2],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        (
            uint256 groupParticipantDelegatorNonce2,
            uint8 v2,
            bytes32 r2,
            bytes32 s2
        ) = PebbleDelegateHelpersTest.getAcceptGroupInviteForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[1],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[2],
                vm
            );

        vm.deal(groupParticipantsOtherThanCreator[1], 100 ether);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.expectEmit(true, false, false, false);
        emit AllInvitesAccepted(groupId); // Must emit event when as all invites are accepted
        vm.startPrank(delegateeCaller);
        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[1],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce2,
            v2,
            r2,
            s2
        );
        vm.stopPrank();

        // All penultimate shared keys must give same shared key
        (
            uint256[] memory participantPenultimateSharedKeysX,
            uint256[] memory participantPenultimateSharedKeysY
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(groupId, addresses);

        (uint256 participant1SharedKeyX, ) = PebbleUtilsTest
            .multiplyScalarToPointOnCurve(
                privateKeys[0],
                participantPenultimateSharedKeysX[0],
                participantPenultimateSharedKeysY[0]
            );
        (uint256 participant2SharedKeyX, ) = PebbleUtilsTest
            .multiplyScalarToPointOnCurve(
                privateKeys[1],
                participantPenultimateSharedKeysX[1],
                participantPenultimateSharedKeysY[1]
            );
        (uint256 participant3SharedKeyX, ) = PebbleUtilsTest
            .multiplyScalarToPointOnCurve(
                privateKeys[2],
                participantPenultimateSharedKeysX[2],
                participantPenultimateSharedKeysY[2]
            );

        require(
            participant1SharedKeyX == participant2SharedKeyX,
            "PEBBLE TEST: UNEQUAL SHARED KEY"
        );
        require(
            participant1SharedKeyX == participant3SharedKeyX,
            "PEBBLE TEST: UNEQUAL SHARED KEY"
        );
    }

    // Invite acceptance should not work with incorrect signature from delegator
    function testFailInvitedParticipantsInvitationAcceptanceWithIncorrectSignature()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        (
            uint256 groupParticipantDelegatorNonce,
            uint8 v,
            ,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getAcceptGroupInviteForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce,
            v,
            bytes32("INCORRECT SIGNATURE"),
            s
        );
        vm.stopPrank();
    }

    // Invite acceptance should not work with signature replay from delegator
    function testFailInvitedParticipantsInvitationAcceptanceWithSignatureReplay()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        (
            uint256 groupParticipantDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getAcceptGroupInviteForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce,
            v,
            r,
            s
        );

        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce + 1,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Invitees should not be able to accept invitation twice
    function testFailDoubleInvitationAcceptance() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        (
            uint256 groupParticipantDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getAcceptGroupInviteForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce,
            v,
            r,
            s
        );

        // Try accepting invite again
        (groupParticipantDelegatorNonce, v, r, s) = PebbleDelegateHelpersTest
            .getAcceptGroupInviteForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce,
            v,
            r,
            s
        );

        vm.stopPrank();
    }

    // Invitees should not be able to accept invitation to a non-existent group
    function testFailAcceptInviteToNonExistentGroup() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        (
            uint256 groupParticipantDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getAcceptGroupInviteForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            groupParticipantDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Non-invitees should not be able to accept invitation
    function testFailAcceptInviteUninvitedGroup() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(4, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Non-participant
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        (
            uint256 nonParticipantDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getAcceptGroupInviteForDelegatorParams(
                groupId,
                addresses[3],
                penultimateKeysFor,
                penultimateKeysXUpdated,
                penultimateKeysYUpdated,
                timestampForWhichUpdatedKeysAreMeant,
                Pebble(address(pebbleProxy)),
                privateKeys[3],
                vm
            );

        vm.deal(addresses[3], 100 ether);
        vm.startPrank(addresses[3]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.acceptGroupInviteForDelegator(
            groupId,
            addresses[3],
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant,
            nonParticipantDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Message can be sent after all invitees accept invite
    function testSendMessageAfterAllInviteesAcceptInvite() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Accept invite - Participant 2
        vm.startPrank(groupParticipantsOtherThanCreator[1]);
        penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        timestampForWhichUpdatedKeysAreMeant = Pebble(address(pebbleProxy))
            .getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        penultimateKeysForNum = penultimateKeysFor.length;
        (penultimateKeysXUpdated, penultimateKeysYUpdated) = Pebble(
            address(pebbleProxy)
        ).getParticipantsGroupPenultimateSharedKey(groupId, penultimateKeysFor);

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[2],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        vm.expectEmit(true, false, false, false);
        emit AllInvitesAccepted(groupId); // Must emit event when as all invites are accepted
        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Send message
        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        (
            uint256 senderDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getSendMessageInGroupForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                bytes("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.startPrank(delegateeCaller);
        vm.expectEmit(true, true, false, false);
        emit SendMessage(groupId, groupParticipantsOtherThanCreator[0], "");
        pebbleDelegatee.sendMessageInGroupForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            bytes("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
            senderDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Message cannot be sent after all invitees accept invite, if incorrect signature is used
    function testFailSendMessageAfterAllInviteesAcceptInviteWithIncorrectSignature()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(458);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Accept invite - Participant 2
        vm.startPrank(groupParticipantsOtherThanCreator[1]);
        penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        timestampForWhichUpdatedKeysAreMeant = Pebble(address(pebbleProxy))
            .getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        penultimateKeysForNum = penultimateKeysFor.length;
        (penultimateKeysXUpdated, penultimateKeysYUpdated) = Pebble(
            address(pebbleProxy)
        ).getParticipantsGroupPenultimateSharedKey(groupId, penultimateKeysFor);

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[2],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        vm.expectEmit(true, false, false, false);
        emit AllInvitesAccepted(groupId); // Must emit event when as all invites are accepted
        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Send message
        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        (
            uint256 senderDelegatorNonce,
            uint8 v,
            ,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getSendMessageInGroupForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                bytes("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.startPrank(delegateeCaller);
        pebbleDelegatee.sendMessageInGroupForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            bytes("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
            senderDelegatorNonce,
            v,
            bytes32("INCORRECT SIGNATURE"),
            s
        );
        vm.stopPrank();
    }

    // Message cannot be sent after all invitees accept invite, if same signature is replayed
    function testFailSendMessageAfterAllInviteesAcceptInviteWithSignatureReplay()
        external
    {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Accept invite - Participant 2
        vm.startPrank(groupParticipantsOtherThanCreator[1]);
        penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        timestampForWhichUpdatedKeysAreMeant = Pebble(address(pebbleProxy))
            .getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        penultimateKeysForNum = penultimateKeysFor.length;
        (penultimateKeysXUpdated, penultimateKeysYUpdated) = Pebble(
            address(pebbleProxy)
        ).getParticipantsGroupPenultimateSharedKey(groupId, penultimateKeysFor);

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[2],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        vm.expectEmit(true, false, false, false);
        emit AllInvitesAccepted(groupId); // Must emit event when as all invites are accepted
        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Send message
        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        (
            uint256 senderDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getSendMessageInGroupForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                bytes("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.startPrank(delegateeCaller);
        vm.expectEmit(true, true, false, false);
        emit SendMessage(groupId, groupParticipantsOtherThanCreator[0], "");
        pebbleDelegatee.sendMessageInGroupForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            bytes("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
            senderDelegatorNonce,
            v,
            r,
            s
        );

        pebbleDelegatee.sendMessageInGroupForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            bytes("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
            senderDelegatorNonce + 1,
            v,
            r,
            s
        );
        vm.stopPrank();
    }

    // Message cannot be sent before all invitees accept invite
    function testFailSendMessageBeforeAllInviteesAcceptInvite() external {
        // Create participants
        (
            uint256[] memory privateKeys,
            ,
            ,
            address[] memory addresses
        ) = PebbleUtilsTest.createUsers(3, vm);

        // Get large integer
        uint256 random = PebbleUtilsTest.createRandomInteger(80);

        // Prepare arguments for creating group
        address[] memory groupParticipantsOtherThanCreator = new address[](2);
        groupParticipantsOtherThanCreator[0] = addresses[1];
        groupParticipantsOtherThanCreator[1] = addresses[2];
        (
            uint256 initialPenultimateSharedKeyForCreatorX,
            uint256 initialPenultimateSharedKeyForCreatorY
        ) = PebbleUtilsTest.getPublicKeyFromPrivateKey(random);
        (
            uint256 initialPenultimateSharedKeyFromCreatorX,
            uint256 initialPenultimateSharedKeyFromCreatorY
        ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[0],
                initialPenultimateSharedKeyForCreatorX,
                initialPenultimateSharedKeyForCreatorY
            );

        // Create group
        vm.startPrank(addresses[0]);
        uint256 groupId = Pebble(address(pebbleProxy)).createGroup(
            groupParticipantsOtherThanCreator,
            initialPenultimateSharedKeyForCreatorX,
            initialPenultimateSharedKeyForCreatorY,
            initialPenultimateSharedKeyFromCreatorX,
            initialPenultimateSharedKeyFromCreatorY
        );
        vm.stopPrank();

        // Accept invite - Participant 1
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        address[] memory penultimateKeysFor = Pebble(address(pebbleProxy))
            .getOtherGroupParticipants(groupId);
        uint256 timestampForWhichUpdatedKeysAreMeant = Pebble(
            address(pebbleProxy)
        ).getGroupPenultimateSharedKeyLastUpdateTimestamp(groupId);

        uint256 penultimateKeysForNum = penultimateKeysFor.length;

        (
            uint256[] memory penultimateKeysXUpdated,
            uint256[] memory penultimateKeysYUpdated
        ) = Pebble(address(pebbleProxy))
                .getParticipantsGroupPenultimateSharedKey(
                    groupId,
                    penultimateKeysFor
                );

        for (uint256 i; i < penultimateKeysForNum; ++i) {
            (
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            ) = PebbleUtilsTest.multiplyScalarToPointOnCurve(
                privateKeys[1],
                penultimateKeysXUpdated[i],
                penultimateKeysYUpdated[i]
            );
        }

        Pebble(address(pebbleProxy)).acceptGroupInvite(
            groupId,
            penultimateKeysFor,
            penultimateKeysXUpdated,
            penultimateKeysYUpdated,
            timestampForWhichUpdatedKeysAreMeant
        );
        vm.stopPrank();

        // Send message
        vm.deal(groupParticipantsOtherThanCreator[0], 100 ether);
        vm.startPrank(groupParticipantsOtherThanCreator[0]);
        pebbleDelegatee.addFunds{value: 0.0005 ether}();
        vm.stopPrank();

        (
            uint256 senderDelegatorNonce,
            uint8 v,
            bytes32 r,
            bytes32 s
        ) = PebbleDelegateHelpersTest.getSendMessageInGroupForDelegatorParams(
                groupId,
                groupParticipantsOtherThanCreator[0],
                abi.encodePacked("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
                Pebble(address(pebbleProxy)),
                privateKeys[1],
                vm
            );

        vm.startPrank(delegateeCaller);
        vm.expectEmit(true, true, false, false);
        emit SendMessage(groupId, groupParticipantsOtherThanCreator[0], "");
        pebbleDelegatee.sendMessageInGroupForDelegator(
            groupId,
            groupParticipantsOtherThanCreator[0],
            abi.encodePacked("ASSUME THIS IS ENCRYPTED OONGA-BOONGA"),
            senderDelegatorNonce,
            v,
            r,
            s
        );
        vm.stopPrank();
    }
}
