const fs = require('fs');
const net = require('net');

const { sendJSON } = require('./ByondCommunication');
const { handleRequest } = require('./ByondHandlers');

const BYOND_SERVER_PORT = 27000;

function startByondServer(byondPort, io, shutdown_function) {
    const ByondServer = net.createServer((stream) => {
        stream.on('data', (data) => {
            const jsonStr = data.toString('utf-8');
            try {
                const json = JSON.parse(jsonStr);
                // console.log('Received JSON:', json);
                handleRequest(json, byondPort, io, shutdown_function);
            } catch (err) {
                console.log(jsonStr);
                console.error('Invalid JSON:', err);
                sendJSON({ error: 'invalid JSON', data: err }, byondPort)
            }
        });
        stream.on('end', () => {
        });
    });

    ByondServer.listen(BYOND_SERVER_PORT, '127.0.0.1', () => {
        console.log(`BYOND server listening on TCP port ${BYOND_SERVER_PORT}`);
    });

    ByondServer.on('error', (err) => {
        console.error('BYOND server error:', err);
    });
    return ByondServer;
}


module.exports = { startByondServer };