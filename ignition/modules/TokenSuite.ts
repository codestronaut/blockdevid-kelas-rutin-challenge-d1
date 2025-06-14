import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

module.exports = buildModule("TokenSuiteModule", (m) => {
  // Deploy ERC-20: CampusCredit.
  // Initial treasury: 10000000 CCR
  const campusCredit = m.contract("CampusCredit", ["10000000"]);

  // ERC-20: CampusCredit: Setup initial configurations.

  // ERC-20: CampusCredit: Merchants.
  const registerMerchant1 = m.call(
    campusCredit,
    "registerMerchant",
    ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "Kafetaria"],
    { id: "registerMerchant1" }
  );

  const registerMerchant2 = m.call(
    campusCredit,
    "registerMerchant",
    ["0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "Bookstore"],
    { id: "registerMerchant2", after: [registerMerchant1] }
  );

  const registerMerchant3 = m.call(
    campusCredit,
    "registerMerchant",
    ["0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB", "Bookstore"],
    { id: "registerMerchant3", after: [registerMerchant2] }
  );

  // ERC-20: CampusCredit: Students.
  const mint1 = m.call(
    campusCredit,
    "mint",
    ["0x617F2E2fD72FD9D5503197092aC168c91465E7f2", "2000000"],
    { id: "mint1", after: [registerMerchant3] }
  );

  //   // Transaction without cashback.
  //   // Case: buying coffee at Kafetaria merchant (30000 CCR).
  //   m.call(
  //     campusCredit,
  //     "transferWithLimit",
  //     ["0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "30000"],
  //     {
  //       id: "merchantTransactionWithoutCashback",
  //       from: "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
  //       after: [mint1],
  //     }
  //   );

  //   // Transaction with cashback.
  //   // Case: buying a comic at Bookstore merchant (80000 CCR).
  //   m.call(
  //     campusCredit,
  //     "transferWithCashback",
  //     ["0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db", "50000"],
  //     {
  //       id: "merchantTransactionWithCashback",
  //       from: "0x617F2E2fD72FD9D5503197092aC168c91465E7f2",
  //       after: [mint1],
  //     }
  //   );

  // Deploy ERC-721: StudentID.
  const studentId = m.contract("StudentID");

  // ERC-721: StudentID: Setup initial configurations.

  // ERC-721: StudentID: Students.
  m.call(
    studentId,
    "issueStudentID",
    [
      "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2",
      "1103184090",
      "Aditya",
      "Computer Engineering",
      "Sample URI 1",
    ],
    { id: "issueStudentID1" }
  );

  m.call(
    studentId,
    "issueStudentID",
    [
      "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db",
      "1103184085",
      "Adine",
      "Computer Engineering",
      "Sample URI 2",
    ],
    { id: "issueStudentID2" }
  );

  m.call(
    studentId,
    "issueStudentID",
    [
      "0x78731D3Ca6b7E34aC0F824c42a7cC18A495cabaB",
      "1103184175",
      "Luce",
      "Computer Engineering",
      "Sample URI 3",
    ],
    { id: "issueStudentID3" }
  );

  return { campusCredit, studentId };
});
