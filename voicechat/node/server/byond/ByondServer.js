const fs = require('fs');
const net = require('net');

const { sendJSON } = require('./ByondCommunication');
const { handleRequest } = require('./ByondHandlers');

const BYOND_SERVER_PORT = 27000;

function startByondServer(byondPort, io, shutdown_function) {
    const ByondServer = net.createServer((stream) => {
        let buffer = '';
        stream.on('data', (data) => {
            buffer += data.toString('utf-8');
        });
        stream.on('end', () => {
            try {
                if (buffer) {
                    const json = JSON.parse(buffer);
                    handleRequest(json, byondPort, io, shutdown_function);
                }
            } catch (err) {
                console.log(buffer);
                console.error('Invalid JSON:', err);
                sendJSON({ error: 'invalid JSON', data: err.message }, byondPort)
            }
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
