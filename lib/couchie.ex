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
		IO.puts "Opening #{name}, #{size}, #{host}"
	open(name, size, host, '', '', '')
	IO.puts "Opened #{name}, #{size}, #{host}"
	end

	def open(name, size, host, bucket) do  # assume the bucket user and pass are the same as bucket name
		open(name, size, host, bucket, bucket, bucket)
	end

	def open(name, size, host, bucket, password) do  # username is same as bucket name
		open(name, size, host, bucket, bucket, password)
	end

	def open(name, size, host, bucket, username, pass) do  #currently usernames are set to bucket names in this interface.
		IO.puts "Opening #{name}, #{size}, #{host}, #{username}, #{pass}, #{bucket} "
	:cberl.start_link(name, size, host, username, pass, bucket, Couchie.Transcoder)
	end

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
		:cberl.set(connection, key, expiration, document)  # NOTE: cberl parameter order is different!
	end


	@doc """
	Get document.  Keys should be binary.
	## Example

		Couchie.get(:connection, "test_key")
		#=> {"test_key" 1234567890, "value"}  # The middle figure is the CAS for this document.
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

	@doc """
	Delete document.  Key should be binary.
	## Example

		Couchie.delete(:connection, "test_key")
	"""
	def query(connection, doc, view, args) do
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
				|> Enum.filter(fn {k, v} -> !is_nil(v) end) # only put fields that are not nil
			}
		}
	end

	@doc """
	Delete view.
	## Example

		Couchie.delete_view(:connection, "design-doc-id")
	"""
	def delete_view(connection, doc_name) do
		:cberl.remove_design_doc(connection, doc_name)
	end
end
