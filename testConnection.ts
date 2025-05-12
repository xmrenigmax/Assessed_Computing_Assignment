import oracledb from 'oracledb';

async function testConnection() {
    try {
        const connection = await oracledb.getConnection({
            user: 'your_username',
            password: 'your_password',
            connectString: 'your_host:your_port/your_service_name',
        });

        console.log('Connection successful!');
        await connection.close();
    } catch (err) {
        console.error('Error connecting to Oracle:', err);
    }
}

testConnection();