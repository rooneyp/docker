#!/bin/bash

HOST=localhost
PORT=8091
if [ ! $# -eq 0 ]; then
    HOST=$1
    PORT=$2
fi

SERVER=http://${HOST}:${PORT}

curl -X POST ${SERVER}/pools/default -d memoryQuota=300 -d indexMemoryQuota=300
curl ${SERVER}/node/controller/setupServices -d 'services=kv%2Cn1ql%2Cindex'
curl -X POST ${SERVER}/settings/web -d port=${PORT} -d username=Administrator -d password=password
curl -u Administrator:password -X POST ${SERVER}/sampleBuckets/install -d '["travel-sample"]'
curl -i -u Administrator:password -X POST ${SERVER}/settings/indexes -d 'storageMode=memory_optimized'

echo "Sleeping to wait for index creation..."
sleep 30s
docker exec -ti couchbase /opt/couchbase/bin/cbq -s 'select * from `travel-sample` limit 1;'
