all    :; dapp build
clean  :; dapp clean
deploy :; dapp create Diamondhands
setup  :; git submodule init&&git submodule update&&mv lib/ds-test/src lib/ds-test/contracts
