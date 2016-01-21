# Linode initial steps 

* Create a Centos 7 64 bit machine
* Create a raw drive device, and label it 'docker-raw'. 
* Go to Dashboard -> Linodes » (binarytemple) » centos-binarytemple » Edit Configuration Profile
* Edit 'Block Device Assignment' - assign 'docker-raw' to '/dev/xvdc' 

# Configure device mapper (LVM) appropriately for use with docker in production

https://docs.docker.com/engine/userguide/storagedriver/device-mapper-driver/

Verify the presence of the raw device

```
lsblk -p --list
```
    NAME      MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
    /dev/xvda 202:0    0    4G  0 disk /
    /dev/xvdb 202:16   0  516M  0 disk [SWAP]
    [root@li198-71 ~]# s/dev/xvdc 202:32   0 43.5G  0 disk 

```
root@li198-71 ~]# sudo pvcreate /dev/xvdc 
```
    Physical volume "/dev/xvdc" successfully created

```
sudo vgcreate vg-docker /dev/xvdc 
```
    Volume group "vg-docker" successfully created

```
sudo lvcreate -L 20G -n data vg-docker
```
    Logical volume "data" created.

```
sudo lvcreate -L 4G -n metadata vg-docker
```
  Logical volume "metadata" created.




# Host steps 

```
sudo reboot






sudo yum -y install lvm2
sudo yum -y update
sudo tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

sudo yum -y install docker-engine
```

# Configure docker via systemd to use LVM 

Edit the file `/usr/lib/systemd/system/docker.service` 

```
sudo tee /usr/lib/systemd/system/docker.service <<-'EOF'
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network.target docker.socket
Requires=docker.socket

[Service]
Type=notify
ExecStart=/usr/bin/docker daemon --storage-driver=devicemapper \
--storage-opt dm.datadev=/dev/vg-docker/data \
--storage-opt dm.metadatadev=/dev/vg-docker/metadata 
MountFlags=slave
LimitNOFILE=1048576
LimitNPROC=1048576
LimitCORE=infinity

[Install]
WantedBy=multi-user.target
EOF
```

Because we manually modified the 'docker.service' systemd configuration file we need to issue a reload to `systemctl`.
```
sudo systemctl daemon-reload
```

Remove the docker config directory (otherwise it will get confused)

```
sudo rm -rf /var/lib/docker
```

Start the docker service 

```
sudo service docker start
```

Request info of the docker service

```
sudo docker info
```

Run the docker hello-world example

```
sudo docker run hello-world
```

Run the ubuntu image 

```
docker run -it ubuntu bash
```

(don't forget to exit from ubuntu)



