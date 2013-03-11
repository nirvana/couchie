defmodule Couchie do
     @moduledoc """
      Minimalist Elixir interface to Couchbase 2.0
      """
   
     @doc """
 	Start a connection pool to the server:
 	Start takes a list of pool configurations, each of which is a tuple, 
 	consisting of the hostname (as char list), port and number of connections.
	
	Couchie.start([{'localhost', 11211, 5}])
	or
	Couchie.start()  # connects on localhost at default memcached port
  	"""
	def start(connection_list) do
		:erlmc.start(connection_list)
	end
     @doc """
	Couchie.start()  # connects on localhost at default memcached port
  	"""
	def start() do
		:erlmc.start()
	end

     @doc """
 	Shutdown the connection to the server
	
	Couchie.quit()
  	"""
	def quit() do
		:erlmc.quit()
	end

     @doc """
 	Returns the stats object provided by the server. 
	
	Couchie.stats()
  	"""
	def stats() do
		:erlmc.stats()
	end
	
     @doc """
 	Set document.  Keys and documents should be binary. Documents should be valid json.
	
	Couchie.set("test_key","{ \"json_key\":\"json_value_string\"}")
  	"""
	def set(key, document) do
		:erlmc.set(key, document)
	end

     @doc """
 	Set expiring document.  
	Keys and documents should be binary. 
	Expiration time should be integer
	Documents should be valid json.
	
	Couchie.set("test_key","{ \"json_key\":\"json_value_string\"}", 123)
  	"""
	def set(key, document, expiration) do
		:erlmc.set(key, document, expiration)
	end

     @doc """
 	Add document.  Keys and documents should be binary. Documents should be valid json.
	
	Couchie.set("test_key","{ \"json_key\":\"json_value_string\"}")
  	"""
	def add(key, value) do
		:erlmc.add(key, value)
	end
 
     @doc """
 	Get document.  Keys should be binary. 
	
	Couchie.get("test_key")
  	"""
	def get(key) do
		:erlmc.get(key)
	end
 
     @doc """
 	Get multiple documents from a list of keys  Keys should be binary. 
	
	Couchie.get("test_key")
  	"""
	def mget(keys) do
		:erlmc.get_many(keys)
	end

     @doc """
 	Delete document.  Keys should be binary. 
	
	Couchie.delete("test_key")
  	"""
	def delete(key) do
		:erlmc.delete(key)
	end
 
     @doc """
 	Version Info from the server
	
	Couchie.version()
  	"""
	def version() do
		:erlmc.version()
	end

end
#
# 	
#

