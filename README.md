# YNAB
YNAB CLI

This is a CLI wrapper for the You Need A Budget (YNAB) API.

## Requirements
- curl
- jq

## Setup

Put the YNAB API token in the `.ynconfig` file, or the following environment variable can be set:
```
set YNAB_TOKEN=<your token>
```

Output can be set to `raw` or `jq` using `YNOUTPUT`.

## Usage

Once you've made a request with your <budget_id>, switch to using `last-used` as the id.

For more detail on schemas, visit: https://api.youneedabudget.com/v1#/

```
ynab.sh user | help
ynab.sh <budget_id> { settings
                      accounts
                      accounts <account_id>
                      accounts <account_id> transactions
                      accounts new-account.json
                      categories
                      categories <category_id>
                      categories <category_id> transactions
                      months
                      months <month>
                      months <month> categories <category_id>
                      months <month> categories <category_id> update-category.json
                      payeelocations
                      payeelocations <payee_location_id>
                      payees
                      payees <payee_id>
                      payees <payee_id> payeelocations
                      payees <payee_id> transactions
                      transactions
                      transactions new-transactions.json
                      transactions update update-transactions.json
                      transactions <transaction_id>
                      transactions <transaction_id> update-transaction.json
                      transactions import
                      scheduled
                      scheduled <scheduled_transaction_id>
```

## Examples

Extracting flattened categories:
```
./ynab.sh last-used categories | jq '.data.category_groups[] | "\(.name) \(.id)"'
./ynab.sh last-used categories | jq | jq '.data.category_groups[].categories[] | "\(.name) \(.id)"'
```

A small script to iterate and POST example transactions in the `transactions/` folder using `ynab.sh`:
```
./send-transactions.sh
```