const express = require('express')
const morgan = require('morgan')
const fs = require('fs').promises

const app = express()
app.use(morgan('combined'))

let live = false
let ready = false;
const busyStack = [];

// Make it so the service responds with 503 service unavailable
// if the "live" flag is false
app.use(function (req, res, next) {
    if (live == false) {
        res.status(503).send("Service is unavailable")
    } else {
        next()
    }
})

app.get('/', (req, res) => {
    res.send(`\nHi there from version ${process.env.VERSION} on pod ${process.env.HOSTNAME}\n\n`)
})

app.get('/info', (req, res) => {
    // Display info about the target and the (secret) launch code
    res.send(`\nTarget: ${process.env.TARGET}\nLaunch code: ${process.env.LAUNCH_CODE}\n\n`)
})

app.get('/message', (req, res) => {
    // Display the message from environment variable
    res.send(`\n${process.env.MESSAGE}\n\n`)
})

app.get('/message2', async (req, res) => {
    // Display the message from the file in /app/data/message.txt
    const path = '/app/data/message.txt'
    try {
        const message = await fs.readFile(path, 'utf8')
        res.send(`\n${message}\n\n`)    
    } catch {
        res.send("\nNo message file found.\n\n")
    }
})

// Simulate a crashing process
app.get('/crash', (req, res) => {
    process.exit(1)
})

// Liveness probe - is the server live?
// We shouldn't even receive the request if it isn't
app.get('/live', (req, res) => {
    if (live) {
        res.status(200).send("OK")
    } else {
        res.status(503).send("Service is not live.")
    }
})

// Readiness probe - server might be live, but is it ready for new requests?
// For example, it may need some time out for a scheduled job etc.
app.get('/ready', (req, res) => {
    if (live && ready) {
        res.status(200).send("OK")
    } else if (live && !ready) {
        res.status(503).send("Service is live but not ready.")
    } else {
        res.status(503).send("Service is not live.")
    }
})

// Make the service stall (not live)
app.get('/stall', (req, res) => {
    live = false;
    ready = false;
    res.send(`${process.env.HOSTNAME} now stalled and not processing any further requests`)
})

// Make the service busy (not ready) for a period of time
// Pass the duration (in seconds) in the URL too
app.get('/busy/:duration(\\d+)', (req, res) => {
    const durationInSeconds = req.params.duration;
    ready = false;
    busyStack.push(1);
    setTimeout(function () {
        busyStack.pop();
        if (busyStack.length == 0) {
            ready = true;
        }
    }, durationInSeconds * 1000)
    res.send(`${process.env.HOSTNAME} has become busy and will be ready again in ${durationInSeconds} seconds.`)
})

const PORT = process.env.PORT || 8000

// Potentially take a while for the service to start
const startupTimeInSeconds = parseInt(process.env.STARTUP_TIME || "1")
console.log(`${process.env.HOSTNAME} is starting up...`)
setTimeout(function () {
    app.listen(PORT, function () {
        console.log(`${process.env.HOSTNAME} is listening on port ${PORT}`)
        live = true;
        ready = true;
    })
}, startupTimeInSeconds * 1000)
