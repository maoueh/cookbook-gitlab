### Production installation with Chef Solo

This guide details installing a GitLab server with Chef Solo. By using Chef Solo you do not need a decicated Chef Server.

### Requirements

Ubuntu 12.04 or CentOS 6.4

### Installation

To get GitLab installed first install the basic system packages:

```bash
## Ubuntu
sudo apt-get update
sudo apt-get install -y build-essential git # We need git to clone the cookbook, newer version will be compiled using the cookbook
```

```bash
## Centos
yum groupinstall -y "Development Tools"
```

Following steps are the same for both OS:

```bash
cd /tmp
curl -LO https://www.opscode.com/chef/install.sh && sudo bash ./install.sh -v 11.4.4
sudo /opt/chef/embedded/bin/gem install berkshelf --no-ri --no-rdoc
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git /tmp/cookbook-gitlab
cd /tmp/cookbook-gitlab
/opt/chef/embedded/bin/berks install --path /tmp/cookbooks
cat > /tmp/solo.rb << EOF
cookbook_path    ["/tmp/cookbooks/"]
log_level        :debug
EOF
cat > /tmp/solo.json << EOF
{"gitlab": {"host": "HOSTNAME", "url": "http://FQDN:80/"}, "recipes":["gitlab::default"]}
EOF
sudo chef-solo -c /tmp/solo.rb -j /tmp/solo.json
```
Chef-solo command should start running and setting up GitLab and it's dependencies.
No errors should be reported and at the end of the run you should be able to navigate to the
`HOSTNAME` you specified using your browser and connect to the GitLab instance.

### Usage

Add `gitlab::default` to the run list of chef-client.

To override default settings of this cookbook you have to supply a json to the node.

```json
{
  "postfix": {
    "mail_type": "client",
    "myhostname": "mail.example.com",
    "mydomain": "example.com",
    "myorigin": "mail.example.com",
    "smtp_use_tls": "no"
  },
  "postgresql": {
    "password": {
      "postgres": "psqlpass"
    }
  },
  "mysql": {
    "server_root_password": "rootpass",
    "server_repl_password": "replpass",
    "server_debian_password": "debianpass"
  },
  "gitlab": {
    "host": "example.com",
    "url": "http://example.com/",
    "email_from": "gitlab@example.com",
    "support_email": "support@example.com",
    "database_adapter": "postgresql",
    "database_password": "datapass"
  },
  "run_list":[
    "postfix",
    "gitlab::default"
  ]
}
```
