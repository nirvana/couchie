#Couchie

couchie is a minimalist API for accessing Couchbase 2.0 servers from within elixir. It should work for elrangers as well, as elixir code can be called from erlang (since it runs on the erlang vm.)

This project is deliberately *not* using the libcouchbase library, or any NIFs due to the limitations of NIFs.  When erlang calls an NIF, the scheduler is suspended and no other processes can run, no matter how long the NIF call takes to return.  This breaks the concurrent nature of erlang.  Secondly, if a NIF crashes it can bring down the entire erlang VM. 

Thus only native erlang or elixir code is used here.

##Current functionality
- project just begun, nothing written yet.

##Planned functionality
- Basic support for data operations such as create, read, update, delete.
- Simple translation from the Couchbase View's REST API to elixir functions, allowing complex queries to be supported.

### working notes

% options: {host, port, connection pool size}
erlmc:start([{"localhost", 12233, 100}]).