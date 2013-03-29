defmodule Couchie do
     @moduledoc """
      Minimalist Elixir interface to Couchbase 2.0.
		
		Couchie is based on cberl which is a NIF of the libcouchbase & Jiffy JSON encoder NIF.
		
		JSON support is built in.  Pass in terms and they are encoded as JSON. 
		When you  fetch JSON documents you get terms.
		
		To store raw data, pass in a binary.
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
	      Couchie.open(:secret, 10, 'localhost:8091', 'bucket_name', 'bucket_pasword')
	      {ok, <0.XX.0>} #=> successful connection to the named bucket, which you can access using the id "secret"
			
			# if your bucket isn't password protected (and isn't default)
	      Couchie.open(:connection, 10, 'localhost:8091", 'bucket_name')
	      {ok, <0.XX.0>} #=> successful connection to the named bucket, which you can access using the id "application"

	  """
 	def open(name) do  
		open(name, 100, 'localhost:8091', '')
 	end

 	def open(name, size) do  
		open(name, size, 'localhost:8091', '')
 	end
	
	def open(name, size, host, bucket) do  
		open(name, size, host, bucket, '')
 	end

  	def open(name, size, host, bucket, pass) do  #currently usernames are set to bucket names in this interface.
		:cberl.start_link(name, size, host, bucket, pass, bucket, )
  	end

#cberl:start_link(PoolName, NumCon, Host, Username, Password, BucketName, Transcoder) ->	


     @doc """
 	Shutdown the connection to a particular bucket
	
		Couchie.close(:connection)
  	"""
	def close(pool) do
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
		doc2 = Couchie.preprocess document
		:cberl.set(connection, key, expiration, doc2)  # NOTE: cberl parameter order is different!
	end
 
    @doc """
 	Turn Dict into list for JSON conversion. Pass binaries along unmolested.
   	"""
	def preprocess(document) do
		case document do
			document when is_list(document) -> document #pass on lists unmolested
			document when is_binary(document) -> document #pass on binaries unmolested
			document -> {Dict.to_list document}   #If not a list or binary, it's a hashdict.
		end
	end

     @doc """
 	Get document.  Keys should be binary. 
  	## Example

      Couchie.get(:connection, "test_key")
      #=> {"test_key" 1234567890, "value"}  # The middle figure is the CAS for this document.
  	"""
	def get(connection, key) do
		result = :cberl.get(connection, key)
		postprocess(result)
	end
 
     @doc """
 	Get multiple documents from a list of keys  Keys should be binary. 
  	## Example

      Couchie.mget(:connection, ["test_key", "another key"])
  	"""
	def mget(connection, keys) do
		results = :cberl.mget(connection, keys)
		Enum.map results, Couchie.postprocess(&1)
	end

    @doc """
 	Remove the envelope around JSON results. Turn JSON structure into HashDict 
   	"""
	def postprocess({key,cas,value}) do
		case value do
			{[h|_]} when is_tuple(h) -> #If the first item is a tuple, we figure its a proplist.
				proplist_to_dict(key, cas, value)
			value when is_binary(value) -> {key, cas, value}  #just pass on binaries.
			_ -> {key, cas, value}  # anything else (Eg: straight list) we pass on unmolested
		end
	end

	defp proplist_to_dict(key, cas, value) do
		{value2} = value  # remove enclosing tuple, get list.
		value3 = HashDict.new value2
		{key, cas, value3}
	end

     @doc """
 	Delete document.  Key should be binary. 
  	## Example

      Couchie.delete(:connection, "test_key")
  	"""
	def delete(connection, key) do
		:cberl.remove(connection, key)
	end
 


     @doc """
 	Simple synchronous fetch view for when you have the specific url & parameters built. 
  	## Example

      Couchie.view("http://example.com:port/_design/foo/_view/bar")
  	"""
	def view(url) do
		case :ibrowse.send_req(url, [], :get) do
			{:error, reason} -> {:error, reason}
			{:ok, return_code, headers, body} -> view_process(return_code, headers, body)
		end
	end
 
	def view_process(return_code, headers, body) do
		headers_dict = HashDict.new headers
## this is not finished!  views not implemented yet, as I explore a different direction.		



	end










end
#
# 	
#

