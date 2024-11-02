// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DataStorage {
    // Define the struct
    struct DataItem {
        string fname;
        string lname;
        string dob;
        string fatherName;
        uint256 age;
        address publicKey;
    }

    address authorityAddress;

    // Array to store user addresses for iteration
    address[] private userAddresses;

    constructor() {
        authorityAddress = 0xF3b456F10C60983808BBDE8Ee6d7B6a1dff9e3Cb;
    }

    // Mappings to store data items and IPFS hashes by user address
    mapping(address => DataItem) private dataItems;
    mapping(address => string) private userDataHash;

    // Event to emit when a new DataItem is uploaded
    event DataItemUploaded(string fname, string lname, string dob, string fatherName, uint256 age);
    event DataHashUploaded(address indexed user, string ipfsHash);

    // Function to upload a DataItem
    function uploadDataItem(string memory _fname, string memory _dob, string memory _fathersName, string memory _lname, uint256 _age) public {
        // Check if the user already has a DataItem
        if (dataItems[msg.sender].publicKey == address(0)) {
            userAddresses.push(msg.sender); // Add to user addresses array if new user
        }

        DataItem memory userDataItem = DataItem({
            fname: _fname,
            lname: _lname,
            age: _age,
            fatherName: _fathersName,
            dob: _dob,
            publicKey: msg.sender
        });

        // Store the DataItem in the mapping
        dataItems[msg.sender] = userDataItem;

        // Emit the event
        emit DataItemUploaded(_fname, _lname, _dob, _fathersName, _age);
    }

    // Function to retrieve a DataItem by address
    function getData(address _userAddress) public view returns (DataItem memory) {
        return dataItems[_userAddress];
    }

    // Function to upload IPFS hash associated with a user address
    function uploadDataHash(address _userAddress, string memory ipfsHash) public {
        // Verify the caller is authorized
        require(
            msg.sender == authorityAddress,
            "Not authorized to upload IPFS hash for this user."
        );

        // Store the IPFS hash in the mapping
        userDataHash[_userAddress] = ipfsHash;

        // Emit the event
        emit DataHashUploaded(_userAddress, ipfsHash);
    }

    // Function to retrieve IPFS hash by user address
    function getDataHash(address _userAddress) public view returns (string memory) {
        return userDataHash[_userAddress];
    }

    // Function that only the authority can call to fetch all DataItems
    function getAllDataItems() public view returns (DataItem[] memory) {
        require(msg.sender == authorityAddress, "Only the authority can access this data.");

        // Create an array to hold all DataItems
        DataItem[] memory allDataItems = new DataItem[](userAddresses.length);
        
        // Populate the array with DataItems from each user address
        for (uint256 i = 0; i < userAddresses.length; i++) {
            allDataItems[i] = dataItems[userAddresses[i]];
        }

        return allDataItems;
    }
}
