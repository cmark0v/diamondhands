

This is a time lock contract. It emits available funds lienarly, so that x% of the funds are available when x% of the timelock period has passed. Withdrawls and deposits can be made at any point during the time lock period, and will not affect the amount of funds available for withdrawl. The state of the locked tokens is stored in a single uint256, which can be thought of as the average age of the tokens. 

To test, first run `yarn setup` or `make setup` to setup the submodules. Then you must set a main net provider RPC url as environment varialbe `ETH_RPC_URL`. Then you may run `yarn hevmtest` to run hevm tests. or run `yarn chain` to run the local hardhat node, and in another window `yarn jstest` to run the javascript tests. `yarn test` will run both. 
