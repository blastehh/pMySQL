require( 'tmysql4' );

pmysql = { };

local db_cache = { };

local db_mt = { };
db_mt.__index = db_mt;

local function print( ... )
  return MsgC( Color( 0, 255, 0 ), '[MYSQL] ', Color( 255, 255, 255 ), ... .. '\n' )
end

function pmysql.newdb( HOSTNAME, USERNAME, PASSWORD, DATABASE, PORT, OPTIONAL_UNIX_SOCKET_PATH )
  local obj = { };
  setmetatable( obj, db_mt );
  
  obj.hash            = string.format( '%s:%s@%X:%s', HOSTNAME, PORT, util.CRC( USERNAME .. '-' .. PASSWORD ), DATABASE );

  if db_cache[ obj.hash ] then
    obj._db = db_cache[ obj.hash ]._db;
    print( 'Recycled database connection with hashid: ' .. obj.hash );
    return
  end

  obj._db, obj.err   = tmysql.initialize( HOSTNAME, USERNAME, PASSWORD, DATABASE, PORT, OPTIONAL_UNIX_SOCKET_PATH );
  obj.hostname       = HOSTNAME;
  obj.username       = USERNAME;
  obj.password       = PASSWORD;
  obj.database       = DATABASE;
  obj.port           = PORT;

  if obj._db then 
    print( 'Connected to database ' .. DATABASE .. ':' .. PORT .. ' successfully.' );
  elseif obj.err then
    print( 'Connection to database ' .. DATABASE .. ':' .. PORT .. ' failed. ERROR: ' .. obj.err );
    return
  end

  db_cache[ obj.hash ] = obj;

  return obj;
end
pmysql.connect = pmysql.newdb;

function pmysql.getTable( )
  return db_cache;
end

function pmysql.pollAll( )
  for _, db in pairs( pmysql.getTable() ) do
    db._db:poll( );
  end
end

function db_mt:escape( str )
  return tmysql.escape( tostring( str ) );
end

function db_mt:poll( )
  return self._db:Poll( );
end

function db_mt:setCharset( charset )
  return self._db:SetCharset( charset );
end

function db_mt:disconnect( )
  self._db:Disconnect( );
  db_cache[ self ] = nil;
end

function db_mt:query( sqlstr, cback )
  return self._db:Query( sqlstr, function( data, status, err )
    if status then
      if cback then cback( data ); end
    elseif err then
      print( err );
    end
  end, QUERY_FLAG_ASSOC );
end

function db_mt:query_ex( sqlstr, options, cback )
  if options ~= nil then
    table.foreach( options, function( k, v )
      options[ k ] = self:escape( v );
    end );

    sqlstr = sqlstr:gsub( '%%','%%%%' ):gsub( '?', '%%s' );
    sqlstr = string.format( sqlstr, unpack( options ) );
  end
  return self:query( sqlstr, cback );
end

function db_mt:query_sync( sqlstr, options ) 
  local data;
  local done = false;
  self:query_ex( sqlstr, options, function( _data )
    data = _data;
    done = true;
  end );

  while not done do
    self:poll( );
  end

  return data;
end
