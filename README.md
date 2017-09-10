# Toshi

[![Build Status](https://img.shields.io/travis/coinbase/toshi/master.svg?style=flat)](https://travis-ci.org/coinbase/toshi)
[![Code Climate](https://img.shields.io/codeclimate/github/coinbase/toshi.svg?style=flat)](https://codeclimate.com/github/coinbase/toshi)
[![Inline Docs](http://inch-ci.org/github/coinbase/toshi.svg?style=flat)](http://inch-ci.org/github/coinbase/toshi)

Toshi is a complete implementation of the Bitcoin protocol, written in Ruby and backed by PostgreSQL. It provides a RESTful API that is ideal for building scalable web applications or analyzing blockchain data.

Toshi is designed to be fully compatible with [Bitcoin Core](https://github.com/bitcoin/bitcoin).
It performs complete transaction and block validation, and passes 100% of TheBlueMatt's
[regression test suite](https://github.com/TheBlueMatt/test-scripts).
For much of the core protocol logic, Toshi makes use of the [bitcoin-ruby](https://github.com/lian/bitcoin-ruby)
library written and maintained by Julian Langschaedel.

Toshi was built at [Coinbase](https://coinbase.com), with the goal of replacing
our core Bitcoin network infrastructure in the near future. It is currently in beta,
and not recommended for production use until it has received sufficient testing
from the Bitcoin community.

You can see Toshi running on various networks at the following URLs:

* https://bitcoin.toshi.io/
* https://testnet3.toshi.io/
* https://litecoin.toshi.io/

## Features

 * Complete Bitcoin node implementation
 * Fully passes TheBlueMatt's [regression test suite](https://github.com/TheBlueMatt/test-scripts)
 * PostgreSQL backed (more convenient for web applications and research)
 * JSON, Hex, and Binary API
 * Simple web [interface](https://bitcoin.toshi.io) to monitor node status

## What is a Bitcoin node?

A Bitcoin node is simply a client on the Bitcoin peer-to-peer network. It validates and relays transactions and blocks to other clients according to the consensus rules as implemented in [Bitcoin Core](https://github.com/bitcoin/bitcoin). A "full node" implies that the client retains a complete copy of the Bitcoin blockchain.

## Toshi vs. Bitcoin Core

**Toshi** is a Bitcoin implementation designed for building highly scalable web applications. It allows you to query the blockchain using a REST API or raw SQL. It comprises a number of individual services, using a shared database. Because Toshi saves much more information and indexes more data than Bitcoin Core, it requires much more space to store the blockchain (~220GB vs ~25GB as of September 2014). However, this makes it possible to run much richer queries that would otherwise not be possible with Bitcoin Core.

**Bitcoin Core** (the reference implementation) is designed to run on a single server, and uses a mixture of raw files and LevelDB to store the blockchain. It allows you to query the blockchain using a JSON-RPC interface.

Some examples of queries which Toshi can easily answer, which are not possible with Bitcoin Core:

* List all unspent outputs for any address (Bitcoin Core only indexes unspent outputs for specific addresses added to the local "wallet").
* Get the balance of any address
* Get the balance of any address at a specific point in time
* Find all transactions for any address
* Find all transactions in a certain time period
* Find all transactions over a certain amount
* Find all transactions given a set of addresses

## Usage

### Hosted Toshi

Coinbase maintains a hosted version of Toshi that you can use at:

**[https://bitcoin.toshi.io](https://bitcoin.toshi.io)**

This is the easiest way to get up and running. You can also run your own version of Toshi as described below.

### Running Toshi locally

    $ git clone https://github.com/coinbase/toshi.git
    $ cd toshi

We use [Docker](https://www.docker.com/) with
[Docker Compose](http://docs.docker.com/compose/install/):

    $ docker-compose build
    $ docker-compose start db
    $ docker-compose run web bundle exec rake db:create

    $ docker-compose build # run this before `up` to run the latest code
    $ docker-compose up
    $ open localdocker:5000 # use `boot2docker ip` for the address if using boot2docker

## Testing

You can run the test suite for Toshi as follows:

    $ git submodule init
    $ git submodule update
    $ docker-compose build
    $ docker-compose run -e TOSHI_ENV=test web bundle exec rake db:create

    $ docker-compose run -e TOSHI_ENV=test web bundle exec rspec


### Bootstrap.dat

Toshi can import the standard `bootstrap.dat` file that bitcoind uses to load
the beginning of the blockchain using the `./bin/bootstrap.rb` command.

    export BOOTSTRAP_FILE=/path/to/bootstrap.dat
    export TOSHI_ENV=production
    ./bin/bootstrap.rb

### Deployment

Toshi can be deployed directly to Heroku:

[![Deploy](https://www.herokucdn.com/deploy/button.png)](https://heroku.com/deploy?template=https://github.com/coinbase/toshi)

After it is deployed, you can start syncing with the following command:

    $ heroku ps:scale web=1 peer_manager=1 block_worker=1 transaction_worker=1

For more detailed Heroku deployment instructions you can [read this page](https://github.com/coinbase/toshi/wiki/Deploying-To-Heroku).

Toshi can also be installed on your own server. You will need:

* PostgreSQL (300gb+ disk space required to sync mainnet)
* Redis (50mb+ RAM recommended)
* Ruby 2.0.0+

To run Toshi on your server, simply:

    $ git clone https://github.com/coinbase/toshi.git
    $ cd toshi
    $ cp config/toshi.yml.example config/toshi.yml
    $ vi config/toshi.yml
    $ REDIS_URL=redis://... DATABASE_URL=postgres://... TOSHI_ENV=production bundle exec foreman start

## API

> Note: The Toshi API provides raw blockchain data only. If you are looking for APIs to store bitcoin securely, buy/sell bitcoin, send/request bitcoin, accept merchant payments, etc) please check out the proprietary [Coinbase API](https://coinbase.com/docs/api/overview).

The API supports three data types by adding an extension on any URL.

`.json` - JSON (default if none specified)
`.hex` - raw binary, in hex form
`.bin` - raw binary

For GET requests, the extension specifies the format of the returned data.
For POST/PUT requests, the extension specifies the format of the request body.

Any API call which returns as list can also be passed an `offset` or `limit` parameter.  The default `limit` is 100.


    # Blocks
    GET /api/v0/blocks                             # Get a paginated list of blocks
    GET /api/v0/blocks/<hash>                      # Get a block by hash
    GET /api/v0/blocks/<height>                    # Get a block by height
    GET /api/v0/blocks/latest                      # Get the latest block
    GET /api/v0/blocks/<hash>/transactions         # Get transactions in a block

    # Transactions
    GET /api/v0/transactions/<hash>                # Get transaction by hash
    GET /api/v0/transactions/unconfirmed           # Get list of unconfirmed transactions
    POST /api/v0/transactions                      # Broadcast a transaction to the network

    # Addresses
    GET /api/v0/addresses/<hash>                   # Get address balance and details
    GET /api/v0/addresses/<hash>/transactions      # Get address transactions
    GET /api/v0/addresses/<hash>/unspent_outputs   # Get unspent outputs on an address


## Configuration

Toshi parses `config/toshi.yml` according to its current environment (determined by the `TOSHI_ENV` environment variable). Toshi will default to the `development` environment if one isn't specified and the `test` environment during rspec tests.

Toshi will use the `config/toshi.yml.example` file if the `config/toshi.yml` file does not exist.


## Contributing

1. Fork this repo and make changes in your own fork
2. Run existing tests with `bundle exec rspec` and add a new test for your changes if applicable.
3. Commit your changes and push to your fork `git push origin master`
4. Create a new pull request and submit it back to the project.


## OSX TROUBLESHOOTING

if you run into a problem with     
Could not find json-1.8.1 in any of the sources
https://ubuntuforums.org/showthread.php?t=2329304

#INSTALL RVM - ruby version manager (for gems)    
curl -sSL https://get.rvm.io | bash        
rvm install ruby-2.1.1    
gem install bundler      
bundle install   
