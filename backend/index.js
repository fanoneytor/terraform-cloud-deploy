const { DynamoDBClient } = require("@aws-sdk/client-dynamodb");

// El cliente de DynamoDB y la región se configuran automáticamente a partir de las variables de entorno de Lambda
const client = new DynamoDBClient({}); 
const tableName = process.env.DYNAMODB_TABLE_NAME;

exports.handler = async (event) => {
    console.log("Evento recibido:", JSON.stringify(event, null, 2));

    // La respuesta de la API
    const response = {
        statusCode: 200,
        headers: {
            "Content-Type": "application/json",
            "Access-Control-Allow-Origin": "*", // Permitir peticiones desde cualquier origen (para la prueba)
            "Access-Control-Allow-Headers": "Content-Type",
            "Access-Control-Allow-Methods": "OPTIONS,GET"
        },
        body: JSON.stringify({
            message: "La API funciona y se ha desplegado automáticamente!",
            dynamoTableName: tableName,
            path: event.rawPath
        }),
    };
    
    return response;
};
