#!/bin/bash

cd ../../source/ArmoniK.Samples

export CPIP=$(kubectl get svc control-plane -n armonik -o custom-columns="IP:.spec.clusterIP" --no-headers=true)
export ReIP=$(kubectl get svc redis -n armonik-storage -o custom-columns="IP:.spec.clusterIP" --no-headers=true)
export CPPort=$(kubectl get svc control-plane -n armonik -o custom-columns="PORT:.spec.ports[*].port" --no-headers=true)
export RePort=$(kubectl get svc redis -n armonik-storage -o custom-columns="PORT:.spec.ports[*].port" --no-headers=true)
export Grpc__Endpoint=http://$CPIP:$CPPort
export Redis__EndpointUrl=$ReIP:$RePort
export Redis__SslHost="127.0.0.1"
export Redis__Timeout=3000

cd Samples/HtcMock/Client/src
export Redis__CaCertPath=../../../../../../infrastructure/credentials/ca.crt
export Redis__ClientPfxPath=../../../../../../infrastructure/credentials/certificate.pfx

dotnet build "ArmoniK.Samples.HtcMock.Client.csproj" -c Release
dotnet bin/Release/net5.0/ArmoniK.Samples.HtcMock.Client.dll