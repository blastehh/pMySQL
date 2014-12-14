pmysql = { };

require( 'tmysql4' );

local db_mt = { };
db_mt.__index = db_mt;

local function print( ... )
  return MsgC(Color(0,255,0), '[MYSQL] ', Color(255,255,255), ... .. '\n')
end

function pmysql.newdb( ... )
  local obj = {};
  setmetatable( obj, db_mt );
  
  local db = tmysql.initialize( ... );
  obj.db = db

  if obj.db then 
    print( 'Connected successfully.' );
  else
    print( 'Connection failed.' );
  end

  return obj;
end

function db_mt:query( sqlstr, cback )
  return self.db:Query( sqlstr, function( data, status, err )
    if status then
      if cback then cback( data ); end
    else
      print( err );
    end
  end, QUERY_FLAG_ASSOC );
end

function db_mt:query_ex( sqlstr, options, cback )
  table.foreach( options, function( k, v )
    options[ k ] = self:escape( v );
  end );

  sqlstr = sqlstr:gsub( '%%','%%%%' ):gsub( '?', '%%s' );
  sqlstr = string.format( sqlstr, unpack( options ) );
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
    self.db:Poll( );
  end

  return data;
end

function db_mt:escape( str )
  return tmysql.escape( tostring( str ) );
end