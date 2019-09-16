helm repo add k8s-jmeter https://kaarolch.github.io/kubernetes-jmeter/charts/

helm install -n jmeter k8s-jmeter/jmeter --set grafana.enabled=true,influxdb.enabled=true

# NOTES:
# JMeter is now starting.


# To get get a shell session on the master you only need to run:

export MASTER_NAME=$(kubectl get pods -l app.kubernetes.io/component=master -o jsonpath='{.items[*].metadata.name}')
kubectl exec -it $MASTER_NAME -- /bin/bash


# To copy your test plans to the master pod:
kubectl cp Auzmor_01_AdminInsights.jmx $MASTER_NAME:/jmeter
kubectl cp Auzmor_02_LearnerV0.1.jmx $MASTER_NAME:/jmeter

# To run your test in all servers you need first a list of all servers IPs (comma-separated) and then you can run your test:
export SERVER_IPS=$(kubectl get pods -l app.kubernetes.io/component=server -o jsonpath='{.items[*].status.podIP}' | tr ' ' ',')
# kubectl exec -it $MASTER_NAME -- jmeter -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.output_format=csv -n -t /jmeter/Auzmor_01_AdminInsights.jmx -l /jmeter/result.jtl -e -o /jmeter/
# kubectl exec -it $MASTER_NAME -- jmeter -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.output_format=csv -n -t /jmeter/Auzmor_01_AdminInsights.jmx -l /jmeter/result/result.jtl -e -o /jmeter/result/ -R $SERVER_IPS



kubectl exec -it $MASTER_NAME -- jmeter -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.output_format=csv -n -t /jmeter/Auzmor_02_LearnerV0.1.jmx -l /jmeter/result.jtl -e -o /jmeter/results -R $SERVER_IPS

# jmeter -Jjmeter.save.saveservice.output_format=xml -Jjmeter.save.saveservice.output_format=csv -n -t /jmeter/Auzmor_01_AdminInsights.jmx -l /jmeter/result.jtl -e -o /jmeter/RawResult.csv


# kubectl cp examples/simple_test.jmx $(kubectl get pod -l "app=jmeter-master" -o jsonpath='{.items[0].metadata.name}'):/test/

# kubectl cp Auzmor_01_AdminInsights.jmx $(kubectl get pod -l "app=jmeter-master" -o jsonpath='{.items[0].metadata.name}'):/test/

# kubectl exec  -it $(kubectl get pod -l "app=jmeter-master" -o jsonpath='{.items[0].metadata.name}') -- sh -c 'ONE_SHOT=true; /run-test.sh'


# kubectl exec -it $MASTER_NAME -- jmeter -Jjmeter.save.saveservice.output_format=csv -n -t /jmeter/LMSAdminV2.jmx -l /jmeter/result.jtl -e -o /jmeter/results -R $SERVER_IPS



#kubectl cp \$MASTER_NAME:/jmeter/result${BUILD_NUMBER}.jtl result${BUILD_NUMBER}.jtl