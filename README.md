This is a simple wrapper for tmysql, originally made by thelastpenguin, updated by me (aStonedPenguin) so we could replace mysqloo with tmysql on our servers.

To use place in: lua/includes/modules

Examle usage:

	require( 'pmysql' )

	db = db or pmysql.connect( hostname, username, password, database, port, optional_unix_socket_path ) - Connect

	pmysql.newdb - Same thing as pmysql.connect

	pmysql.getTable( ) - Returns a table of all active databases

	pmysql.pollAll( ) - Polls all databases

	pmysql.print( ... ) - Fancy prefixed MsgC

	pmysql.log( str ) - Logs to pmysql_logs.txt and calls pmysql.print

	pmysql.enableLog( true or false ) - Enable/Disable logging. Default: true

	pmysql.setMaxErrors( num ) - Max errors before a query is dropped. Default: Unlimited

	pmysql.setTimeOut( time ) - How long before a sync query times out and gets dropped. Default: 0.3

	db:escape( str )

	db:poll( )

	db:setCharset( charset )

	db:disconnect( )

	db:query( 'SELECT * FROM example', function( data ) - Normal query
	  PrintTable ( data )
	end )

	db:query_ex( 'SELECT * FROM example WHERE example=?', { player:SteamID() }, function( data ) - Escape all values
	  PrintTable ( data )
	end )

	- Synchronous query_ex, much like calling query:wait() in mysqloo. Timeout is optional and will use default otherwise. Query will return nil upon timeout.
	local data = db:query_sync( 'SELECT * FROM example WHERE example=?', { player:SteamID() }, timeout ) 
	PrintTable( data )
