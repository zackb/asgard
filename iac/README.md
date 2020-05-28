
curl -i -H 'Content-Type: application/json' -XPUT --data-binary '{"hello":"world"}' asgard.jeedup.net/fs/foo/bar

curl -i -XPOST --data-binary 'hello queue' asgard.jeedup.net/node/queue

curl -i -XPOST --data-binary 'hello broadcast' asgard.jeedup.net/node/broadcast

curl -i -XPOST --data-binary 'hello stream' asgard.jeedup.net/node/stream




helm --kubeconfig=kubeconfig.yaml install cassandra incubator/cassandra --set config.cluster_size=3 --set resources.requests.memory=2Gi --set resources.limits.memory=3Gi
