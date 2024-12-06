#!/bin/bash
aws ec2 stop-instances --instance-ids $(aws ec2 describe-instances --filters "Name=tag:Project,Values=kubernetes-the-hard-way" --query "Reservations[*].Instances[*].InstanceId" --output text)

