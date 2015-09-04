# Client Certificates Manager
A bunch of scripts to manage client certificates for securing communications between the client's browser and the HTTPS server.

## Usage
### Configure the manager

It is recomended to change the owner of all files to _root_ user.

Copy the file **settings.conf.example** to **settings.conf**.

```
sudo cp settings.conf.example settings.conf
```

Change all the values in the **settings.conf** file.

```
# Default data for client certificates
export COUNTRY=MX
export STATE=Jalisco
export CITY=Guadalajara
export ORGANIZATION=Example Company
export DAYS=730
export BITS=4096

# Default export password of the PFX file
export EXPORT_PASS=something

# The common name of the CA (not needed to be the domain name)
export CA_COMMON_NAME=example.com

# The path where the CA will be created (filename path without extension)
export CA=./ca/ca-production

# The path where the revocation list will be created
export CRL_OUTPUT=./crl/revoke_list.pem

# The user in the system which will be the owner of the final PFX file
export PFX_USER=newint33h
```

Also check for the default values ant the end of the file **openssl.conf**.

```
default_ca	= CA_default

[ CA_default ]

dir		= ./crl			        # Where everything is kept
crl_dir		= $dir/crl		    # Where the issued crl are kept
database	= $dir/index.txt	# database index file.
crlnumber	= $dir/crlnumber	# the current crl number

default_crl_days= 365			# how long before next CRL
default_md	= sha1			    # which md to use.

```

### Initialize the manager

To created the needed files, run:

```
sudo ./initialize.sh
```

This will create the file ```$CA.crt``` that must be configured in the HTTPS server settings.

### Create a client certificate

To create a client certificate, run:

```
sudo ./generate.sh "myfilename:My Name"
```

All the required files will be created inside the __./clients__ directory.

The file __myfilename.pfx__ will be created with the user owner ```$PFX_USER```. That file should be imported to the client's browser of the OS key manager.

### Revoke a client certificate

To revoke a client certificate, run:

```
sudo ./revoke.sh "My Name"
```

or using the filename without extension:

```
sudo ./revoke.sh "myfilename"
```

This will update the file ```$CRL_OUTPUT.crl``` with the revoked certificate. This file should be set inside the HTTP server revocation list parameter.