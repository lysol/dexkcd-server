redis = require 'redis'
http = require 'http'
querystring = require 'querystring'

destroy = (res) ->
    res.writeHead 200, 'Content-Type': 'application/json'
    res.write JSON.stringify action: 'destroy'
    res.end()

keep = (res) ->
    res.writeHead 404, 'Content-Type': 'application/json'
    res.write JSON.stringify action: 'keep'
    res.end()

serve = (req, res) ->
  fullData = ''
  req.on 'data', (chunk) -> fullData += chunk.toString()
  req.on 'end', () ->
    try
      hashed = (querystring.parse fullData).hash
      if hashed? and hashed.length == 40 and hashed.match /[0-9a-fA-F]{40}/
        redis.get "dexkcd:CheckHash:#{hashed}", (err, data) =>
          if err? or not data?
            console.log err
            keep res
          else
            destroy res
      else
        keep res
    catch err
      console.log "Error: #{err}"
      keep res

(http.createServer serve).listen 3001
