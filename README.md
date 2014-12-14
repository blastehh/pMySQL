This is a simple wrapper for tmysql, originally made by thelastpenguin, updated by me (aStonedPenguin) so we could replace mysqloo with tmysql on our servers.

Examle usage:

	db = db or pmysql.newdb( HOSTNAME, USERNAME, PASSWORD, DATABASE, PORT, OPTIONAL_UNIX_SOCKET_PATH ) - Connect

	db:query( 'SELECT * FROM example', function( data ) - Normal query
	  PrintTable ( data )
	end )

	db:query_ex( 'SELECT * FROM example WHERE example=?', { player:SteamID() }, function( data ) - Escape all values
	  PrintTable ( data )
	end )

	local data = db:query_sync( 'SELECT * FROM example WHERE example=?', { player:SteamID() } ) - Synchronous query_ex, much like calling query:wait() in mysqloo
	PrintTable( data )
