const net = require('net');

const { sendJSON } = require('./ByondCommunication');
const { handleRequest } = require('./ByondHandlers');

const HOST = '127.0.0.1';

function startByondServer(byondPort, io, shutdown_function) {
    const ByondServer = net.createServer((stream) => {
        stream.on('data', (data) => {
            const jsonStr = data.toString('utf-8');

            try {
                const json = JSON.parse(jsonStr);
                handleRequest(json, byondPort + 1, io, shutdown_function);
            }
            catch (err) {
                console.log(jsonStr);
                console.error('Invalid JSON:', err);
                sendJSON({ error: 'invalid JSON', data: err.toString() }, byondPort + 1);
            }
        });

        stream.on('error', (err) => {
            console.error('Socket stream error:', err);
        });
    });

    ByondServer.listen(byondPort + 1, HOST, () => {
        console.log(`BYOND bridge listening on ${HOST}:${byondPort + 1}`);
    });

    ByondServer.on('error', (err) => {
        console.error('Bridge server error:', err);
    });

    return ByondServer;
}

module.exports = { startByondServer };
