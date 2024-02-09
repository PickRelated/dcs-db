const path = require('path')
const fs = require('fs')

const fileNames = fs.readdirSync(path.resolve(__dirname, 'rawExport'))

fileNames.forEach((fileName) => {
  // eslint-disable-next-line import/no-dynamic-require
  const rawJSON = require(path.resolve(__dirname, 'rawExport', fileName))
  const airbases = []
  Object.values(rawJSON).forEach((raw) => {
    const airbase = { icao: raw.icao, id: raw.id, name: raw.name, position: raw.position }

    airbase.radio = Object.values(raw.radio)
      .map((obj) =>
        Object.entries(obj).map(([range, [modulation, frequency]]) => ({
          frequency,
          modulation,
          range: parseInt(range),
        })),
      )
      .flat()

    const beacons = Object.values(raw.beacons).map((values) => {
      let direction = Math.round(values.direction)
      if (direction < 0) {
        direction += 360
      }
      return { ...values, direction }
    })
    airbase.beacons = [...beacons]

    airbase.runways = Object.values(raw.runways)
      .map((name) =>
        name.split('-').map((name) => {
          const hdg = parseInt(name) * 10

          const runwayBeacons = []

          beacons.forEach((beacon) => {
            if (!beacon.direction) {
              return
            }
            if (Math.abs(beacon.direction - hdg) < 10) {
              runwayBeacons.push(beacon)
              airbase.beacons = airbase.beacons.filter(({ direction }) => direction !== beacon.direction)
            }
          })

          return { beacons: runwayBeacons, name }
        }),
      )
      .flat()

    airbases.push(airbase)
  })

  fs.writeFileSync(path.resolve(__dirname, 'dist', fileName), JSON.stringify(airbases))
})
