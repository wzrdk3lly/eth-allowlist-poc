### Overview

This repository is a foundry POC for the ETH allowlist implementation, originally created by the yearn team. See [ yearn's README.md](/src/contracts/eth-allowlist/README.md) for details on the allow list. At a high level the eth-allowlist implementation helps mitigate DNS spoofing and man in the middle attacks by validating calldata that a protocol owner has allowListed.

### Objective

The objective is to create an allowlist POC for an fake protocol. In this scenario the fake protocol will be called InvestX. It is a simple dapp, that accepts Fake usd (FUSD) and deposits these tokens into a pool. We will be creating an allowList implementation that prevents malicous calls from beng made to the InvestX dapp. One key thing to note is that, direct smart contract calls are not prevented. This functionality is to be applied to API calls and wallet integration calls.

### Navigating this Repo

- src/contracts/eth-allowlist
  - This is a slightly altered version of the original [eth-allowlist](https://github.com/yearn/eth-allowlist/tree/03f2a9ad5716abd0dbfc6d45885f5d6a04061edc) by the yearn team. All of the contents in the foler allow support for the eth-allowlist.
- src/contracts/InvestX
  - This contains the code for fusd tokens and for the fake protocol that accepts fusd tokens.
  - InvestXImplementation is the cutom implementation contract for the eth allowlist
- test/allowList.t.sol
  - This is the file that holds the allow list test. It performs key operations such as registering a protocol, adding an implementation contract, adding conditions, and validating conditions.
- test/invstX.t.sol
  - This is where all the investx specific test are
- test/investXimplem.t.sol
  - This is where the investX implementation contract test are

### Alterations

The scope of this POC is limited to the eth allowList and the fake protocol. This POC does NOT include the ENS oracle and registry contracts. There were slight alterations made to the allowlist registry to prevent having to configure and deploy an ENS oracle and ENS registry. The assumption was made that the ENS registry and ENS oracle should work as intended.

The changes to support the scope of this POC include:

- Setting a hardcoded protocolOwnerAddress rather than making the call to the ENS Oracle contracts.
- Implementing a timelock ability for reregistering protocols. This will help mitigate protocol takeovers and attackers who attempt to create a new allowList implementation.

### Installation

When you have foundry installed, clone this repo and run `forge build`.

run this commnand `forge test --match-path path/to/test/file`. EX: forge test `forge test --match-path test/allowList.t.sol`
