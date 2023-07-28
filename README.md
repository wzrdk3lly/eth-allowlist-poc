### Overview

This repository is a WIP of an POC for the ETH allowlist implementation, originally created by the yearn team.

### Objective

The objective is to create an allowlist POC for an fake protocol. In this scenario the fake protocol will be called InvestX. It is a simple dapp, that accepts Fake usd (FUSD) and deposits these tokens into a pool.

The Allowlist will need to verify the following rules:

- InvestX only allows approvals for the token FUSD with the spender being the investXpool ONLY
- InvestX only allows deposits into the FUSD-Pool address

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

- setting a hardcoded protocolOwnerAddress rather than making the call to ENS contracts.

### Installation

When you have foundry installed, clone this repo and run `forge build`.

run this commnand `forge test --match-path path/to/test/file`. EX: forge test `forge test --match-path test/allowList.t.sol`

### Tips:

- The paramaters are to be the parameters of the method you select. in an approve function you have the params(spender, amount). The spender param should corelate to your deployed implementation contract. In our case we want to validate that the spender is the investX smart contract adddress.
