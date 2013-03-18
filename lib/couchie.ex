defmodule Couchie do
     @moduledoc """
      Minimalist Elixir interface to Couchbase 2.0
      """
   
	@doc """
 	Open a connection pool to the server:
 	Open takes a connection configuration consisting of connection name, 
	size of the pool to set up, hostname & port, username, password.

	  ## Examples

	  		# open connection named "default_connection" to the default bucket, which should be used for testing only
	      Couchie.open(:default_connection)
	      {ok, <0.XX.0>} #=> successful connection to default bucket on localhost

			# if your bucket is password protected:
	      Couchie.open(:secret, 10, "localhost:8091", "bucket_name", "bucket_pasword")
	      {ok, <0.XX.0>} #=> successful connection to the named bucket, which you can access using the id "secret"
			
			# if your bucket isn't password protected (and isn't default)
	      Couchie.open(:application, 10, "localhost:8091", "bucket_name", "")
	      {ok, <0.XX.0>} #=> successful connection to the named bucket, which you can access using the id "application"

	  """
 	def open(name) do  
		:cberl.start_link(name, 10)
 	end

 	def open(name, size, host, bucket) do  
		:cberl.start_link(name, 10)
 	end

  	def open(name, size, host, bucket, pass) do  #currently usernames are set to bucket names in this interface.
		:cberl.start_link(name, size, host, bucket, pass, bucket)
  	end
	
     @doc """
 	Shutdown the connection to a particular bucket
	
		Couchie.stop(:application)
  	"""
	def quit(pool) do
		:cberl.stop(pool)
	end
	
	@doc """
 	Create document if it doesn't exist, or replace it if it does.
	First parameter is the connection you passed into Couchie.open()

	  ## Examples

	  		# 
	      Couchie.set(:default, "key", "document data")
	  """
	def set(connection, key, document) do
		Couchie.set(connection, key, document, 0)
	end

	@doc """
 	Create document if it doesn't exist, or replace it if it does.
	First parameter is the connection you passed into Couchie.open()
 	If you want the document to be purged after a period of time, use the Expiration.
	Set expiration to zero for permanent storage (or use set/3)

	  ## Example

	      Couchie.set(:default, "key", "document data", 0)
	  """
	def set(connection, key, document, expiration) do
		:cberl.set(connection, key, document, expiration)
	end
 
     @doc """
 	Get document.  Keys should be binary. 
  	## Example

      Couchie.get(:connection, "test_key")
  	"""
	def get(connection, key) do
		:cberl.get(connection, key)
	end
 
     @doc """
 	Get multiple documents from a list of keys  Keys should be binary. 
  	## Example

      Couchie.mget(:connection, ["test_key", "another key"])
  	"""
	def mget(connection, keys) do
		:cberl.mget(connection, keys)
	end

     @doc """
 	Delete document.  Key should be binary. 
  	## Example

      Couchie.delete(:connection, "test_key")
  	"""
	def delete(connection, key) do
		:cberl.remove(connection, key)
	end
 
end
#
# 	
#

