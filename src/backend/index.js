const { DynamoDBClient, ScanCommand, GetItemCommand, PutItemCommand, UpdateItemCommand, DeleteItemCommand } = require("@aws-sdk/client-dynamodb");
const { marshall, unmarshall } = require("@aws-sdk/util-dynamodb");
const { randomUUID } = require("crypto");

const client = new DynamoDBClient({});
const DYNAMODB_TABLE_NAME = process.env.DYNAMODB_TABLE_NAME;

// Helper para crear logs con Métricas Embebidas (EMF)
const createMetric = (namespace, metricName, value, unit, dimensions) => {
    const metric = {
        "_aws": {
            "Timestamp": Date.now(),
            "CloudWatchMetrics": [{
                "Namespace": namespace,
                "Dimensions": [Object.keys(dimensions)],
                "Metrics": [{
                    "Name": metricName,
                    "Unit": unit
                }]
            }]
        },
        ...dimensions,
    };
    metric[metricName] = value;
    console.log(JSON.stringify(metric));
};

// Helper para respuestas de la API
const createResponse = (statusCode, body, headers = {}) => ({
    statusCode,
    headers: {
        "Content-Type": "application/json",
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Headers": "Content-Type,Authorization",
        "Access-Control-Allow-Methods": "OPTIONS,GET,POST,PUT,DELETE",
        ...headers,
    },
    body: JSON.stringify(body),
});

exports.handler = async (event) => {
    console.log("Request:", JSON.stringify(event, null, 2));
    const httpMethod = event.requestContext.http.method;
    const path = event.rawPath;
    const user = event.requestContext.authorizer?.jwt.claims;

    try {
        // --- Rutas Públicas ---
        if (httpMethod === "GET" && path === "/products") {
            const { Items } = await client.send(new ScanCommand({ TableName: DYNAMODB_TABLE_NAME }));
            return createResponse(200, Items.map(item => unmarshall(item)));
        }

        const singleProductMatch = path.match(/^\/products\/([a-zA-Z0-9_-]+)$/);
        if (httpMethod === "GET" && singleProductMatch) {
            const productId = singleProductMatch[1];
            const { Item } = await client.send(new GetItemCommand({ TableName: DYNAMODB_TABLE_NAME, Key: marshall({ id: productId }) }));
            if (!Item) return createResponse(404, { message: "Producto no encontrado" });
            createMetric("NetSolutionsApp", "ProductViewed", 1, "Count", { ProductId: productId });
            return createResponse(200, unmarshall(Item));
        }

        const purchaseMatch = path.match(/^\/products\/([a-zA-Z0-9_-]+)\/purchase$/);
        if (httpMethod === "POST" && purchaseMatch) {
            const productId = purchaseMatch[1];
            createMetric("NetSolutionsApp", "ProductPurchased", 1, "Count", { ProductId: productId, Category: "Demo" });
            return createResponse(200, { message: `Compra simulada para ${productId}` });
        }

        // --- Rutas Protegidas ---
        if (!user) {
            return createResponse(401, { message: "No autorizado. Se requiere autenticación." });
        }

        if (httpMethod === "POST" && path === "/products") {
            const body = JSON.parse(event.body);
            const product = { id: randomUUID(), ...body };
            await client.send(new PutItemCommand({ TableName: DYNAMODB_TABLE_NAME, Item: marshall(product) }));
            createMetric("NetSolutionsApp", "ProductCreated", 1, "Count", { UserId: user.sub });
            return createResponse(201, product);
        }

        if (httpMethod === "PUT" && singleProductMatch) {
            const productId = singleProductMatch[1];
            const body = JSON.parse(event.body);
            const updateExpression = "SET #n = :n, #d = :d, #p = :p, #c = :c";
            const expressionAttributeNames = { "#n": "name", "#d": "description", "#p": "price", "#c": "category" };
            const expressionAttributeValues = marshall({ ":n": body.name, ":d": body.description, ":p": body.price, ":c": body.category });
            const command = new UpdateItemCommand({
                TableName: DYNAMODB_TABLE_NAME, 
                Key: marshall({ id: productId }),
                UpdateExpression: updateExpression,
                ExpressionAttributeNames: expressionAttributeNames,
                ExpressionAttributeValues: expressionAttributeValues,
                ReturnValues: "ALL_NEW"
            });
            const { Attributes } = await client.send(command);
            createMetric("NetSolutionsApp", "ProductUpdated", 1, "Count", { ProductId: productId });
            return createResponse(200, unmarshall(Attributes));
        }

        if (httpMethod === "DELETE" && singleProductMatch) {
            const productId = singleProductMatch[1];
            await client.send(new DeleteItemCommand({ TableName: DYNAMODB_TABLE_NAME, Key: marshall({ id: productId }) }));
            createMetric("NetSolutionsApp", "ProductDeleted", 1, "Count", { ProductId: productId });
            return createResponse(204, null);
        }

        return createResponse(404, { message: "Ruta no encontrada" });

    } catch (error) {
        console.error("ERROR:", error);
        return createResponse(500, { message: "Error interno del servidor", error: error.message });
    }
};
