pragma solidity ^0.4.0;

contract Sell_eth {
    uint weiForSale;
    uint price; //wei per smallest currency unit (eg. cent)   
    address seller;
    struct Buyer {uint amount; uint price; bool pending;}
    mapping(address => Buyer) buyers;

    modifier onlySeller() { if (msg.sender != seller) throw;  _; }
    
    event newWeiForSale(uint indexed wei_for_sale);
    event newPrice(uint indexed nprice);
    event purchaseConfirmed(address indexed _buyer, uint value, uint price);
    event cashReceived(address indexed rec_buyer);

    function Sell_eth(uint _price) payable {
        seller = msg.sender;
        price = _price;
        weiForSale = msg.value / 2;
        newWeiForSale(weiForSale);
        newPrice(price);
    }

    function purchase() payable {
        if (msg.value > weiForSale || (msg.value/price)%5000 != 0) throw;
        purchaseConfirmed(msg.sender, msg.value, price);
        buyers[msg.sender] = Buyer (msg.value, price, true);
        weiForSale -= msg.value;
        newWeiForSale(weiForSale);
    }

    function confirmReceived(address addr_buyer) onlySeller payable {
        Buyer rec_buyer = buyers[addr_buyer];
        cashReceived(addr_buyer);
        if (rec_buyer.pending != true) throw;
        rec_buyer.pending = false;
        uint amt = rec_buyer.amount;
        rec_buyer.amount = 0;
        if (!addr_buyer.send(2*amt)) throw;
    }
    
    function addEther() onlySeller payable {  
            weiForSale += msg.value/2;
            newWeiForSale(weiForSale);
    }

    function changePrice(uint new_price) onlySeller {
        price = new_price;
        newPrice(price);
    }
   
   function get_cont_bal() returns(uint balance) {
     return this.balance;
   }
}

    