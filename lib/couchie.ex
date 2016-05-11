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
			iex> {:ok, _} = Couchie.open(:default_connection) 
			iex> :ok
			:ok

			# if your bucket is password protected:
			Couchie.open(:secret, 10, 'localhost:8091', 'bucket_name', 'bucket_pasword')
			{ok, <0.XX.0>} #=> successful connection to the named bucket, which you can access using the id "secret"

			# if your bucket isn't password protected (and isn't default)
			Couchie.open(:connection, 10, 'localhost:8091', 'bucket_name')
			{ok, <0.XX.0>} #=> successful connection to the named bucket, which you can access using the id "application"
	"""
	def open(name) do
		open(name, 10, 'localhost:8091')
	end

	def open(name, size) do
		open(name, size, 'localhost:8091')
	end

	def open(name, size, host) do
	open(name, size, host, '', '', '')
	end

	def open(name, size, host, bucket) do  # assume the bucket user and pass are the same as bucket name
		open(name, size, host, bucket, bucket, bucket)
	end

	def open(name, size, host, bucket, password) do  # username is same as bucket name
		open(name, size, host, bucket, bucket, password)
	end

	def open(name, size, host, bucket, username, pass) do  #currently usernames are set to bucket names in this interface.
	:cberl.start_link(name, size, host, username, pass, bucket, Couchie.Transcoder)
	end

	@doc """
	Shutdown the connection to a particular bucket

	## Examples

			iex> Couchie.open(:connection)
			iex> Couchie.close(:connection)
			:ok

	"""
	def close(pool) do
		:cberl.stop(pool)
	end

	@doc """
	Create document if it doesn't exist, or replace it if it does.
	First parameter is the connection you passed into Couchie.open()

	## Examples
			
			iex> Couchie.open(:default)
			iex> Couchie.set(:default, "key", "document data")
			:ok

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

			iex> Couchie.open(:default)
			iex> Couchie.set(:default, "key", "document data", 0)
			:ok

	"""
	def set(connection, key, document, expiration) do
		:cberl.set(connection, key, expiration, document)  # NOTE: cberl parameter order is different!
	end

	@doc """
	Create document if it doesn't exist, or replace it if it does.
	First parameter is the connection you passed into Couchie.open()
	If you want to verify the document hasn't been updated since the last read,
	use the cas property from the last read.

	## Example

      iex> Couchie.open(:default)
      iex> Couchie.set(:default, "key", "document data", 0, 12345)
      {:error, :key_eexists}

	"""
	def set(connection, key, document, expiration, cas) do
		:cberl.set(connection, key, expiration, document, :standard, cas)
	end


	@doc """
	Increment

	## Example

			iex> Couchie.open(:default)
			iex> Couchie.set(:default, "test_increment", 1)
			iex> {:ok, _, "2"} = Couchie.incr(:default, "test_increment")
			iex> :ok
			:ok

	"""
	def incr(connection, key, offset \\ 1, exp \\ 0) do
		:cberl.incr(connection, key, offset, exp)
	end


	@doc """
	Decrement

	## Example

			iex> Couchie.open(:default)
			iex> Couchie.set(:default, "test_decrement", 1)
			iex> {:ok, _, "0"} = Couchie.decr(:default, "test_decrement")
			iex> :ok
			:ok

	"""
	def decr(connection, key, offset \\ 1, exp \\ 0) do
		:cberl.decr(connection, key, offset, exp)
	end




	@doc """
	Get document.  Keys should be binary.
	## Example
			
			iex> Couchie.open(:default)
			iex> Couchie.set(:default, "test_key", %{:blah => "blah"})
			iex> {"test_key", _cas , res} = Couchie.get(:default, "test_key")
			iex> res
			%{"blah" => "blah"}

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
	Remove document.  Key should be binary.
	## Example

		Couchie.remove(:connection, "test_key")
	"""
	def remove(connection, key) do
		:cberl.remove(connection, key)
	end

	@doc """
	Empty the contents of the specified bucket, deleting all stored data.
	## Example

		Couchie.flush(:connection)
	"""
	def flush(connection) do
		:cberl.flush(connection)
	end

	@doc """
	Delete document.  Key should be binary.
	## Example

		Couchie.delete(:connection, "test_key")
	"""
	def view(connection, doc, view, args) do
		:cberl.view(connection, doc, view, args)
	end

	defmodule DesignDoc do
		@moduledoc """
		A struct that encapsulates a single view definition.

		It contains the following fields:

			* `:name`   - the view's name
			* `:map`    - the map function as JavaScript code
			* `:reduce` - the reduce function as JavaScript code (optional)
		"""
		defstruct name: nil, map: nil, reduce: nil
	end

	@doc """
	Creates or updates a view.

	Specify the name of the design you want to create or update as `doc_name`.
	The third parameter can be one view definition or a list of them. See DesignDoc struct above.

	## Example
		Couchie.create_view(:db, "my-views", %Couchie.DesignDoc{name: "only_youtube", map: "function(doc, meta) { if (doc.docType == 'youtube') { emit(doc.docType, doc); }}"})
	"""
	def create_view(connection, doc_name, %DesignDoc{} = view), do: create_view(connection, doc_name, [view])
	def create_view(connection, doc_name, views) do
		design_doc = {[{
			"views",
				{ views |> Enum.map(&view_as_json(&1)) }
			}]}
		:cberl.set_design_doc(connection, doc_name, design_doc)
	end

	defp view_as_json(view) do
		# convert one view definition to a tuple that can later be converted to json
		{ view.name,
			{ view
				|> Map.take([:map, :reduce])
				|> Enum.filter(fn {_k, v} -> !is_nil(v) end) # only put fields that are not nil
			}
		}
	end


	@doc """


	## Example

			iex> Couchie.open(:default)
			iex> {:ok, _results, _meta} = Couchie.query(:default, "select * from default limit 1")
			iex> :ok
			:ok

	"""
	def query(connection, query) do
		query = "statement=#{query}" |> to_char_list
		case :cberl.http(connection, '', query, 'application/x-www-form-urlencoded; charset=UTF-8', :post, :n1ql) do
			{:ok, 200, result} ->
				results = Poison.decode!(result)
				{:ok, results["results"], Map.delete(results, "results")}
			err ->
				err
		end
	end


	@doc """
	Delete view.
	## Example

		Couchie.remove_view(:connection, "design-doc-id")
	"""
	def remove_view(connection, doc_name) do
		:cberl.remove_design_doc(connection, doc_name)
	end

	@doc """
	Merges the couchbase document with a given map, to simplify cases where you are updating a few properties

	If "safe" is specified then CAS is used to verify it hasn't been changed while modifying.

	If doc has changed {:error, :key_eexists} is returned.

	## Example

	  	iex> Couchie.open(:default)
	  	...> Couchie.set(:default, "somekey", %{"key1" => 1, "key2" => 2})
	  	...> Couchie.merge(:default, "somekey", %{"key2" => "changed", "key3" => 3})
	  	...> {"somekey", _cas, doc} = Couchie.get(:default, "somekey")
	  	...> doc
	  	%{"key1" => 1, "key2" => "changed", "key3" => 3}

	"""
	def merge(connection, key, doc, safe \\ false) do
		case Couchie.get(connection, key) do
			{^key, cas , old_doc} ->
				cas_to_use = case safe do
					true ->
						cas
					false ->
						0
				end
				Couchie.set(connection, key, Map.merge(old_doc, doc), 0, cas_to_use)
			_ ->
				{:error, :key_enoent}
		end
end
