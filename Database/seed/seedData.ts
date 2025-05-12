import fs from 'fs';
import csv from 'csv-parser';

const generateSQL = async () => {
    const results: any[] = [];
    const outputFile = './seed/generated_inserts.sql';

    // Read the CSV file
    fs.createReadStream('./seed/data.csv')
        .pipe(csv())
        .on('data', (data) => results.push(data))
        .on('end', () => {
            const sqlStatements = results.map((row) => {
                return `INSERT INTO employees (name, email, alphanumeric, start_date, line_manager, line_manager_department, department, department_email)
                VALUES ('${row['Employee Name']}', '${row['email']}', '${row['alphanumeric']}', TO_DATE('${row['Employee Start Date']}', 'DD.MM.YY'), '${row['Current Line Manager']}', '${row['Line Manager Department']}', '${row['Department']}', '${row['Department email']}');`;
            });

            // Write the SQL statements to a file
            fs.writeFileSync(outputFile, sqlStatements.join('\n'));
            console.log(`SQL statements generated in ${outputFile}`);
        });
};

generateSQL();