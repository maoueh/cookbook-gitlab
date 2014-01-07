### Production installation with Chef Solo

This guide details installing a GitLab server with Chef Solo.
By using Chef Solo you do not need a decicated Chef Server.

### Requirements

Ubuntu 12.04 or CentOS 6.4

### Installation

Configure your installation parameters by editing the `/tmp/solo.json` file.
Parameters which you will likely want to customize include:

```bash
cat > /tmp/solo.json << EOF
{
  "gitlab": {
    "host": "example.com",
    "url": "http://example.com/",
    "email_from": "gitlab@example.com",
    "support_email": "support@example.com",
    "database_adapter": "mysql or postgresql",
    "database_password": "database password used by the GitLab application",
    "repository": "clone URL for e.g. GitLab Enterprise Edition; omit this line to use Community Edition",
    "revision": "branch or tag or SHA1 to install a specific version of GitLab, e.g. 6-4-stable"
  },
  "postgresql": {
    "password": {
      "postgres": "psqlpass"
    }
  },
  "mysql": {
    "server_root_password": "mysql root password",
    "server_repl_password": "mysql replication password; omit this line for a random password",
    "server_debian_password": "Debian administration password; omit this line for a random password"
  },
  "postfix": {
    "mail_type": "client",
    "myhostname": "mail.example.com",
    "mydomain": "example.com",
    "myorigin": "mail.example.com",
    "smtp_use_tls": "no"
  },
  "run_list": [
    "postfix",
    "gitlab::default"
  ]
}
EOF
```

You only need to keep parameters which need to differ from their default values.
For example, if you are using `mysql`, there is no need to keep the `postgresql` configuration.

First we install dependencies based on the OS used:

```bash
distro="$(cat /etc/issue | awk ''NR==1'{ print $1 }')"
case "$distro" in
  Ubuntu)
    sudo apt-get update
    sudo apt-get install -y build-essential git curl # We need git to clone the cookbook, newer version will be compiled using the cookbook
  ;;
  CentOS)
    yum groupinstall -y "Development Tools"
  ;;
  *)
    echo "Your distro is not supported." 1>&2
    exit 1
  ;;
esac
```

Next run:

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
sudo chef-solo -c /tmp/solo.rb -j /tmp/solo.json
```

Chef-solo command should start running and setting up GitLab and it's dependencies.
No errors should be reported and at the end of the run you should be able to navigate to the
`gitlab['host']` you specified using your browser and connect to the GitLab instance.

You should consider removing the `.json` file once you are done with it since
it contains sensitive information:

```bash
rm /tmp/solo.json
```
### Enabling HTTPS

In order to enable HTTPS you will need to provide the following custom attributes:

```json
{
  "gitlab": {
    "port": 443,
    "url": "https://example.com/",
    "ssl_certificate": "-----BEGIN CERTIFICATE-----\nLio90slsdflsa0salLfjfFLJQOWWWWFLJFOAlll0029043jlfssLSIlccihhopqs\n-----END CERTIFICATE-----",
    "ssl_certificate_key": "-----BEGIN PRIVATE KEY-----\nLio90slsdflsa0salLfjfFLJQOWWWWFLJFOAlll0029043jlfssLSIlccihhopqs\n-----END PRIVATE KEY-----"
  }
}
```

### Cloning GitLab from private repository

By default GitLab is cloned from the public repository.
If you need to clone GitLab from a private repository (eg. you are maintaining a fork or need to install GitLab Enterprise) you need to specify a deploy key:

```json
{
  "gitlab": {
    "deploy_key": "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAK\n-----END RSA PRIVATE KEY-----"
  }
}
```

*Note*: Deploy key is a *private key*.
=======
*Note*: SSL certificate(.crt) and SSL certificate key(.key) must be in valid format. If this is not the case nginx won't start! By default, both the certificate and key will be located in `/etc/ssl/` and will have the name of HOSTNAME, eg. `/etc/ssl/example.com.crt` and `/etc/ssl/example.com.key`.

### Including multi-line strings in JSON
It is not possible to just copy-paste a multi-line string such as an SSL certificate into a JSON file.
You can use the following one-liner to format a file or standard input for inclusion in JSON (using Ruby 1.9):

```bash
ruby -rjson -e 'puts JSON.dump([ARGF.read])[1..-2]' my_site.cert
```

### Storing repositories and satellites in a custom directory
In some situations it can be practical to put repository and satellite data on a separate volume.
Below we assume that the GitLab system user (`git`) will have UID:GID 1234:1234, and that `/mnt/storage` is owned by 1234:1234.

```json
{
  "gitlab": {
    "user_uid": 1234,
    "user_gid": 1234,
    "repos_path": "/mnt/storage/repositories",
    "satellites_path": "/mnt/storage/satellites"
  }
}
```
