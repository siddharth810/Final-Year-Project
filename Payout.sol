pragma solidity >=0.4.0;
import "./Ownable.sol";
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a / b;
          return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Payout {
    using SafeMath for uint256;
    uint256 internal amountForCalc1 = 0;
    uint256 internal amountForCalc2;
    uint256 internal _percentageSum = 0;
    uint256 _totalRecipients = 0;
    mapping(uint256 => address) public recipients;
    mapping(address => uint256) public shares;


    function fundContract() public payable {
        require(msg.value > 0, "Royalty amount must be higher than 0");
        amountForCalc1 = amountForCalc1.add(msg.value);
    }

    function addRecipient(uint256 _percentage, address _address)
        public
        returns (bool success)
    {
        require(
            _percentage > 0 &&
                _percentage <= 100 &&
                (_percentageSum + _percentage) <= 100,
            "Percentages are not valid"
        );

        recipients[_totalRecipients] = _address;
        shares[_address] = _percentage;
        _totalRecipients++;

        _percentageSum = _percentageSum.add(_percentage);

        return true;
    }

    function payRecipients() public payable returns (bool success) {
        require(amountForCalc1 > 0, "No funds have been sent to the contract");
        if (_percentageSum != 100) {
            return false;
        } else {
            _percentageSum = 0;
            amountForCalc2 = amountForCalc1.div(100);
            amountForCalc1 = 0;
            for (uint256 i = 0; i < _totalRecipients; i++) {
                address(recipients[i]).transfer(
                    amountForCalc2.mul(shares[recipients[i]])
                );
                delete recipients[i];
                delete shares[recipients[i]];
            }
            return true;
        }
    }
}
