# Firestore Data Model Documentation

This document outlines the NoSQL data structure for the Bytebank application, using Google Cloud Firestore.

---

## Overall Structure

The database is structured around two primary top-level collections:

- **users**: Contains all data specific to each user, with sensitive information secured by Firestore rules. User-specific data like transactions and investments are stored in sub-collections.
- **metadata**: Contains global, non-sensitive application data, like the available categories for transactions, which can be read by all users.

---

## users Collection

Contains a document for every user who signs up for the application.

**Path:** `/users/{userId}`

**Description:** The document ID (`userId`) is the unique UID provided by Firebase Authentication. This is the central anchor for all of a user's data.

### Fields

| Field Name | Data Type | Required? | Description                                     |
| ---------- | --------- | --------- | ----------------------------------------------- |
| name       | String    | Yes       | The user's full name.                           |
| email      | String    | Yes       | The user's unique email address.                |
| createdAt  | Timestamp | Yes       | The date and time the user account was created. |

#### Example Document

```json
{
  "name": "João da Silva",
  "email": "joao.silva@email.com",
  "createdAt": "August 15, 2025 at 6:00:00 PM UTC-3"
}
```

---

### balances Sub-collection

Contains documents representing the different financial accounts a user has.

**Path:** `/users/{userId}/balances/{balanceId}`

**Description:** A sub-collection within a user document. A user can have one or more balance documents.

#### Fields

| Field Name  | Data Type | Required? | Description                                                                                             |
| ----------- | --------- | --------- | ------------------------------------------------------------------------------------------------------- |
| accountType | String    | Yes       | The type of account (e.g., CHECKING_ACCOUNT). The value should be an ID from `/metadata/balance_types`. |
| amount      | Number    | Yes       | The current balance of the account.                                                                     |
| currency    | String    | Yes       | The currency code for the balance (e.g., "BRL").                                                        |

#### Example Document

```json
{
  "accountType": "CHECKING_ACCOUNT",
  "amount": 10000.0,
  "currency": "BRL"
}
```

---

### transactions Sub-collection

Contains documents representing every financial transaction for a user.

**Path:** `/users/{userId}/transactions/{transactionId}`

**Description:** A sub-collection within a user document. This can scale to hold thousands of transactions per user.

#### Fields

| Field Name   | Data Type | Required? | Description                                                                           |
| ------------ | --------- | --------- | ------------------------------------------------------------------------------------- |
| amount       | Number    | Yes       | The transaction value. Negative for expenses, positive for income.                    |
| balanceId    | String    | Yes       | The ID of the balance document this transaction is associated with.                   |
| category     | String    | Yes       | The category ID from `/metadata/transaction_categories` (e.g., FOOD).                 |
| date         | Timestamp | Yes       | The exact date and time of the transaction.                                           |
| description  | String    | No        | An optional, user-written memo for the transaction.                                   |
| type         | String    | Yes       | The general type, inherited from the category metadata (e.g., expense, income).       |
| investmentId | String    | No        | If this transaction created an investment, this is the ID of the investment document. |
| receiptUrl   | String    | No        | The URL of a receipt image stored in Firebase Storage.                                |

#### Example Document

```json
{
  "amount": -75.5,
  "balanceId": "checking_account_main",
  "category": "FOOD",
  "date": "August 15, 2025 at 12:30:00 PM UTC-3",
  "description": "Almoço com a equipe",
  "type": "expense",
  "investmentId": null,
  "receiptUrl": null
}
```

---

### investments Sub-collection

Contains documents representing the investments a user has made.

**Path:** `/users/{userId}/investments/{investmentId}`

**Description:** A sub-collection within a user document to track their portfolio.

#### Fields

| Field Name | Data Type | Required? | Description                                                                          |
| ---------- | --------- | --------- | ------------------------------------------------------------------------------------ |
| name       | String    | Yes       | A user-defined, human-readable name for the investment.                              |
| amount     | Number    | Yes       | The principal amount invested.                                                       |
| category   | String    | Yes       | The high-level category ID from `/metadata/investment_options` (e.g., FIXED_INCOME). |
| type       | String    | Yes       | The specific type ID from `/metadata/investment_options` (e.g., GOVERNMENT_BOND).    |
| investedAt | Timestamp | Yes       | The date and time the investment was made.                                           |
| balanceId  | String    | Yes       | The ID of the balance from which the funds were drawn.                               |

#### Example Document

```json
{
  "name": "Tesouro Selic 2029",
  "amount": 5000.0,
  "category": "FIXED_INCOME",
  "type": "GOVERNMENT_BOND",
  "investedAt": "August 14, 2025 at 10:00:00 AM UTC-3",
  "balanceId": "checking_account_main"
}
```

---

## metadata Collection

A top-level collection containing global configuration data for the app. It is readable by all users.

### balance_types Document

**Path:** `/metadata/balance_types`

**Description:** Defines the available types of balances.

#### Example Fields

```json
{
  "types": [
    { "id": "CHECKING_ACCOUNT", "label": "Conta Corrente" },
    { "id": "SAVINGS_ACCOUNT", "label": "Conta Poupança" }
  ]
}
```

### transaction_categories Document

**Path:** `/metadata/transaction_categories`

**Description:** Defines the available categories for transactions.

#### Example Fields

```json
{
  "categories": [
    { "id": "SALARY", "label": "Salário", "type": "income" },
    { "id": "FOOD", "label": "Alimentação", "type": "expense" },
    { "id": "TRANSPORT", "label": "Transporte", "type": "expense" }
  ]
}
```

### investment_options Document

**Path:** `/metadata/investment_options`

**Description:** Defines the available options for creating new investments.

#### Example Fields

```json
{
  "options": [
    {
      "id": "FIXED_INCOME",
      "label": "Renda Fixa",
      "types": [{ "id": "GOVERNMENT_BOND", "label": "Tesouro Direto" }]
    },
    {
      "id": "VARIABLE_INCOME",
      "label": "Renda Variável",
      "types": [{ "id": "STOCK_MARKET", "label": "Ações" }]
    }
  ]
}
```
