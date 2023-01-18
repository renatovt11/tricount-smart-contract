//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

contract Tricount {

    struct AddressBalance {
        address existingAddress;
        int currentAmount;
    }

    struct Balance {
        int amount;
        bool exists;
    }

    struct BalanceToDiscount {
        address addressToDiscount;
        int amountToDiscount;
    }

    mapping(address => Balance) public balances;
    address[] public addresses;
    event newAmount();

    constructor(address[] memory addresses_) {
        addresses = addresses_;
        for (uint i = 0; i < addresses_.length; i++) {
            balances[addresses_[i]] = Balance(0, true);
        }
    }

    function setAddresses(address[] memory incomingAddresses) public {
        addresses = incomingAddresses;
        for (uint i = 0; i < incomingAddresses.length; i++) {
            balances[incomingAddresses[i]] = Balance(0, true);
        }
    }

    function addAmount(int amount, BalanceToDiscount[] memory balancesToDiscount) public {
        require(addressExistsInBalance(), "Address does not exists in balances");
        require(amountsMatchWithTotal(amount, balancesToDiscount), "Amounts to discount does not match with the total one");
        addAmountToAccount(msg.sender, amount);
        if (balancesToDiscount.length != 0) {
            discountToDefinedBalances(balancesToDiscount);
        } else {
            discountToAllBalances(amount);
        }
        emit newAmount();
    }

    function addressExistsInBalance() public view returns(bool) {
        return balances[msg.sender].exists;
    }

    function amountsMatchWithTotal(int totalAmount, BalanceToDiscount[] memory balancesToDiscount) private pure returns(bool) {
        if (balancesToDiscount.length == 0) {
            return true;
        }
        int totalAmountsToDiscount = 0;
        for (uint i = 0; i < balancesToDiscount.length; i++) {
            totalAmountsToDiscount += balancesToDiscount[i].amountToDiscount;
        }
        return totalAmount == totalAmountsToDiscount;
    }

    function discountToAllBalances(int amount) private {
        int amountToDiscount = amount / (int(addresses.length) - 1);
        for (uint i = 0; i < addresses.length; i++) {
            if (addresses[i] != msg.sender) {
                discountAmountToAccount(addresses[i], amountToDiscount);
            }
        }
    }

    function discountToDefinedBalances(BalanceToDiscount[] memory balancesToDiscount) private {
        for (uint i = 0; i < balancesToDiscount.length; i++) {
            if (balancesToDiscount[i].addressToDiscount != msg.sender) {
                discountAmountToAccount(balancesToDiscount[i].addressToDiscount, balancesToDiscount[i].amountToDiscount);
            }
        }
    }

    function addAmountToAccount(address expectedAddress, int amount) private {
        balances[expectedAddress].amount = balances[expectedAddress].amount + amount;
    }

    function discountAmountToAccount(address expectedAddress, int amount) private {
        balances[expectedAddress].amount = balances[expectedAddress].amount - amount;
    }

    function getAddresses() public view returns (address[] memory){
        return addresses;
    }

    function getAddressesBalances() public view returns (AddressBalance[] memory){
        AddressBalance[] memory existingBalances = new AddressBalance[](addresses.length);
        for (uint i = 0; i < addresses.length; i++) {
            existingBalances[i] = AddressBalance(addresses[i],balances[addresses[i]].amount);
        }
        return existingBalances;
    }

}