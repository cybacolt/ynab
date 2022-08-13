#!/bin/bash

for i in curl jq; do
    which $i > /dev/null
done

if [ -f ".ynconfig" ]; then
    source .ynconfig
fi

if [ "$YNDEBUG" = "true" ]; then
    set -x
fi

# load token from file or env var
YNTOKEN=$YNAB_TOKEN

YNHOST="api.youneedabudget.com"
YNMETHOD="GET"
YNAUTH="Authorization: Bearer $YNTOKEN"
YNHEADERS="accept: application/json"
YNPROTOCOL="https"
YNPAYLOAD=""
YNBUDGETID=$1
YNAPIPATH="/v1/budgets/$YNBUDGETID"
command="$2"

exec()
{
    if [ ! -z $YNPAYLOAD ]; then
            output=`curl -sS -X $YNMETHOD $YNHEADERS "$YNPROTOCOL://$YNHOST$YNAPIPATH" -d $YNPAYLOAD 2>&1`
    else
            output=`curl -sS -X $YNMETHOD "$YNPROTOCOL://$YNHOST$YNAPIPATH" -H "$YNAUTH" -H "$YNHEADERS" 2>&1`
    fi

    if [ "$YNOUTPUT" = "jq" ]; then
            echo $output | jq
    elif [ $? -gt 0 ] || [ "$YNOUTPUT" = "raw" ]; then
            echo $output
    fi
}

user()
{
    YNAPIPATH="/v1/user"
}

accounts()
{
    fileoraccount=${1-}
    action=${2-}

    if [ -f "$fileoraccount" ]; then
        file=$fileoraccount
        YNPAYLOAD="-d @$file"
        YNMETHOD="POST"
        fileoraccount=""
    fi
    commonpath "accounts" $fileoraccount $action

}

categories()
{
    id=${1-}
    action=${2-}
    commonpath "categories" $id $action
}

months()
{
    id=${1-}
    action=${2-}
    actionid=${3-}
    file=${4-}
    commonpath "months" $id

    if [ -n "$actionid" ]; then
        commonpath "categories" $actionid
    fi

    if [ -n "$file" ]; then
        YNPAYLOAD="-d @$file"
        YNMETHOD="PATCH"
    fi
}

payeelocations()
{
    id=${1-}
    commonpath "payee_locations" $id
}

payees()
{
    id=${1-}
    action=${2-}
    if [ "$action" = "payeelocations" ]; then
        action="payee_locations"
    fi
    commonpath "payees" $id $action
}

transactions()
{
    YNAPIPATH=$YNAPIPATH"/transactions"
    fileoractionorid=${1-}
    file=${2-}

    if [ -f "$file" ]; then
        YNPAYLOAD="-d @$file"
        YNMETHOD="POST"
    fi

    if [ -n "$fileoractionorid" ]; then
        if [ -f "$fileoractionorid" ]; then
            YNPAYLOAD="-d @$fileoractionorid"
            YNMETHOD="POST"
        elif [ "$fileoractionorid" = "import" ] || [ "$fileoractionorid" = "update" ]; then
            action="$fileoractionorid"

            if [ "$action" = "update" ]; then
                YNMETHOD="PATCH"
            else
                YNAPIPATH=$YNAPIPATH"/$action"
            fi
        else
            transactionid=$fileoractionorid
            YNAPIPATH=$YNAPIPATH"/$transactionid"
            if [ -f "$file" ]; then
                YNMETHOD="PUT"
            fi
        fi
    fi

}

scheduled()
{
    id=${1-}
    commonpath "scheduled_transactions" $id
}

commonpath()
{
    context=${1-}
    id=${2-}
    action=${3-}

    YNAPIPATH=$YNAPIPATH"/$context"

    if [ -n "$id" ]; then
        YNAPIPATH=$YNAPIPATH"/$id"
    fi

    if [ -n "$action" ]; then
        YNAPIPATH=$YNAPIPATH"/$action"
    fi
}

help()
{
	echo "usage:  $0
        $0 user | help
        $0 <budget_id> { settings
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
                         transactions import new-transactions.json
                         scheduled
                         scheduled <scheduled_transaction_id>

        For more detail on schemas, visit: https://api.youneedabudget.com/v1#/
"
   YNAPIPATH="/v1/budgets"
}

# misc actions
case "$YNBUDGETID" in
  "user" | "help" )
        "$YNBUDGETID" "$@"
        exec
        exit
        ;;
  *)
        ;;
esac

shift 2

# budget actions
case "$command" in
  "settings" | "accounts" | "categories" | "months" | "payees" | "payeelocations" | "transactions" | "scheduled" )
        "$command" "$@"
        ;;
  *)
        ;;
esac

exec