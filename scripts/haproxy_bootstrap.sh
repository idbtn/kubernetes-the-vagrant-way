#!/bin/bash

# Add all hostnames to /etc/hosts files on each server:
sudo su -c 'echo "192.168.11.10    loadbalancer1.idbtn.net       loadbalancer1
192.168.11.21    kubernetesmaster1.idbtn.net   kubernetesmaster1
192.168.11.22    kubernetesmaster2.idbtn.net   kubernetesmaster2
192.168.11.23    kubernetesmaster3.idbtn.net   kubernetesmaster3
192.168.11.31    kubernetesnode1.idbtn.net     kubernetesnode1
192.168.11.32    kubernetesnode2.idbtn.net     kubernetesnode2
192.168.11.33    kubernetesnode3.idbtn.net     kubernetesnode3" >> /etc/hosts'

# Install haproxy.
sudo yum install haproxy -y

# Create errors directory.
sudo mkdir -p /etc/haproxy/errors/

# Create /run/haproxy directory for binding UNIX sockets.
sudo mkdir -p /run/haproxy/

# Make sure wget is installed.
sudo yum install wget -y

# Download error files to the created errors directory.
sudo wget https://raw.githubusercontent.com/joyent/haproxy-1.4/master/examples/errorfiles/400.http -O /etc/haproxy/errors/400.http
sudo wget https://raw.githubusercontent.com/joyent/haproxy-1.4/master/examples/errorfiles/403.http -O /etc/haproxy/errors/403.http
sudo wget https://raw.githubusercontent.com/joyent/haproxy-1.4/master/examples/errorfiles/408.http -O /etc/haproxy/errors/408.http
sudo wget https://raw.githubusercontent.com/joyent/haproxy-1.4/master/examples/errorfiles/500.http -O /etc/haproxy/errors/500.http
sudo wget https://raw.githubusercontent.com/joyent/haproxy-1.4/master/examples/errorfiles/502.http -O /etc/haproxy/errors/502.http
sudo wget https://raw.githubusercontent.com/joyent/haproxy-1.4/master/examples/errorfiles/503.http -O /etc/haproxy/errors/503.http
sudo wget https://raw.githubusercontent.com/joyent/haproxy-1.4/master/examples/errorfiles/504.http -O /etc/haproxy/errors/504.http

# Add haproxy configuration file.
sudo su -c 'cat > /etc/haproxy/haproxy.cfg << EOF

#---------------------------------------------------------------------
# Example configuration for a possible web application.  See the
# full configuration options online.
#
#   http://haproxy.1wt.eu/download/1.4/doc/configuration.txt
#
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# Global settings
#---------------------------------------------------------------------
global
    # to have these messages end up in /var/log/haproxy.log you will
    # need to:
    #
    # 1) configure syslog to accept network log events.  This is done
    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
    #    /etc/sysconfig/syslog
    #
    # 2) configure local2 events to go to the /var/log/haproxy.log
    #   file. A line like the following can be added to
    #   /etc/sysconfig/syslog
    #
    #    local2.*                       /var/log/haproxy.log
    #
    log         127.0.0.1 local2

    chroot      /var/lib/haproxy
    pidfile     /var/run/haproxy.pid
    stats socket /run/haproxy/admin.sock mode 660 level admin
    stats timeout 30s
    maxconn     4000
    user        haproxy
    group       haproxy
    daemon

    # turn on stats unix socket
    stats socket /var/lib/haproxy/stats

#---------------------------------------------------------------------
# common defaults that all the 'listen' and 'backend' sections will
# use if not designated in their block
#---------------------------------------------------------------------
defaults
    mode                    tcp
    log                     global
    option                  tcplog
    option                  dontlognull
    timeout connect         5000
    timeout client          50000
    timeout server          50000
    errorfile 400 /etc/haproxy/errors/400.http
    errorfile 403 /etc/haproxy/errors/403.http
    errorfile 408 /etc/haproxy/errors/408.http
    errorfile 500 /etc/haproxy/errors/500.http
    errorfile 502 /etc/haproxy/errors/502.http
    errorfile 503 /etc/haproxy/errors/503.http
    errorfile 504 /etc/haproxy/errors/504.http

#---------------------------------------------------------------------
# main frontend which proxys to the backends
#---------------------------------------------------------------------
frontend k8s
    bind 192.168.11.10:6443 # Port 6443 needs to be added to firewall rules.
    default_backend k8s_backend
#---------------------------------------------------------------------
# static backend for serving up images, stylesheets and such
#---------------------------------------------------------------------

#---------------------------------------------------------------------
# round robin balancing between the various backends
#---------------------------------------------------------------------
backend k8s_backend
    balance     roundrobin
    mode        tcp
    server  kubernetesmaster1.idbtn.net 192.168.11.21:6443 check inter 1000
    server  kubernetesmaster2.idbtn.net 192.168.11.22:6443 check inter 1000
    server  kubernetesmaster3.idbtn.net 192.168.11.23:6443 check inter 1000
EOF'

# Add tcp port 6443 to firewall rules.
sudo firewall-cmd --permanent --add-port=6443/tcp

# Reload firewalld.
sudo firewall-cmd --reload

# Update SELinux rules to allow HAProxy to bind to addresses.
sudo setsebool -P haproxy_connect_any=1

# Enable haproxy service.
sudo systemctl enable haproxy.service

# Start haproxy service.
sudo systemctl start haproxy.service

# Check the haproxy status.
sudo systemctl status haproxy.service

# Print finish message.
echo "====================================="
echo "========= Done with HAProxy ========="
echo "====================================="

exit 0
