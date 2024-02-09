local json = require("json")
local Terrain = require('terrain')

local function init()
  env.info('Dumping airbases')

  local objects = {}
  local Airdromes = Terrain.GetTerrainConfig('Airdromes')

  local allBeacons = {}
  for b, beacon in pairs(Terrain.getBeacons()) do
    allBeacons[beacon.beaconId] = {
      direction = beacon.direction,
      type = beacon.type,
      callsign = beacon.callsign,
      frequency = beacon.frequency,
      channel = beacon.channel,
    }
  end

  local allRadio = {}
  for r, radio in pairs(Terrain.getRadio()) do
    allRadio[radio.radioId] = {}
    for range, value in pairs(radio.frequency) do
      allRadio[radio.radioId][tostring(range)] = value
    end
  end

  for i, airdrome in pairs(Airdromes) do
    local id = tostring(i)
    local point = airdrome.reference_point
    local lat, lng = coord.LOtoLL({ x = point.x, z = point.y })

    local runways = {}
    if airdrome.runways then
      for r, runway in pairs(airdrome.runways) do
        runways[tostring(r)] = runway.name
      end
    end

    local beacons = {}
    if airdrome.beacons then
      for b, beacon in pairs(airdrome.beacons) do
        beacons[tostring(b)] = allBeacons[beacon.beaconId]
      end
    end

    local radio = {}
    if airdrome.radio then
      for r, radioId in pairs(airdrome.radio) do
        radio[tostring(r)] = allRadio[radioId]
      end
    end

    objects[id] = {
      id = id,
      position = {
        lat = lat,
        lng = lng,
      },
      name = airdrome.display_name,
      icao = airdrome.code,
      runways = runways,
      beacons = beacons,
      radio = radio,
    }
  end

  local file = io.open(lfs.writedir()..env.mission.theatre..'airbases.json', 'w')
  file:write(json.encode(objects))
  file:close()

  env.info('Done')
end

init()