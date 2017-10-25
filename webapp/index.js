// Pull in the libraries
const express    = require('express');
const bodyParser = require('body-parser');
const app        = express();
const Chatkit    = require('pusher-chatkit-server');
const chatkit    = new Chatkit.default(require('./config.js'))

// Express Middlewares
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: false }));

// --------------------------------------------------------
// Creates a new user using the Chatkit API
// --------------------------------------------------------
app.post('/users', (req, res) => {
    let username = req.body.username;
    chatkit.createUser(username, username)
         .then(r => res.json({username}))
         .catch(e => res.json({error: e.error_description, type: e.error_type}))
})


// --------------------------------------------------------
// Fetches a token from Chatkit and returns it
// --------------------------------------------------------
app.post('/auth', (req, res) => {
    let resp = chatkit.authenticate({grant_type: req.body.grant_type}, req.body.user_id)
    res.json(resp)
});


// --------------------------------------------------------
// Index
// --------------------------------------------------------
app.get('/', (req, res) => {
    res.json("It works!");
});


// --------------------------------------------------------
// Handle 404 errors
// --------------------------------------------------------
app.use((req, res, next) => {
    let err = new Error('Not Found');
    err.status = 404;
    next(err);
});

// --------------------------------------------------------
// Serve application
// --------------------------------------------------------
app.listen(4000, function(){
    console.log('App listening on port 4000!')
});

