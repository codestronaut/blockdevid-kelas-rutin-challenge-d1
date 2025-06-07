// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

contract AcademicSystem {
    struct Student {
        uint256 id;
        string name;
        string major;
        uint256[] grade;
        bool isActive;
    }
    
    mapping(uint256 => Student) public student;
    mapping(address => bool) public authorized;
    uint256[] public listOfId;
    
    event StudentEnrolled(uint256 id, string name);
    event Graded(uint256 id, uint256 grade);
    
    modifier onlyAuthorized() {
        require(authorized[msg.sender], "Not authorized.");
        _;
    }
    
    constructor() {
        authorized[msg.sender] = true;
    }
    
    function enroll(uint256 _id, string memory _name, string memory _major) public onlyAuthorized {
        require(student[_id].id != _id, "Student already enrolled.");
        student[_id] = Student({
            id: _id,
            name: _name,
            major: _major,
            grade: new uint256[](0),
            isActive: true
        });

        listOfId.push(_id);
        emit StudentEnrolled(_id, _name);
    }

    function grade(uint256 _id, uint256 _grade) public onlyAuthorized {
        student[_id].grade.push(_grade);
        emit Graded(_id, _grade);
    }

    function getStudentInfo(uint256 _id) public view returns(Student memory) {
        require(student[_id].isActive, "Student no longer active");
        return student[_id];
    }
}