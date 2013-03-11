#Couchie

couchie is a minimalist API for accessing Couchbase 2.0 servers from within elixir. It should work for elrangers as well, as elixir code can be called from erlang (since it runs on the erlang vm.)

This project is deliberately *not* using the libcouchbase library, or any NIFs due to the limitations of NIFs.


##Current functionality
- Basic commands: Set, Get, Add, Delete, Stats

##Planned functionality
- Simple translation from the Couchbase View's REST API to elixir functions, allowing complex queries to be supported.

### Example

	$ iex -S mix
	Erlang R16B (erts-5.10.1) [source-05f1189] [64-bit] [smp:8:8] [async-threads:10] [hipe] [kernel-poll:false]

	Compiled lib/couchie.ex
	Generated couchie.app
	Interactive Elixir (0.8.1) - press Ctrl+C to exit (type h() ENTER for help)
	iex(1)> Couchie.start
	:ok
	iex(2)> Couchie.set "test_key", "{\"test_json_key\":\"test_json_value\"}"
	""
	iex(3)> Couchie.get "test_key"
	"{\"test_json_key\":\"test_json_value\"}"
	iex(4)> Couchie.mget ["test_key", "binary key", "atom_key"]
	[{"test_key","{\"test_json_key\":\"test_json_value\"}"},{"binary key","{ \"key\":\"value\"}"},{"atom_key","{ \"key\":\"value\"}"}]
	iex(5)> Couchie.delete "test_key"
	""
	iex(6)> Couchie.get "test_key"
	""

## License

Copyright 2013, all rights reserved.  

Please note that this code will eventually be released as open source, however, 
the license is not yet determined and the API is not stable. Until then it remains copyrighted.
It is available on github for evaluation purposes only.
