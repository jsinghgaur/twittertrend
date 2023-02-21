#!/bin/sh
kubectl apply -f namespace.yaml
kubectl apply -f secret.ymal
kubectl apply -f deployment.yaml
kubectl apply -f service.ymal