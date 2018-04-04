# Prometheus and Grafana on Openshift Origin

```
oc project openshift-infra
oc adm policy add-cluster-role-to-user cluster-reader -z default
oc create -f https://github.com/wangyadongd/datafoundry-document/blob/master/grafana-promethus/grafana.yaml
oc create -f https://github.com/wangyadongd/datafoundry-document/blob/master/grafana-promethus/prometheus.yaml
oc create -f https://github.com/wangyadongd/datafoundry-document/blob/master/grafana-promethus/grafana-dashboard.json
oc volume dc/prometheus --add --name=prom-k8s -m /etc/prometheus -t configmap --configmap-name=prom-k8s 
oc env dc/grafana GF_INSTALL_PLUGINS=hawkular-datasource
```
USER:admin/admin


参考文档：

https://github.com/debianmaster/openshift-examples/tree/master/promethus 
https://github.com/OpenShiftDemos/grafana-openshift 
http://www.hawkular.org/blog/2016/10/24/hawkular-metrics-openshift-and-grafana.html 
https://grafana.com/plugins/hawkular-datasource 
