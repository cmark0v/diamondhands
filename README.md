

This is a time lock contract. It emits available funds linearly, so that x% of the funds are available when x% of the timelock period has passed. Withdrawls and deposits can be made at any point during the time lock period, and will not affect the amount of funds available for withdrawl. The state of the locked tokens is stored in a single uint256, which can be thought of as the average age of the tokens. 

To test:
- run `yarn setup` to setup the submodules and install dependencies. 
- run `yarn chain` to start a local hardhat node then you can run `yarn jstest`
- you can set a main net provider RPC url as environment varialbe `ETH_RPC_URL`. Then you may run `yarn hevmtest` to run hevm tests.

