# Black Hole API Servers

## About Black Hole Servers

A black hole server is a process which simulates a production server without
actually executing any of the tasks that the real server might. This can be
helpful in the course of developing a client for the API, allowing you to 
run your own server for performance testing or simple compliance checks.

## Usage

Visit [http://nodejs.org](http://nodejs.org) and install Node JS. When the
installer finishes, open a command prompt and run: 

```
node -v
```

If you see a message along the lines of

```
v0.8.17
```
you should be good to go. To run the Push API black hole server, simply run:

```
node push.js
```

If you'd like to change the IP address or port to which the black hole binds,
those settings can be tweaked in the pushConfig.json file before running.

For details regarding the Push API, please consult the [Documentation](http://docs.xtify.com/display/APIs/Push+API+2.0).

If you experience any problems, please open an issue on [Github](https://github.com/Xtify/xtifyTools/issues).
