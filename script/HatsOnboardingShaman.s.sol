// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script, console2 } from "forge-std/Script.sol";
import { HatsOnboardingShaman } from "../src/HatsOnboardingShaman.sol";
import {
  HatsModuleFactory, deployModuleFactory, deployModuleInstance
} from "lib/hats-module/src/utils/DeployFunctions.sol";

contract DeployImplementation is Script {
  HatsOnboardingShaman public implementation;
  bytes32 public SALT = keccak256("lets add some salt to this meal");

  // default values
  string public version = "0.1.0"; // increment with each deploy
  bool private verbose = true;

  /// @notice Override default values, if desired
  function prepare(string memory _version, bool _verbose) public {
    version = _version;
    verbose = _verbose;
  }

  function run() public {
    uint256 privKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.rememberKey(privKey);
    vm.startBroadcast(deployer);

    implementation = new HatsOnboardingShaman{ salt: SALT}(version);

    vm.stopBroadcast();

    if (verbose) {
      console2.log("HatsOnboardingShaman:", address(implementation));
    }
  }

  // forge script script/HatsOnboardingShaman.s.sol:DeployImplementation -f ethereum --broadcast --verify
}

contract DeployInstance is Script {
  HatsModuleFactory public factory;
  address public implementation;
  address public instance;
  uint256 public hatId;
  bytes public otherImmutableArgs;
  bytes public initData;
  bool internal verbose = true;
  bool internal defaults = true;

  /// @dev override this to abi.encode (packed) other relevant immutable args (initialized and set within the function
  /// body). Alternatively, you can pass encoded data in
  function encodeImmutableArgs() internal virtual returns (bytes memory) {
    // abi.encodePacked()...
  }

  /// @dev override this to abi.encode (unpacked) the init data (initialized and set within the function body)
  function encodeInitData() internal virtual returns (bytes memory) {
    // abi.encode()...
  }

  /// @dev override this to set the default values within the function body
  function setDefaultValues() internal virtual {
    // factory = HatsModuleFactory(0x);
    // implementation = 0x;
    // hatId = ;
  }

  /// @dev Call from tests or other scripts to override default values
  function prepare(
    HatsModuleFactory _factory,
    address _implementation,
    uint256 _hatId,
    bytes memory _otherImmutableArgs,
    bytes memory _initData,
    bool _verbose
  ) public {
    factory = _factory;
    implementation = _implementation;
    hatId = _hatId;
    otherImmutableArgs = _otherImmutableArgs;
    initData = _initData;
    verbose = _verbose;

    defaults = false;
  }

  /// @dev Designed for override to not be necessary (all changes / config can be made in above functions), but can be
  /// if desired
  function run() public virtual {
    uint256 privKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.rememberKey(privKey);
    vm.startBroadcast(deployer);

    // if {prepare} was not called, then use the default values and encode the data
    if (defaults) {
      // set the default values
      setDefaultValues();
      // encode the other immutable args
      otherImmutableArgs = encodeImmutableArgs();
      // encode the init data
      initData = encodeInitData();
    }

    // deploy the instance
    instance = deployModuleInstance(factory, implementation, hatId, otherImmutableArgs, initData);

    vm.stopBroadcast();

    if (verbose) {
      console2.log("Instance:", instance);
    }
  }

  // forge script script/HatsOnboardingShaman.s.sol:DeployInstance -f ethereum --broadcast --verify
}
