import { buildModule } from "@nomicfoundation/hardhat-ignition/modules";

module.exports = buildModule("TokenSuiteModule", (m) => {
  // Deploy ERC-20: CampusCredit.
  // Initial treasury: 10000000 CCR
  const campusCredit = m.contract("CampusCredit", ["10000000"]);

  // Setup initial configurations.

  // Merchants.
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

  // Students.
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

  return { campusCredit };
});
