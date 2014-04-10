#Couchie

Couchie is a minimalist API for accessing Couchbase 2.0 servers from within elixir. It should work for elrangers as well, as elixir code can be called from erlang (since it runs on the erlang vm.)

### Status:  CRUD Working, Simple Views Supported. Requires Elixir 0.13 & R17.0 for maps.

### Description

Couchie uses cberl (libcouchbase as a NIF) for database access and Jazz to turn the JSON documents that Couchbase returns into Elixir Maps.

Couchie has recently become "opinionated" in that it expects you to be storing maps (though any structure that Jazz's encoders can handle should work.)  Decoding has the atoms keys set, so that the keys in the maps you get back will be atoms.

### Building

Note: to build, you need to have libcouchbase installed.

	brew install libcouchbase

### Example
(this is a bit obsolete)

	$ iex -S mix
	Erlang R16B (erts-5.10.1) [source-05f1189] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false]

	Interactive Elixir (0.8.1) - press Ctrl+C to exit (type h() ENTER for help)
	iex(1)> Couchie.open(:default)
	{:ok,#PID<0.63.0>}
	iex(2)> Couchie.set(:default, "3-18-13-6-57", "value")
	:ok
	iex(3)> Couchie.get(:default, "3-18-13-6-57")
	{"3-18-13-6-57",16538602597327634432,"value"}
	iex(5)> Couchie.set(:default, "3-18-13-7-07", [:a, :b, :c])
	:ok
	iex(6)> Couchie.get(:default, "3-18-13-7-07")
	{"3-18-13-7-07",11380463241031450624,["a","b","c"]}
	iex(7)> Couchie.open(:cache, 10, 'localhost:8091', 'cache', 'cache')
	{:ok,#PID<0.77.0>}
	iex(8)> Couchie.set(:cache, "3-18-13-7-11", "test value")
	:ok
	iex(9)> Couchie.set(:cache, "3-18-13-7-12", ["a", 'b'], 10)
	:ok
	# more than ten seconds later...
	iex(10)> Couchie.get(:cache, "3-18-13-7-12")
	{"3-18-13-7-12",{:error,:key_enoent}}  #key has expired from memcached bucket.
	iex(11)> Couchie.get(:cache, "3-18-13-7-11")
	{"3-18-13-7-11",72057594037927936,"test value"}
	iex(12)> Couchie.set(:cache, "3-18-13-7-12", ["a", 'b'], 100)
	:ok
	iex(13)> Couchie.get(:cache, "3-18-13-7-12")
	{"3-18-13-7-12",216172782113783808,["a",'b']}
	# Storing data structures, like a HashDict
	iex(14)> bar = HashDict.new
	#HashDict<[]>
	iex(15)> bar = bar |> HashDict.put("key", "value")
	#HashDict<[{"key", "value"}]>
	iex(16)> Couchie.set(:default, "bar", bar)
	:ok
	iex(17)> Couchie.get(:default, "bar")
	{"bar", 983466356890402816, #HashDict<[{"key", "value"}]>}

## Simple support for cberl views"
Couchie.open(:beer, 10, 'cb.server.w.beer.sample:8091', 'beer-sample', 'beer-sample', '')
Couchie.query(:beer, 'beer', 'brewery_beers', [{:limit, 10}])

##Current functionality
- Basic commands: Set, Get, MGet, Delete
- named connections.
- Support multiple buckets open simultaneously
- Support raw and json encoding of data

##Planned functionality
- Simple translation from the Couchbase View's REST API to elixir functions, allowing complex queries to be supported.
