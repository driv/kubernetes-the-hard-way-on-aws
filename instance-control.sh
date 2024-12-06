#!/bin/bash
# stop-cluster.sh
stop_cluster() {
    # Get all instance IDs with tag values k8s-server or k8s-node0
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=k8s-server,k8s-node0" "Name=instance-state-name,Values=running" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)

    if [ -z "$INSTANCE_IDS" ]; then
        echo "No running instances found"
        return 0
    fi

    echo "Stopping instances: $INSTANCE_IDS"
    aws ec2 stop-instances --instance-ids $INSTANCE_IDS
    echo "Waiting for instances to stop..."
    aws ec2 wait instance-stopped --instance-ids $INSTANCE_IDS
    echo "All instances stopped"
}

#!/bin/bash
# start-cluster.sh
start_cluster() {
    # Get all instance IDs with tag values k8s-server or k8s-node0
    INSTANCE_IDS=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=k8s-server,k8s-node0" "Name=instance-state-name,Values=stopped" \
        --query "Reservations[].Instances[].InstanceId" \
        --output text)

    if [ -z "$INSTANCE_IDS" ]; then
        echo "No stopped instances found"
        return 0
    }

    echo "Starting instances: $INSTANCE_IDS"
    aws ec2 start-instances --instance-ids $INSTANCE_IDS
    echo "Waiting for instances to start..."
    aws ec2 wait instance-running --instance-ids $INSTANCE_IDS
    echo "All instances started"

    # Print the public IPs
    echo "Instance Public IPs:"
    aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=k8s-server,k8s-node0" "Name=instance-state-name,Values=running" \
        --query "Reservations[].Instances[].[Tags[?Key=='Name'].Value|[0],PublicIpAddress]" \
        --output text
}

# Automated shutdown at specific time
#!/bin/bash
# schedule-shutdown.sh
setup_scheduled_shutdown() {
    # Create cron jobs for shutdown and startup
    (crontab -l 2>/dev/null; echo "0 18 * * 1-5 /path/to/stop-cluster.sh") | crontab -
    (crontab -l 2>/dev/null; echo "0 8 * * 1-5 /path/to/start-cluster.sh") | crontab -
    echo "Scheduled cluster shutdown at 6 PM and startup at 8 AM on weekdays"
}
