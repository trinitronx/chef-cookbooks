SSL Certs Biola Cookbook
========================

Copies SSL certs from encrypted data bags to your nodes.

How to Use
----------

Add an your SSL certs to an encrypted data bag called
`ssl_certs` like so

    {
      "id":"example_com",
      "key":"-----BEGIN RSA PRIVATE KEY-----\n...\n-----END RSA PRIVATE KEY-----",
      "cert":"-----BEGIN CERTIFICATE-----\n...\n-----END CERTIFICATE-----"
    }

Then add an attribute to your role or node like so

    {
      "ssl_certs_biola": {
        "cert_names":  ["example_com"]
      }
    }

Default Attributes
------------------

    {
      "ssl_certs_biola": {
        "data_bag_name": "ssl_certs",
        "key_dir": "/etc/ssl/private",
        "cert_dir": "/etc/ssl/certs"
      }
    }