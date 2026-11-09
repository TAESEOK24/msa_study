#!/usr/bin/env bash
#
# Sample usage:
#
#   HOST=localhost PORT=7001 ./test-em-all.bash
#
: ${HOST=localhost}
: ${PORT=8080}
: ${PROD_ID_REVS_RECS=1}
: ${PROD_ID_NOT_FOUND=13}
: ${PROD_ID_NO_RECS=113}
: ${PROD_ID_NO_REVS=213}

function assertCurl() {

  local expectedHttpCode=$1
  local curlCmd="$2 -w \"%{http_code}\""
  local result=$(eval $curlCmd)
  local httpCode="${result:(-3)}"
  RESPONSE='' && (( ${#result} > 3 )) && RESPONSE="${result%???}"

  if [ "$httpCode" = "$expectedHttpCode" ]
  then
    if [ "$httpCode" = "200" ]
    then
      echo "Test OK (HTTP Code: $httpCode)"
    else
      echo "Test OK (HTTP Code: $httpCode, $RESPONSE)"
    fi
  else
    echo  "Test FAILED, EXPECTED HTTP Code: $expectedHttpCode, GOT: $httpCode, WILL ABORT!"
    echo  "- Failing command: $curlCmd"
    echo  "- Response Body: $RESPONSE"
    exit 1
  fi
}

function assertEqual() {

  local expected=$1
  local actual=$2

  if [ "$actual" = "$expected" ]
  then
    echo "Test OK (actual value: $actual)"
  else
    echo "Test FAILED, EXPECTED VALUE: $expected, ACTUAL VALUE: $actual, WILL ABORT"
    exit 1
  fi
}

function testUrl() {
  url=$@
  if $url -ks -f -o /dev/null
  then
    return 0
  else
    return 1
  fi;
}

function waitForService() {
  url=$@
  echo -n "Wait for: $url... "
  n=0
  until testUrl $url
  do
    n=$((n + 1))
    if [[ $n == 100 ]]
    then
      echo " Give up"
      exit 1
    else
      sleep 3
      echo -n ", retry #$n "
    fi
  done
  echo "DONE, continues..."
}

set -e

echo "Start Tests:" `date`

echo "HOST=${HOST}"
echo "PORT=${PORT}"

if [[ $@ == *"start"* ]]
then
  echo "Restarting the test environment..."
  echo "$ docker compose down --remove-orphans"
  docker compose down --remove-orphans
  echo "$ docker compose up -d"
  docker compose up -d
fi


waitForService curl http://$HOST:$PORT/product-composite/$PROD_ID_REVS_RECS

# 1. 정상적인 상품 조회 (추천·리뷰 API 미구현)
assertCurl 200 "curl http://$HOST:$PORT/product-composite/$PROD_ID_REVS_RECS -s"
assertEqual $PROD_ID_REVS_RECS "$(echo "$RESPONSE" | jq .productId)"
assertEqual 0 "$(echo "$RESPONSE" | jq '.recommendations | length')"
assertEqual 0 "$(echo "$RESPONSE" | jq '.reviews | length')"

# 2. 존재하지 않는 상품 (404)
assertCurl 404 "curl http://$HOST:$PORT/product-composite/$PROD_ID_NOT_FOUND -s"
assertEqual "/product-composite/$PROD_ID_NOT_FOUND" "$(echo "$RESPONSE" | jq -r .path)"

# 3. 추천 정보가 없는 상품
assertCurl 200 "curl http://$HOST:$PORT/product-composite/$PROD_ID_NO_RECS -s"
assertEqual $PROD_ID_NO_RECS "$(echo "$RESPONSE" | jq .productId)"
assertEqual 0 "$(echo "$RESPONSE" | jq '.recommendations | length')"
assertEqual 0 "$(echo "$RESPONSE" | jq '.reviews | length')"

# 4. 리뷰 정보가 없는 상품
assertCurl 200 "curl http://$HOST:$PORT/product-composite/$PROD_ID_NO_REVS -s"
assertEqual $PROD_ID_NO_REVS "$(echo "$RESPONSE" | jq .productId)"
assertEqual 0 "$(echo "$RESPONSE" | jq '.recommendations | length')"
assertEqual 0 "$(echo "$RESPONSE" | jq '.reviews | length')"

# 5. 잘못된 상품 ID (422)
assertCurl 422 "curl http://$HOST:$PORT/product-composite/-1 -s"
assertEqual "/product-composite/-1" "$(echo "$RESPONSE" | jq -r .path)"

# 6. 숫자가 아닌 상품 ID (400)
assertCurl 400 "curl http://$HOST:$PORT/product-composite/invalidProductId -s"
assertEqual "Type mismatch." "$(echo "$RESPONSE" | jq -r .message)"

if [[ $@ == *"stop"* ]]
then
    echo "We are done, stopping the test environment..."
    echo "$ docker compose down"
    docker compose down
fi

echo "End, all tests OK:" `date`
