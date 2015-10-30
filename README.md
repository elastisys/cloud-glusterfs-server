# cloud-glusterfs-server
Gluster FS cluster packaged in Docker for being used with cloud servers (EC2, OpenStack).

This repo is a modification of the very nice [nixelsolutions/rancher-glusterfs-server](https://github.com/nixelsolutions/rancher-glusterfs-server) project, and modifications are mainly to make it work in non-Rancher environments such as typical clouds.

## Note about deployment

There is very little to point from redundancy and performance standpoints to run several of these Docker containers on the same host (virtual and physical). Don't do it.

Instead, provision new VMs for each Gluster FS node you intend to run, and then just run one of these containers there.

## Changes compared to upstream

There are two main changes, and we try to keep the number of changes as low as possible. However, not running in the Rancher environment means we must handle getting IP addresses and service discovery differently.

## Note about obtaining the IP address

Rancher does cool stuff with IP addresses and routing between containers on different hosts. We cannot assume that functionality is available. Instead, we rely on the [metadata service](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-instance-metadata.html) to tell us private and public IP addresses.

Choose which one to use by setting the environment variable `USE_PUBLIC_IP_ADDRESS` to either `true` or `false`.

## Note about service discovery

The original [nixelsolutions/rancher-glusterfs-server](https://github.com/nixelsolutions/rancher-glusterfs-server) uses Rancher's nice DNS service for service discovery. We, however, cannot assume that it is present, since we are not using Rancher.

Instead, in this version, we ask the systems administrator to enter the IP of another peer (in the [trusted pool](http://www.gluster.org/community/documentation/index.php/QuickStart)) as an environment variable. To get the system up and running, one should:

 - Provision two servers from the cloud provider (suitable security groups should be used)
 - Note the IP addresses of these servers, calling them `server1` and `server2`
 - Set the `GLUSTER_PEERS` environment variable on `server1` to the value `server2` and a container from the image
 - Similarly, set `GLUSTER_PEERS` on `server2` to be `server1` and start a container from the image

If it all works the way it is supposed to, you now have a two-node cluster with replication set up.

If you need to add nodes, provision a new VM, and set `GLUSTER_PEERS` to the list `server1 server2`. It will then connect to them via ssh, and ask them to make it a member, as Gluster FS requires.

## Using the container

The container is self-contained (ha!), so there really is no need for Docker compose or similar. However, since it just makes the command line easier, we provide one. That way, you can't forget the rather unusual privileged flag, for instance. Edit it to your liking, and then start via `docker-compose up -d`
