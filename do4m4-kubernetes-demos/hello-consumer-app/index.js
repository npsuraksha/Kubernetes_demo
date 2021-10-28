const express = require('express')
const morgan = require('morgan')
const axios = require('axios')

const app = express()
app.use(morgan('combined'))

app.get('/', async (req, res) => {
    // Make a call to the hello micro-service
    try {
        const response = await axios.get('http://hello-service');
        res.send(`\nHello micro-service said: ${response.data.trim()}\n\n`);    
    } catch {
        res.send('\nHello micro-service could not be contacted!\n\n');
    }
})

const PORT = process.env.PORT || 8000
app.listen(PORT, function () {
    console.log(`Listening on port ${PORT}`)
})