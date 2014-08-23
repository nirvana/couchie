#Couchie

Couchie is a minimalist API for accessing Couchbase 2.0 servers from within elixir. It should work for elrangers as well, as elixir code can be called from erlang (since it runs on the erlang vm.)

### Status:  CRUD Working, Simple Views Supported.
- Tagged version supports R17.0 & Elixir 0.13.0
- Master requires Elixir 0.15ish and R17ish

### Description

Couchie uses cberl (libcouchbase as a NIF) for database access and Jazz to turn the JSON documents that Couchbase returns into Elixir Maps.

Couchie has recently become "opinionated" in that it expects you to be storing maps (though any structure that Jazz's encoders can handle should work.)  Decoding has the atoms keys set, so that the keys in the maps you get back will be atoms.

### Building

Note: to build, you need to have libcouchbase installed.

	brew install libcouchbase

### Example

```

	$ iex -S mix
	Erlang R16B (erts-5.10.1) [source-05f1189] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false]

	Interactive Elixir (0.8.1) - press Ctrl+C to exit (type h() ENTER for help)
	iex(1)> Couchie.open(:d)
	Opening d, 10, localhost:8091
	Opening d, 10, localhost:8091, , ,  
	Opened d, 10, localhost:8091
	:ok
	iex(2)> Couchie.set(:d, "foo", %{foo: "bar"})
	:ok
	iex(3)> Couchie.get(:d, "foo")
	{"foo", 10812679138524069888, %{foo: "bar"}}
	iex(4)>
```

## Simple support for cberl views"
```
Couchie.open(:beer, 10, 'cb.server.w.beer.sample:8091', 'beer-sample', 'beer-sample', '')
Couchie.query(:beer, 'beer', 'brewery_beers', [{:limit, 10}])
```

##Current functionality
- Basic commands: Set, Get, MGet, Delete
- named connections.
- Support multiple buckets open simultaneously
- Support raw and json encoding of data

##Planned functionality
- Simple translation from the Couchbase View's REST API to elixir functions, allowing complex queries to be supported.
