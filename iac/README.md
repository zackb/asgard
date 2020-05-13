curl -i -H 'Content-Type: application/json' -XPUT --data-binary '{"hello":"world"}' mute.winter/fs/foo/bar

helm --kubeconfig=kubeconfig.yaml install cassandra incubator/cassandra --set config.cluster_size=3 --set resources.requests.memory=2Gi --set resources.limits.memory=3Gi
