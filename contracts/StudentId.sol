// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title StudentID
 * @dev NFT-based student identity card
 * Features:
 * - Auto-expiry after 4 years
 * - Renewable for active students
 * - Contains student metadata
 * - Non-transferable (soulbound)
 */
contract StudentID is ERC721, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    struct Student {
        string id;
        string name;
        string major;
        uint256 enrollmentDate;
        uint256 expiryDate;
        uint8 semester;
        bool isActive;
    }

    // Mappings.
    mapping(uint256 => Student) public student;
    mapping(string => uint256) public idToTokenId;
    mapping(address => uint256) public addressToTokenId;

    // Events.
    event StudentIdIssued(
        uint256 indexed tokenId,
        string id,
        address student,
        uint256 expiryDate
    );
    event StudentIdRenewed(uint256 indexed tokenId, uint256 newExpiryDate);
    event StudentStatusUpdated(uint256 indexed tokenId, bool isActive);
    event ExpiredIdBurned(uint256 indexed tokenId);

    constructor() ERC721("Student Identity Card", "SID") Ownable(msg.sender) {}

    /**
     * @dev Override _update function to make non-transferable.
     * Use case: Make soulbound (non-transferable).
     */
    function _update(
        address to,
        uint256 tokenId,
        address auth
    ) internal override returns (address) {
        address from = _ownerOf(tokenId);
        require(
            from == address(0) || to == address(0),
            "SID is non-transferable"
        );
        return super._update(to, tokenId, auth);
    }

    /**
     * @dev Override: tokenURI.
     */
    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    /**
     * @dev Override: supportsInterface.
     */
    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    /**
     * @dev Issue new student ID.
     * Use case: New student enrollment.
     */
    function issueStudentID(
        address _to,
        string memory _id,
        string memory _name,
        string memory _major,
        string memory _uri
    ) public onlyOwner {
        require(idToTokenId[_id] == 0, "Student ID already registered.");
        require(
            addressToTokenId[_to] == 0,
            "Student address already have Token ID."
        );

        // New Token ID generation & expiry date calculation.
        uint256 tokenId = _nextTokenId++;
        uint256 expiryDate = block.timestamp + (4 * 365 days);

        _safeMint(_to, tokenId);
        _setTokenURI(tokenId, _uri);

        student[tokenId] = Student({
            id: _id,
            name: _name,
            major: _major,
            enrollmentDate: block.timestamp,
            expiryDate: expiryDate,
            semester: 1,
            isActive: true
        });

        idToTokenId[_id] = tokenId;
        emit StudentIdIssued(tokenId, _id, _to, expiryDate);
    }

    /**
     * @dev Renew student ID.
     * Use case: Student proceeds to next semester.
     */
    function renewStudentID(uint256 _tokenId) public onlyOwner {
        require(
            idToTokenId[student[_tokenId].id] >= 0,
            "Tokenn ID doesn't exists."
        );

        require(student[_tokenId].isActive, "Student inactive.");

        // Extending the expiry date (extra 6 months).
        // Update the semester.
        student[_tokenId].expiryDate += (0.5 * 365 days);
        student[_tokenId].semester++;

        emit StudentIdRenewed(_tokenId, student[_tokenId].expiryDate);
    }

    /**
     * @dev Update student status (active/inactive).
     * Use case: Leave, Drop Out, atau Graduated.
     */
    function updateStudentStatus(uint256 _tokenId, bool _isActive)
        public
        onlyOwner
    {
        student[_tokenId].isActive = _isActive;
        emit StudentStatusUpdated(_tokenId, _isActive);
    }

    /**
     * @dev Check if ID is expired.
     */
    function isExpired(uint256 _tokenId) public view returns (bool) {
        return block.timestamp > student[_tokenId].expiryDate;
    }

    /**
     * @dev Burn expired ID.
     * Use case: Cleanup expired cards.
     */
    function burnExpired(uint256 _tokenId) public {
        require(
            idToTokenId[student[_tokenId].id] >= 0,
            "Token ID doesn't exists."
        );

        require(isExpired(_tokenId), "Token ID doesn't expired yet.");

        // Burning token and Cleaning up mappings.
        _burn(_tokenId);
        delete student[_tokenId];
        delete idToTokenId[student[_tokenId].id];
        delete addressToTokenId[_ownerOf(_tokenId)];

        emit ExpiredIdBurned(_tokenId);
    }

    /**
     * @dev Get student info by id.
     */
    function getStudentById(string memory _id)
        public
        view
        returns (
            address owner,
            uint256 tokenId,
            Student memory data
        )
    {
        return (
            _ownerOf(idToTokenId[_id]),
            idToTokenId[_id],
            student[idToTokenId[_id]]
        );
    }
}
