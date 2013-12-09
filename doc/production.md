### Production installation with Chef Solo

This guide details installing a GitLab server with Chef Solo. By using Chef Solo you do not need a decicated Chef Server.

### Requirements

* git
* ruby (>= 1.9.3)
* rubygems installed.

### Installation

To get GitLab installed do:

```bash
gem install berkshelf
cd /tmp
curl -LO https://www.opscode.com/chef/install.sh && sudo bash ./install.sh -v 11.4.4
git clone https://gitlab.com/gitlab-org/cookbook-gitlab.git /tmp/gitlab
cd /tmp/gitlab
berks install --path /tmp/cookbooks
cat > /tmp/solo.rb << EOF
cookbook_path    ["/tmp/cookbooks/", "/tmp/gitlab/"]
log_level        :debug
EOF
cat > /tmp/solo.json << EOF
{"gitlab": {"host": "HOSTNAME", "url": "http://FQDN:80/"}, "recipes":["gitlab::default"]}
EOF
chef-solo -c /tmp/solo.rb -j /tmp/solo.json
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
### Enabling HTTPS

In order to enable HTTPS you will need to provide the following custom attributes:

```json
{
  "gitlab": {
    "port": 443,
    "url": "https://example.com/",
    "ssl_certificate": "-----BEGIN CERTIFICATE-----
Lio90slsdflsa0salLfjfFLJQOWWWWFLJFOAlll0029043jlfssLSIlccihhopqs
-----END CERTIFICATE-----",
    "ssl_certificate_key": "-----BEGIN PRIVATE KEY-----
Lio90slsdflsa0salLfjfFLJQOWWWWFLJFOAlll0029043jlfssLSIlccihhopqs
-----END PRIVATE KEY-----"
  }
}
```
*Note*: SSL certificate(.crt) and SSL certificate key(.key) must be in valid format. If this is not the case nginx won't start! By default, both the certificate and key will be located in `/etc/ssl/` and will have the name of HOSTNAME, eg. `/etc/ssl/example.com.crt` and `/etc/ssl/example.com.key`.
