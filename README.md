# Blacklist

**Please Note:** This code is unmaintained, and just uploaded as a code dump.

This is a simple app to manage a block list of domains on OSX.
Domains can be temporarily enabled for a short period of time (e.g. block
twitter, except when you need access to test things) and was built
because I suck at productivity.

Also, it was hacked together one day and isn't really intended for serious use. Ok?

## Instalation

```sh
git clone git://github.com/Sutto/blacklist.git
cd blacklist
bundle
# Now run rackup config.ru as someone who can write /etc/hosts.
```